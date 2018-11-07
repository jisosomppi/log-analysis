base:
  'ws*':
    - rsyslog-client

  'srv*':
    - server-setup
    - rsyslog-server
    - logstash
    - elasticsearch
    - kibana
    - fixperms
