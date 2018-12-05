elastic-oss-pkg:
  pkgrepo.managed:
    - humanname: Elastic Co. - Apache 2.0
    - name: deb https://artifacts.elastic.co/packages/oss-6.x/apt stable main
    - dist: stable
    - file: /etc/apt/sources.list.d/elastic-oss-6.x.list
    - gpgcheck: 1
    - key_url: https://artifacts.elastic.co/GPG-KEY-elasticsearch
    - require_in:
      - elasticsearch
      - kibana
      - logstash
