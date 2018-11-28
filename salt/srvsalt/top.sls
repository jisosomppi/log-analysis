base:
  'ws*':
    - rsyslog-client
    - etchosts

  'srv*':
    - etchosts
    - rsyslog-server
    - elastic-pkg
    - logstash
    - elasticsearch
    - kibana
    - nginx
    - fixperms
    - ufw
