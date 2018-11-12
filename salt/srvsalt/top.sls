base:
  'ws*':
    - rsyslog-client
    - etchosts

  'srv*':
    - rsyslog-server
    - elastic-pkg
    - java
    - logstash
    - elasticsearch
    - kibana
    - nginx
    - fixperms
