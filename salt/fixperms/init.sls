## Change permissions for all collected log files
## User and group: read and write for all files, execute only for directories

chmod ug=rwX -R /var/log/client_logs/:
  cmd.run
  require:
    - sls: rsyslog-server
