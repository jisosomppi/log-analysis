## THIS IS A CENTRALLY MANAGED FILE! ##
## CHANGES WILL BE OVERWRITTEN ##

ufw:
  pkg.installed
     
/etc/ufw/user.rules:
  file.managed:
    - source: salt://ufw/user.rules
    - template: jinja

ufw.service:
  service.running:
    - name: ufw
    - watch:
      - file: /etc/ufw/user.rules
