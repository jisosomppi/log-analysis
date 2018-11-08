logstash:
## should be logstash-oss but is not found
  pkg.installed:
    - version: '1:6.4.2-1'
#    - require:
#      - sls: elastic-pkg
#      - sls: java

/etc/logstash/conf.d/logstash.conf:
  file.managed:
    - source: salt://logstash/logstash.conf

logstash.service:
  service.running:
    - name: logstash
    - watch:
      - file: /etc/logstash/conf.d/logstash.conf
