base:
  'ws*':
    - rsyslog-client
    - etchosts

  'srv*':
    - ssl-certificate
    - etchosts
    - rsyslog-server
    - elastic-pkg
    - java
    - logstash
    - elasticsearch
    - kibana
    - nginx
    - fixperms
