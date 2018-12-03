rsyslog-relp:
  pkg.latest
  
librelp-dev:
  pkg.latest

rsyslog:
  pkg.latest

/etc/rsyslog.conf:
  file.managed:
    - source: salt://rsyslog-server/rsyslog.conf
    - template: jinja
    - context:
      rsyslog_port: {{pillar.get('rsyslog_port','514')}}

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
