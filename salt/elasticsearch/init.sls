elasticsearch:
  pkg.installed

/etc/elasticsearch/elasticsearch.yml:
  file.managed:
    - source: salt://elasticsearch/elasticsearch.yml
    - template: jinja
    - context:
      elasticsearch_port: 9200

elasticsearch:
  service.running:
    - watch:
      - file: /etc/elasticsearch/elasticsearch.yml
