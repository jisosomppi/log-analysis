include:
  - java

elasticsearch-oss:
  pkg.installed:
    - version: '6.5.1'
    - require:
      - sls: java

/etc/elasticsearch/elasticsearch.yml:
  file.managed:
    - source: salt://elasticsearch/elasticsearch.yml
    - template: jinja
    - context:
      elasticsearch_port: {{pillar.get('elasticsearch_port','9200')}}
      elasticsearch_ip: {{pillar.get('elasticsearch_ip','localhost')}}

{%- if not salt['file.directory_exists']('/usr/share/elasticsearch/plugins/readonlyrest') %}
sudo /usr/share/elasticsearch/bin/elasticsearch-plugin install file:///tmp/v1.16.30_es6.5.1.zip -b -s:
  cmd.run
{%- endif %}

/etc/elasticsearch/readonlyrest.yml:
  file.managed:
    - source: salt://elasticsearch/readonlyrest.yml
    - template: jinja
    - context:
      elasticsearch_username: {{ pillar.get('elasticsearch_username','foo') }}
      elasticsearch_password: {{ pillar.get('elasticsearch_password','bar') }}

elasticsearch.service:
  service.running:
    - name: elasticsearch
    - watch:
      - file: /etc/elasticsearch/elasticsearch.yml
      - file: /etc/elasticsearch/readonlyrest.yml
