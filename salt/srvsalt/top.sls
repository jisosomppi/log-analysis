base:
  '*':
    - rsyslog-pkg
    - etchosts
    
  'ws*':
    - rsyslog-client
    - logtest

  'srv*':
    - rsyslog-server
    - elastic-pkg
    - logstash
    - elasticsearch
    - kibana
    - nginx
    - fixperms
    - ufw
