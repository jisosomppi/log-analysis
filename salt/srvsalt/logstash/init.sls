include:
  - java

logstash-oss:
  pkg.installed:
    - skip_verify: True
    - require:
      - sls: java

/etc/logstash/conf.d/logstash.conf:
  file.managed:
    - source: salt://logstash/logstash.conf
    - template: jinja
    - context:
      elasticsearch_ip: {{pillar.get('elasticsearch_ip','localhost')}}
      elasticsearch_port: {{pillar.get('elasticsearch_port','9200')}}
      elasticsearch_username: {{pillar.get('elasticsearch_username','NO_USERNAME')}}
      elasticsearch_password: {{pillar.get('elasticsearch_password','NO_PASSWORD')}}

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
