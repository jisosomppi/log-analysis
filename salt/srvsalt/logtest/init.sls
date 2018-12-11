/usr/local/bin/logtest:
  file.managed:
    - source: salt://logtest/logtest
    - file_mode: 755

chmod a+x /usr/local/bin/logtest:
  cmd.run
