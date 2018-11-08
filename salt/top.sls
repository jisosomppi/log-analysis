base:
  'ws*':
    - rsyslog-client

  '*':
    - rsyslog-server
    - elastic-pkg
    - java
    - logstash
    - elasticsearch
    - kibana
    - fixperms
