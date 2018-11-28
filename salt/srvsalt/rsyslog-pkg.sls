rsyslog-pkg:
  pkgrepo.managed:
    - humanname: Rsyslog Repository
    - ppa: adiscon/v8-stable
    - keyserver: keys.gnupg.net
    - keyid: AEF0CF8E
    - refresh_db: true
    - require_in:
      - rsyslog-client
      - rsyslog-server
