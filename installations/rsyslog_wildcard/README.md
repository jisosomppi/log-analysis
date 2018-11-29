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
After modifying

```
template(name="FloowLogSavePath" type="list") {
    constant(value="/srv/rsyslog/")
    property(name="timegenerated" dateFormat="year")
    constant(value="/")
    property(name="hostname")
    constant(value="/")
    property(name="timegenerated" dateFormat="month")
    constant(value="/")
    property(name="timegenerated" dateFormat="day")
    constant(value="/")
    property(name=".logpath")
}
```  
to  
```
template(name="FloowLogSavePath" type="list") {
    constant(value="/srv/rsyslog/")
    property(name="hostname")
    constant(value="-")
    property(name="fromhost-ip")
    constant(value="/")
    property(name=".logpath")
}
```
I got the wanted folder format  
![kuveke](https://raw.githubusercontent.com/jisosomppi/log-analysis/master/images/kuveke.png)  
though this requires much more research and digging in order to be included to the final product. 
