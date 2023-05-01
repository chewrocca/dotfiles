# op inject -i $HOME/.config/brew-services/grafana-agent-config.yml.tpl -o /usr/local/etc/grafana-agent/config.yml
integrations:
  agent:
    enabled: true
    relabel_configs:
      - action: replace
        source_labels:
          - agent_hostname
        target_label: instance
  node_exporter:
    enabled: true
    metric_relabel_configs:
      - action: keep
        regex: node_load5|node_filesystem_files_free|node_filesystem_files|node_vmstat_pgmajfault|node_disk_io_time_seconds_total|node_load1|node_filesystem_readonly|node_network_transmit_errs_total|node_memory_Cached_bytes|node_cpu_seconds_total|node_network_transmit_bytes_total|node_memory_total_bytes|node_textfile_scrape_error|node_disk_io_time_weighted_seconds_total|node_filesystem_size_bytes|node_memory_compressed_bytes|node_filesystem_avail_bytes|node_network_receive_errs_total|node_network_receive_bytes_total|node_network_transmit_packets_total|node_memory_MemAvailable_bytes|node_memory_MemFree_bytes|node_memory_internal_bytes|node_network_transmit_drop_total|node_network_receive_drop_total|node_load15|node_disk_read_bytes_total|node_uname_info|node_memory_wired_bytes|node_network_receive_packets_total|node_memory_purgeable_bytes|node_disk_written_bytes_total|node_memory_Buffers_bytes|node_memory_Slab_bytes|node_memory_MemTotal_bytes
        source_labels:
          - __name__
    relabel_configs:
      - replacement: mac0016437
        source_labels:
          - agent_hostname
        target_label: instance
      - replacement: integrations/macos-node
        source_labels:
          - agent_hostname
        target_label: job
  prometheus_remote_write:
    - basic_auth:
        password: op://Secrets/grafana cloud/Section_ntydhdke7lpxvrahvzaf3wdxba/token
        username: 540332
      url: https://prometheus-prod-10-prod-us-central-0.grafana.net/api/prom/push
logs:
  configs:
    - clients:
        - basic_auth:
            password: op://Secrets/grafana cloud/Section_ntydhdke7lpxvrahvzaf3wdxba/token
            username: 269136
          url: https://logs-prod3.grafana.net/loki/api/v1/push
      name: integrations
      positions:
        filename: /tmp/positions.yaml
      scrape_configs:
        - job_name: integrations/node_exporter_direct_scrape
          pipeline_stages:
            - multiline:
                firstline: ^([\w]{3} )?[\w]{3} +[\d]+ [\d]+:[\d]+:[\d]+|[\w]{4}-[\w]{2}-[\w]{2}
                  [\w]{2}:[\w]{2}:[\w]{2}(?:[+-][\w]{2})?
            - regex:
                expression: (?P<timestamp>([\w]{3} )?[\w]{3} +[\d]+
                  [\d]+:[\d]+:[\d]+|[\w]{4}-[\w]{2}-[\w]{2}
                  [\w]{2}:[\w]{2}:[\w]{2}(?:[+-][\w]{2})?) (?P<hostname>\S+)
                  (?P<sender>.+?)\[(?P<pid>\d+)\]:? (?P<message>(?s:.*))$
            - labels:
                ? hostname
                ? pid
                ? sender
            - match:
                selector: '{sender!="", pid!=""}'
                stages:
                  - template:
                      source: message
                      template: "{{ "{{.sender }}[{{.pid}}]: {{ .message }}" }}"
                  - labeldrop:
                      - pid
                  - output:
                      source: message
          static_configs:
            - labels:
                __path__: /var/log/*.log
                instance: mac0016437
                job: integrations/macos-node
              targets:
                - localhost
      target_config:
        sync_period: 10s
metrics:
  configs:
    - name: integrations
      remote_write:
        - basic_auth:
            password: op://Secrets/grafana cloud/Section_ntydhdke7lpxvrahvzaf3wdxba/token
            username: 540332
          url: https://prometheus-prod-10-prod-us-central-0.grafana.net/api/prom/push
    - name: vscode
      scrape_configs:
        - job_name: vscode
          scrape_interval: 5s
          static_configs:
            - targets:
                - localhost:9931
              labels:
                instance: mac0016437
                job: vscode
      remote_write:
        - basic_auth:
            password: op://Secrets/grafana cloud/Section_ntydhdke7lpxvrahvzaf3wdxba/token
            username: 540332
          url: https://prometheus-prod-10-prod-us-central-0.grafana.net/api/prom/push
  global:
    scrape_interval: 60s
    external_labels:
      location: austin
  wal_directory: /tmp/grafana-agent-wal
