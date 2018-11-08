openjdk-8-jre:
  pkg.installed:
    - required_in:
      - sls: elasticsearch
      - sls: kibana
      - sls: logstash
