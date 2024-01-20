resource "kubernetes_namespace" "fluentd" {
  metadata {
    name = "fluentd"
  }
}

resource "kubernetes_config_map" "fluentd" {
  metadata {
    name = "config-volume"
    namespace = kubernetes_namespace.fluentd.id
  }

  # data = {
  #   "fluent.conf" = "${file("${path.module}/templates/fluentd/configmap.yml")}"
  # }

  data = {
    "fluent.conf" = <<EOF
<source>
  @type tail
  @id in_tail_kube_apiserver
  multiline_flush_interval 5s
  path /var/log/pods/*kube-apiserver*/kube-apiserver/*.log
  pos_file "#{File.join('/data/fluentd/', ENV.fetch('FLUENT_POS_EXTRA_DIR', ''), 'fluentd-kube-apiserver.log.pos')}"
  tag kube-apiserver
  <parse>
    @type json
    time_type string 
    time_format %Y-%m-%dT%H:%M:%S.%N%z
  </parse>
</source>

<source>
  @id fluentd-containers.log
  @type tail
  path /var/log/containers/*.log
  pos_file /var/log/es-containers.log.pos
  time_format %Y-%m-%dT%H:%M:%S.%NZ
  tag raw.kubernetes.*
  read_from_head true
  <parse>
    @type multi_format
    <pattern>
      format json
      time_key time
      time_format %Y-%m-%dT%H:%M:%S.%NZ
    </pattern>
    <pattern>
      format /^(?<time>.+) (?<stream>stdout|stderr) [^ ]* (?<log>.*)$/
      time_format %Y-%m-%dT%H:%M:%S.%N%:z
    </pattern>
  </parse>
</source>

<match **>
  @type stdout
</match>

# Enriches records with Kubernetes metadata
# <filter kubernetes.**>
#   @type kubernetes_metadata
# </filter>

<match **>
  @id opensearch
  @type opensearch
  @log_level info
  include_tag_key true
  host opensearch-cluster-master.opensearch
  port 9200
  scheme https
  user admin
  password admin
  ssl_verify false
  logstash_format true
  logstash_prefix k8s
  logstash_dateformat %d.%m.%Y
  <buffer>
    @type file
    path /var/log/fluentd-buffers/kubernetes.system.buffer
    flush_mode interval
    retry_type exponential_backoff
    flush_thread_count 2
    flush_interval 5s
    retry_forever
    retry_max_interval 30
    chunk_limit_size 2M
    queue_limit_length 8
    overflow_action block
  </buffer>
</match>
    EOF
  }
}

resource "kubernetes_daemonset" "fluentd" {
  metadata {
    name      = "fluentd"
    namespace = "fluentd"
  }

  spec {
    selector {
      match_labels = {
        name = "fluentd-ds"
      }
    }

    template {
      metadata {
        labels = {
          name = "fluentd-ds"
        }
      }

      spec {
        container {
          name  = "fluentd-ds"
          image = "andrar/fluentd-opensearch:0.1"

          resources {
            limits = {
              memory = "200Mi"
            }
            requests = {
              cpu    = "100m"
              memory = "200Mi"
            }
          }

          volume_mount {
            name       = "data"
            mount_path = "/data"
          }

          volume_mount {
            name       = "var-log-pods"
            mount_path = "/var/log/pods"
            read_only  = true
          }

          volume_mount {
            name       = "var-lib-docker-containers"
            mount_path = "/var/lib/docker/containers"
            read_only  = true
          }

          volume_mount {
            name       = "config-volume"
            mount_path = "/fluentd/etc/fluent.conf"
            sub_path   = "fluent.conf"
          }

          security_context {
            allow_privilege_escalation = false
            run_as_user                = 0
          }
        }

        termination_grace_period_seconds = 30

        volume {
          name = "data"
          host_path {
            path = "/data"
          }
        }

        volume {
          name = "var-log-pods"
          host_path {
            path = "/var/log/pods"
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
      }
    }
  }
}