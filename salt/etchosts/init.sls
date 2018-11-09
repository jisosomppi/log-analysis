/etc/hosts:
  file.managed:
    - source: salt://etchosts/hosts
    - template: jinja
    - context:
      hostname: {{grains['localhost']}}
      logserver: {{grains['master']}}

networking:
  service.running:
    - watch: 
      - file: /etc/hosts
