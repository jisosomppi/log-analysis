Server Public Cert:
  file.managed:
    - name: /etc/ssl/private/{{ pillar['ssl']['cert']['filename'] }}
    - user: {{ pillar['ssl']['user'] }}
    - group: {{ pillar['ssl']['group'] }}
    - mode: {{ pillar['ssl']['cert']['mode'] }}
    - contents_pillar: ssl:cert:contents

Server Private Key:
  file.managed:
    - name: /etc/ssl/private/{{ pillar['ssl']['key']['filename'] }}
    - user: {{ pillar['ssl']['user'] }}
    - group: {{ pillar['ssl']['group'] }}
    - mode: {{ pillar['ssl']['key']['mode'] }}
    - contents_pillar: ssl:key:contents

/etc/ssl/private/current.crt:
  file.symlink:
    - target: {{ pillar['ssl']['cert']['filename'] }}
    - watch:
      - file: Server Public Cert

/etc/ssl/private/current.key:
  file.symlink:
    - target: {{ pillar['ssl']['key']['filename'] }}
    - watch:
      - file: Server Private Key

{% for svc in pillar['ssl']['services'] %}
Restart SSL service {{svc}}:
  service.running:
    - name: {{svc}}
    - enable: True
    - full_restart: true
    - watch:
      - file: /etc/ssl/private/current.key
      - file: /etc/ssl/private/current.crt
      - file: Server Public Cert
      - file: Server Private Key
{% endfor %}
