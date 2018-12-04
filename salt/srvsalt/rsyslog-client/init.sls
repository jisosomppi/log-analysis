rsyslog.install:
  pkg.latest:
    - pkgs:
      - rsyslog
      - rsyslog-relp
      - librelp-dev

/etc/rsyslog.conf:
  file.managed:
    - source: salt://rsyslog-client/rsyslog.conf
    - template: jinja
    - context:
      rsyslog_ip: {{salt['grains.get']('master')}}
      relp_port: {{pillar.get('relp_port', '10514')}}
      
/etc/ssl/localCA.pem:
  file.managed:
    - source: salt://rsyslog-client/localCA.pem

/etc/ssl/logclient.local.key:
  file.managed:
    - source: salt://rsyslog-client/logclient.local.key
    
/etc/ssl/logclient.local.crt:
  file.managed:
    - source: salt://rsyslog-client/logclient.local.crt

rsyslog.service:
  service.running:
    - name: rsyslog
    - watch:
      - file: /etc/rsyslog.conf
