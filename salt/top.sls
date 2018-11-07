base:
  'ws*':
    - rsyslog-client
    - fixperms

  'srv*':
    - server-setup
    - rsyslog-server
    - logstash
    - elasticsearch
    - kibana
