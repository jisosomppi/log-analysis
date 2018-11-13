/etc/hosts:
  file.managed:
    - source: salt://etchosts/hosts
    - template: jinja
    - context:
      hostname: {{grains['localhost']}}
      {% if grains['master'] == 'localhost' %}
      logserver: 127.0.0.1
      {% else %}
      logserver: {{grains['master']}}
      {% endif %}
