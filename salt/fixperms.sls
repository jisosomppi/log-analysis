/var/log/client_logs/:
  file.directory:
    - makedirs: True
    - user: syslog
    - group: adm
    - dir_mode: 755
    - file_mode: 644
    - recurse
      - user
      - group
      - mode

#chmod a+rX -R /var/log/client_logs/:
#  cmd.run
