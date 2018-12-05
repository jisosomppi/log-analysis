include:
  - java

kibana-oss:
  pkg.installed:
    - skip_verify: True
    - require:
      - sls: java

/etc/kibana/kibana.yml:
  file.managed:
    - source: salt://kibana/kibana.yml
    - template: jinja
    - context:
      kibana_ip: {{pillar.get('kibana_ip','localhost')}}
      kibana_port: {{pillar.get('kibana_port','5601')}}
      elasticsearch_ip: {{pillar.get('elasticsearch_ip','localhost')}}
      elasticsearch_port: {{pillar.get('elasticsearch_port','9200')}}
      elasticsearch_username: {{pillar.get('elasticsearch_username','foo')}}
      elasticsearch_password: {{pillar.get('elasticsearch_password','bar')}}

kibana.service:
  service.running:
    - name: kibana
    - watch:
      - file: /etc/kibana/kibana.yml
