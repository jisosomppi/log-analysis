rsyslog:
  pkg.installed

/etc/rsyslog.conf:
  file.managed:
    - source: salt://rsyslog-server/rsyslog.conf
    - template: jinja
    - context:
      server_port: 514

syslog.user:
  user.present:
    - name: syslog
    - groups:
      - adm
      - syslog

rsyslog.service:
  service.running:
    - name: rsyslog
    - watch:
      - file: /etc/rsyslog.conf
