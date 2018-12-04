rsyslog-pkg:
  pkgrepo.managed:
    - humanname: Rsyslog Repository
    - ppa: adiscon/v8-stable
    - refresh_db: true
    - require_in:
      - rsyslog-client
      - rsyslog-server
