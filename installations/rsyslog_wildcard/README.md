Configurations source:  
https://stackoverflow.com/questions/53012208/how-to-save-files-found-with-wildcard-file-folder-to-the-right-file-name-on-th/53048017#53048017  

Other sources:  
https://github.com/rsyslog/rsyslog-doc/issues/474  
https://selivan.github.io/2017/02/07/rsyslog-log-forward-save-filename-handle-multi-line-failover.html  

These are original configurations by stackoverflow user "Rumbles", with modifications on log gathering source.

These configurations are to be edited heavile to better suit our needs.

Default file tree for client logs:  
![default](https://raw.githubusercontent.com/jisosomppi/log-analysis/master/images/orginalformattree.png)

What we want would look something like

```
/var/log/
      client_logs/
                xubuntu-1.2.3.4/
                              apache2/
                                    access.log
                                    error.log
                              apt/
                                    history.log
                                    term.log
                              auth.log
                              ..and so on...
```                              
