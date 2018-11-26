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
    - template: jinja
    - context:
      elasticsearch_ip: {{pillar.get('elasticsearch_ip','localhost')}}
      elasticsearch_port: {{pillar.get('elasticsearch_port','9200')}}
      elasticsearch_user: {{pillar.get('elasticsearch_user','NO_USERNAME')
      elasticsearch_password: {{pillar.get('elasticsearch_password','NO_PASSWORD')

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
