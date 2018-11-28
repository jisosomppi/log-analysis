base:
  'ws*':
    - rsyslog-pkg
    - rsyslog-client
    - etchosts

  'srv*':
    - etchosts
    - rsyslog-pkg
    - rsyslog-server
    - elastic-pkg
    - logstash
    - elasticsearch
    - kibana
    - nginx
    - fixperms
    - ufw
