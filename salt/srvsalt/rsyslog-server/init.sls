rsyslog.install:
  pkg.latest:
    - pkgs:
      - rsyslog
      - rsyslog-relp
      - librelp-dev

/etc/rsyslog.conf:
  file.managed:
    - source: salt://rsyslog-server/rsyslog.conf
    - template: jinja
    - context:
      relp_port: {{pillar.get('relp_port','10514')}}

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
