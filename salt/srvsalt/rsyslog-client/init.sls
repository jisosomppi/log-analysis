rsyslog-relp:
  pkg.latest

librelp-dev:
  pkg.latest

rsyslog:
  pkg.latest

/etc/rsyslog.conf:
  file.managed:
    - source: salt://rsyslog-client/rsyslog.conf
    - template: jinja
    - context:
      rsyslog_ip: {{salt['grains.get']('master')}}
      rsyslog_port: {{pillar.get('rsyslog_port', '514')}}

rsyslog.service:
  service.running:
    - name: rsyslog
    - watch:
      - file: /etc/rsyslog.conf
