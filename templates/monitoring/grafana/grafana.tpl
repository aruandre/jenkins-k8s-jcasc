adminPassword: "1234"

service:
  name: service
  type: NodePort
  port: 80
  nodePort: ${nodePort}

datasources:
  datasources.yaml:
    apiVersion: 1
    datasources:
    - name: Prometheus
      type: prometheus
      access: server
      url: http://prometheus-server:80
      jsonData:
        httpMethod: POST
        manageAlerts: true
        prometheusType: Prometheus
        prometheusVersion: ${prometheusVersion}
        cacheLevel: Low

sidecar:
  dashboards:
    enabled: true
    label: grafana_dashboard
    folder: /tmp/dashboards