rsyslog:
  pkg.installed

/etc/rsyslog.conf:
  file.managed:
    - source: salt://rsyslog-client/rsyslog.conf
    - template: jinja
    - context:
      server_ip: 172.28.175.21
##    server_ip: {{grains['master']}}
##    server_ip: {{pillar.get('rsyslog_ip', '172.28.175.21')}}
      server_port: 514
##    server_port: {{pillar.get('rsyslog_port', '514')}}

rsyslog.service:
  service.running:
    - name: rsyslog
    - watch:
      - file: /etc/rsyslog.conf
