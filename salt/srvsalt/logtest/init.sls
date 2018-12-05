/usr/local/bin/logtest.sh:
  file.managed:
    - source: salt://logtest/logtest.sh
    - file_mode: 755
