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

## {% if tiedosto ei olemassa /etc/elast/readonlyrestfilu %}
readonlyrest.plugin:
  - cmd.run: "sudo /usr/share/elasticsearch/bin/elasticsearch-plugin install file:///home/xubuntu/log-analysis/downloads/readonlyrest-1.16.28_es6.4.2.zip"
## {% endif %}

/etc/elasticsearch/readonlyrest.yml:
  file.managed:
    - source: salt://elasticsearch/readonlyrest.yml
    - template: jinja
    - context:
      elasticsearch_username: {{ pillar.get('elasticsearch_username','foo') }}
      elasticsearch_password: {{ pillar.get('elasticsearch_password','bar')

elasticsearch.service:
  service.running:
    - name: elasticsearch
    - watch:
      - file: /etc/elasticsearch/elasticsearch.yml
      - file: /etc/elasticsearch/readonlyrest.yml
