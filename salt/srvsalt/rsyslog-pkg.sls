rsyslog-pkg:
  pkgrepo.managed:
    - humanname: Rsyslog Repository
    - name: deb http://ppa.launchpad.net/adiscon/v8-stable/ubuntu xenial main
    - dist: xenial main
    - file: /etc/apt/sources.list.d/adiscon-ubuntu-v8-stable-xenial.list
    - keyserver: keys.gnupg.net
    - keyid: AEF0CF8E
    - require_in:
      - rsyslog-client
      - rsyslog-server
