/usr/local/bin/logtest.sh:
  file.managed:
    - source: salt://logtest/logtest
    - file_mode: 755
