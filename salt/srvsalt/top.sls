base:
  'ws*':
    - rsyslog-client

  'srv*':
    - rsyslog-server
    - elastic-pkg
    - java
    - logstash
    - elasticsearch
    - kibana
    - nginx
    - fixperms
