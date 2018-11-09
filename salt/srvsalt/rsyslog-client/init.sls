rsyslog:
  pkg.installed

/etc/rsyslog.conf:
  file.managed:
    - source: salt://rsyslog-client/rsyslog.conf
    - template: jinja
    - context:
      rsyslog_ip: {{pillar.get('server_ip', '172.28.175.21')}}
##    rsyslog_ip: {{grains['master']}}
      rsyslog_port: {{pillar.get('rsyslog_port', '514')}}

rsyslog.service:
  service.running:
    - name: rsyslog
    - watch:
      - file: /etc/rsyslog.conf
