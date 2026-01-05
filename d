[1mdiff --git a/monitoring/grafana/datasources.yaml b/monitoring/grafana/datasources.yaml[m
[1mindex f2e20b7..b09471f 100644[m
[1m--- a/monitoring/grafana/datasources.yaml[m
[1m+++ b/monitoring/grafana/datasources.yaml[m
[36m@@ -6,10 +6,12 @@[m [mdatasources:[m
     access: proxy[m
     url: http://prometheus:9090[m
     isDefault: true[m
[32m+[m[32m    uid: prometheus[m
 [m
   - name: Loki[m
     type: loki[m
     access: proxy[m
     url: http://loki:3100[m
[32m+[m[32m    uid: loki[m
     jsonData:[m
       maxLines: 1000[m
[1mdiff --git a/monitoring/promtail/promtail-config.yaml b/monitoring/promtail/promtail-config.yaml[m
[1mindex 7889eb4..1ecb020 100644[m
[1m--- a/monitoring/promtail/promtail-config.yaml[m
[1m+++ b/monitoring/promtail/promtail-config.yaml[m
[36m@@ -9,46 +9,17 @@[m [mclients:[m
   - url: http://loki:3100/loki/api/v1/push[m
 [m
 scrape_configs:[m
[31m-  # 1. ZBIERANIE LOGÓW Z KONTENERÓW DOCKER (GŁÓWNY CEL!)[m
   - job_name: docker-containers[m
     docker_sd_configs:[m
       - host: unix:///var/run/docker.sock[m
         refresh_interval: 10s[m
     relabel_configs:[m
[31m-      # Pobierz nazwę kontenera[m
       - source_labels: ['__meta_docker_container_name'][m
         regex: '/(.*)'[m
         target_label: 'container'[m
       [m
[31m-      # Pobierz obraz kontenera[m
       - source_labels: ['__meta_docker_container_image'][m
         target_label: 'image'[m
       [m
[31m-      # Dodaj job label[m
       - target_label: 'job'[m
         replacement: 'docker-logs'[m
[31m-      [m
[31m-      # Zbieraj tylko logi aplikacji (pomiń monitoring)[m
[31m-      - source_labels: ['__meta_docker_container_name'][m
[31m-        regex: '(promtail|loki|grafana|prometheus|trivy)'[m
[31m-        action: drop[m
[31m-    [m
[31m-  # 2. LOGI Z RAPORTÓW TRIVY[m
[31m-  - job_name: trivy-reports[m
[31m-    static_configs:[m
[31m-      - targets:[m
[31m-          - localhost[m
[31m-        labels:[m
[31m-          job: trivy-reports[m
[31m-          app: security-scanner[m
[31m-          __path__: /reports/*.txt[m
[31m-  [m
[31m-  # 3. LOGI SYSTEMOWE (opcjonalnie)[m
[31m-  - job_name: system-logs[m
[31m-    static_configs:[m
[31m-      - targets:[m
[31m-          - localhost[m
[31m-        labels:[m
[31m-          job: system-logs[m
[31m-          host: docker-host[m
[31m-          __path__: /var/log/*.log[m
