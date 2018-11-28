firefox:
  pkg.installed

~/localCA.crt:
  file.managed:
    - source: salt://firefox/localCA.crt

~/.mozilla/firefox/*.default/user.js:
  file.managed:
    source: salt://firefox/user.js
    
