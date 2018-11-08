default-jre:
  pkg.installed:
    - required_in:
      - sls: elasticsearch
      - sls: kibana
      - sls: logstash
