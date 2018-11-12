include:
  - java

elasticsearch-oss:
  pkg.installed:
    - version: '6.4.2'
    - require:
      - sls: java

/etc/elasticsearch/elasticsearch.yml:
  file.managed:
    - source: salt://elasticsearch/elasticsearch.yml
    - template: jinja
    - context:
      elasticsearch_port: {{pillar.get('elasticsearch_port','9200')}}
      elasticsearch_ip: {{pillar.get('elasticsearch_ip','localhost')}}

elasticsearch.service:
  service.running:
    - name: elasticsearch
    - watch:
      - file: /etc/elasticsearch/elasticsearch.yml
