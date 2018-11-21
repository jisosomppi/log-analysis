firefox:
  pkg.installed
  
/etc/firefox/default...:
  file.managed:
    - source: salt://firefox/...
    ## GLOBAL CONF TÄHÄN ##
  
~/.mozilla/firefox/??...??.default/prefs.js:
  file.managed:
    - source: salt://firefox/prefs.js
    - content: 
    ## KÄYTTÄJÄ CONF TÄHÄN ##
    ## kotisivut: git + logserver ##
    
~/.mozilla/firefox/??...??.default/database:
  file.managed:
    - source: salt://firefox/database
    - content:
    ## MUOKATTU CERT-DB TÄHÄN ##
