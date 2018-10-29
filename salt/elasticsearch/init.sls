elasticsearch:
  pkg.installed
    - require:
      - sls: server-setup

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
