elasticsearch:
  pkg.installed:
    - version: '6.4.2'
#    - require:
#      - sls: java
#      - sls: elastic-pkg
        
/etc/elasticsearch/elasticsearch.yml:
  file.managed:
    - source: salt://elasticsearch/elasticsearch.yml
    - template: jinja
    - context:
      elasticsearch_port: 9200

elasticsearch.service:
  service.running:
    - name: elasticsearch
    - watch:
      - file: /etc/elasticsearch/elasticsearch.yml
