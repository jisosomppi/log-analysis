base:
  '*':
    - rsyslog-pkg
    - etchosts
    
  'ws*':
    - rsyslog-client
    - logtest

  'srv*':
    - rsyslog-server
    - logstash
    - elasticsearch
    - kibana
    - nginx
    - fixperms
    - ufw
