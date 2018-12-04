# This configuration replaces the old version of 
# forcing chmod a+rX -R /var/log/client_logs/

/var/log/client_logs/:
  file.directory:
    - makedirs: True
    - user: syslog
    - group: adm
    - dir_mode: 755
    - file_mode: 644
    - recurse:
      - user
      - group
      - mode

sched_perms:
  schedule.present:
    - function: fixperms.sls
    - seconds: 60
