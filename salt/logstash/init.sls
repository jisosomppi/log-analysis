logstash:
  pkg.installed

/etc/logstash/conf.d/logstash.conf:
  file.managed:
    - source: salt://logstash/logstash.conf

logstash:
  service.running:
    - watch:
      - file: /etc/logstash/conf.d/logstash.conf
