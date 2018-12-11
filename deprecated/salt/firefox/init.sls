## Non-functional

firefox:
  pkg.installed

~/localCA.crt:
  file.managed:
    - source: salt://firefox/localCA.crt

## Needs logic to target randomly named profile folder
~/.mozilla/firefox/*.default/user.js:
  file.managed:
    source: salt://firefox/user.js
    
