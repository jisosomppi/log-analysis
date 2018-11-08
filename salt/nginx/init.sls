apache2-utils:
  pkg.installed

nginx:
  pkg.installed
    
/etc/nginx/sites-available/default:
  file.managed:
    - source: salt://nginx/default
    - template: jinja
    - context:
      server_ip: 172.28.171.138
## server_ip: grains['ipv4 interfaces'](eno1)   
    
nginx.service:
  service.running:
    - name: nginx
    - watch:
      - file: /etc/nginx/sites-available/default
      
