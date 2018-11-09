apache2-utils:
  pkg.installed

nginx:
  pkg.installed
    
/etc/nginx/sites-available/default:
  file.managed:
    - source: salt://nginx/default_nossl
    - template: jinja
    - context:
      server_name: {{salt['network.interface_ip']('eno1')}} 
##    server_name: logserver.local

nginx.service:
  service.running:
    - name: nginx
    - watch:
      - file: /etc/nginx/sites-available/default
