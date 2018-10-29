rsyslog:
  pkg.installed

/etc/rsyslog.conf:
  file.managed:
    - source: salt://rsyslog/rsyslog.conf
    - template: jinja
    - context:
      server_ip: 172.28.175.21
      server_port: 514

rsyslog:
  service.running:
    - watch:
      - file: /etc/rsyslog.conf
