logstash:
  pkg.installed

/etc/logstash/conf.d/logstash.conf:
  file.managed:
    - source: salt://logstash/logstash.conf

logstash.service:
  service.running:
    - name: logstash
    - watch:
      - file: /etc/logstash/conf.d/logstash.conf
