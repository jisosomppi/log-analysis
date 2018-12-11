base:
  '*':
    - rsyslog-pkg
    - etchosts
    
  'ws*':
    - rsyslog-client
    - logtest
    - root-ca

  'srv*':
    - rsyslog-server
    - elastic-pkg
    - logstash
    - elasticsearch
    - kibana
    - nginx
    - fixperms
    - ufw
    - dashboard
