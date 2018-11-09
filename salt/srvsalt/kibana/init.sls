include:
  - java

kibana-oss:
  pkg.installed:
    - version: '6.4.2'
    - require:
      - sls: java

/etc/kibana/kibana.yml:
  file.managed:
    - source: salt://kibana/kibana.yml
    - template: jinja
    - context:
      kibana_port: pillar.get('kibana_port','5601')
      kibana_ip: pillar.get('kibana_ip','localhost')


kibana.service:
  service.running:
    - name: kibana
    - watch:
      - file: /etc/kibana/kibana.yml
