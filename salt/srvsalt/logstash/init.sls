include:
  - java

logstash:
  pkg.installed:
    - version: '1:6.4.2-1'
    - require:
      - sls: java

/etc/logstash/conf.d/logstash.conf:
  file.managed:
    - source: salt://logstash/logstash.conf

logstash.user:
  user.present:
    - name: logstash
    - groups: 
      - adm
      - syslog

logstash.service:
  service.running:
    - name: logstash
    - watch:
      - file: /etc/logstash/conf.d/logstash.conf
