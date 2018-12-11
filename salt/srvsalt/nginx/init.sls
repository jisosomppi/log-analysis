apache2-utils:
  pkg.installed

nginx:
  pkg.installed
    
/etc/nginx/sites-available/default:
  file.managed:
    - source: salt://nginx/default
    - template: jinja
    - context:
      server_ip: {{ salt['grains.get']('ip4_interfaces:{{pillar.get('client_interface','eno1')}}')[0] }}
      nginx_port: {{pillar.get('nginx_port','80')}}
      kibana_ip: {{pillar.get('kibana_ip','localhost')}}
      kibana_port: {{pillar.get('kibana_port','5601')}}
      ssl_port: {{pillar.get('ssl_port','443')}}

/etc/nginx/snippets/logserver.local.conf:
  file.managed:
    - source: salt://nginx/snippets/logserver.local.conf

/etc/nginx/snippets/ssl-params.conf:
  file.managed:
    - source: salt://nginx/snippets/ssl-params.conf

nginx.service:
  service.running:
    - name: nginx
    - watch:
      - file: /etc/nginx/sites-available/default
      - file: /etc/nginx/snippets/logserver.local.conf
      - file: /etc/nginx/snippets/ssl-params.conf
