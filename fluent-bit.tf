resource "kubernetes_service_account" "fluentbit" {
  metadata {
    name      = var.fluentbit_name
    namespace = kubernetes_namespace.logging.id
  }
}

resource "kubernetes_cluster_role" "fluentbit" {
  metadata {
    name = "${var.fluentbit_name}-read"
  }

  rule {
    api_groups = [""]
    resources  = ["namespaces", "pods"]
    verbs      = ["get", "list", "watch"]
  }
}

resource "kubernetes_cluster_role_binding" "fluentbit" {
  metadata {
    name = "${var.fluentbit_name}-read"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.fluentbit.metadata.0.name
  }

  subject {
    kind      = "ServiceAccount"
    name      = var.logging_namespace
    namespace = kubernetes_namespace.logging.id
  }
}

resource "kubernetes_config_map" "fluentbit" {
  metadata {
    name      = "config-volume"
    namespace = kubernetes_namespace.logging.id
  }

  data = {
    "fluent-bit.conf" = <<EOF
[SERVICE]
  Flush         1
  Log_Level     info
  Daemon        off
  Parsers_File  parsers.conf
  HTTP_Server   On
  HTTP_Listen   0.0.0.0
  HTTP_Port     ${var.fluentbit_port}

[INPUT]
  Name              tail
  Tag               kube.*
  Path              /var/log/containers/*.log
  Parser            docker
  DB                /var/log/flb_kube.db
  Mem_Buf_Limit     5MB
  Skip_Long_Lines   On
  Refresh_Interval  10

[FILTER]
  Name                kubernetes
  Match               kube.*
  Kube_URL            https://kubernetes.default.svc:443
  Kube_CA_File        /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
  Kube_Token_File     /var/run/secrets/kubernetes.io/serviceaccount/token
  Kube_Tag_Prefix     kube.var.log.containers.
  Merge_Log           On
  Merge_Log_Key       log_processed
  K8S-Logging.Parser  On
  K8S-Logging.Exclude Off

[OUTPUT]
  Name                opensearch
  Match               *
  Host                opensearch-cluster-master.logging
  Port                9200
  HTTP_User           admin
  HTTP_Passwd         admin
  Suppress_Type_Name  On
  Logstash_Format     On
  Logstash_Prefix     logs
  Replace_Dots        On
  Retry_Limit         False
  Compress            True
  tls                 On
  tls.verify          Off
EOF

    "parsers.conf" = <<EOF
[PARSER]
  Name   apache
  Format regex
  Regex  ^(?<host>[^ ]*) [^ ]* (?<user>[^ ]*) \[(?<time>[^\]]*)\] "(?<method>\S+)(?: +(?<path>[^\"]*?)(?: +\S*)?)?" (?<code>[^ ]*) (?<size>[^ ]*)(?: "(?<referer>[^\"]*)" "(?<agent>[^\"]*)")?$
  Time_Key time
  Time_Format %d/%b/%Y:%H:%M:%S %z

[PARSER]
  Name   apache2
  Format regex
  Regex  ^(?<host>[^ ]*) [^ ]* (?<user>[^ ]*) \[(?<time>[^\]]*)\] "(?<method>\S+)(?: +(?<path>[^ ]*) +\S*)?" (?<code>[^ ]*) (?<size>[^ ]*)(?: "(?<referer>[^\"]*)" "(?<agent>[^\"]*)")?$
  Time_Key time
  Time_Format %d/%b/%Y:%H:%M:%S %z

[PARSER]
  Name   apache_error
  Format regex
  Regex  ^\[[^ ]* (?<time>[^\]]*)\] \[(?<level>[^\]]*)\](?: \[pid (?<pid>[^\]]*)\])?( \[client (?<client>[^\]]*)\])? (?<message>.*)$

[PARSER]
  Name   nginx
  Format regex
  Regex ^(?<remote>[^ ]*) (?<host>[^ ]*) (?<user>[^ ]*) \[(?<time>[^\]]*)\] "(?<method>\S+)(?: +(?<path>[^\"]*?)(?: +\S*)?)?" (?<code>[^ ]*) (?<size>[^ ]*)(?: "(?<referer>[^\"]*)" "(?<agent>[^\"]*)")?$
  Time_Key time
  Time_Format %d/%b/%Y:%H:%M:%S %z

[PARSER]
  Name   json
  Format json
  Time_Key time
  Time_Format %d/%b/%Y:%H:%M:%S %z

[PARSER]
  Name        docker
  Format      json
  Time_Key    time
  Time_Format %Y-%m-%dT%H:%M:%S.%L
  Time_Keep   On

[PARSER]
  # http://rubular.com/r/tjUt3Awgg4
  Name cri
  Format regex
  Regex ^(?<time>[^ ]+) (?<stream>stdout|stderr) (?<logtag>[^ ]*) (?<message>.*)$
  Time_Key    time
  Time_Format %Y-%m-%dT%H:%M:%S.%L%z

[PARSER]
  Name        syslog
  Format      regex
  Regex       ^\<(?<pri>[0-9]+)\>(?<time>[^ ]* {1,2}[^ ]* [^ ]*) (?<host>[^ ]*) (?<ident>[a-zA-Z0-9_\/\.\-]*)(?:\[(?<pid>[0-9]+)\])?(?:[^\:]*\:)? *(?<message>.*)$
  Time_Key    time
  Time_Format %b %d %H:%M:%S
EOF
  }
}

resource "kubernetes_daemonset" "fluentbit" {
  metadata {
    name      = var.fluentbit_name
    namespace = kubernetes_namespace.logging.id
  }

  spec {
    selector {
      match_labels = {
        name = "fluentbit-ds"
      }
    }

    template {
      metadata {
        labels = {
          name = "fluentbit-ds"
        }
        annotations = {
          "prometheus.io/scrape" = "true"
          "prometheus.io/port"   = var.fluentbit_port
          "prometheus.io/path"   = "/api/v1/metrics/prometheus"
        }
      }

      spec {
        container {
          name  = "fluentbit-ds"
          image = "fluent/fluent-bit:latest-debug"
          port {
            container_port = var.fluentbit_port
          }

          volume_mount {
            name       = "var-log"
            mount_path = "/var/log"
          }
          volume_mount {
            name       = "var-lib-docker-containers"
            mount_path = "/var/lib/docker/containers"
            read_only  = true
          }
          volume_mount {
            name       = "config-volume"
            mount_path = "/fluent-bit/etc/"
          }
          volume_mount {
            name       = "mnt"
            mount_path = "/mnt"
            read_only  = true
          }
        }

        termination_grace_period_seconds = 10
        service_account_name             = kubernetes_service_account.fluentbit.metadata.0.name

        volume {
          name = "var-log"
          host_path {
            path = "/var/log"
          }
        }
        volume {
          name = "var-lib-docker-containers"
          host_path {
            path = "/var/lib/docker/containers"
          }
        }
        volume {
          name = "config-volume"
          config_map {
            name = "config-volume"
          }
        }
        volume {
          name = "mnt"
          host_path {
            path = "/mnt"
          }
        }

        toleration {
          key      = "node-role.kubernetes.io/master"
          operator = "Exists"
          effect   = "NoSchedule"
        }
        toleration {
          operator = "Exists"
          effect   = "NoExecute"
        }
        toleration {
          operator = "Exists"
          effect   = "NoSchedule"
        }
      }
    }
  }
}