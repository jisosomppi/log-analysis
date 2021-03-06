ufw:
  pkg.installed
 
/etc/ufw/ufw.conf:
  file.managed:
    - source: salt://ufw/ufw.conf

/etc/ufw/user.rules:
  file.managed:
    - source: salt://ufw/user.rules
    - template: jinja
    - context:
      rsyslog_port: {{pillar.get('rsyslog_port','514')}}
      elasticsearch_port: {{pillar.get('elasticsearch_port','9200')}}
      kibana_port: {{pillar.get('kibana_port','5601')}}
      nginx_port: {{pillar.get('nginx_port','80')}}
      ssh_port: {{pillar.get('ssh_port','22')}}
      ssl_port: {{pillar.get('ssl_port','443')}}
      relp_port: {{pillar.get('relp_port','10514')}}
      permitted_network: {{pillar.get('permitted_network','172.28.0.0/16')}}

ufw.service:
  service.running:
    - name: ufw
    - watch:
      - file: /etc/ufw/user.rules
      - file: /etc/ufw/ufw.conf
