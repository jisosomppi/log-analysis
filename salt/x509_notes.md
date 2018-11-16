# Setting up an x509 Certificate Authority with Salt

Reference: 
* https://gist.github.com/fm-jason/c2bf2b986cb47a234f81cfce8e0892de
* https://docs.saltstack.com/en/latest/ref/states/all/salt.states.x509.html
* https://www.rsyslog.com/doc/v8-stable/tutorials/tls.html
* http://virtuallyhyper.com/2013/04/setup-your-own-certificate-authority-ca-on-linux-and-use-it-in-a-windows-environment/
* https://deliciousbrains.com/ssl-certificate-authority-for-local-https-development/
* Also referencing [Eino's research notes](https://github.com/jisosomppi/log-analysis/blob/master/installations/tls/working-conf-with-certs.md) for the actual setup

## The need
We're trying to set up Rsyslog authentication between clients using x509 certificates. Since we're already using Salt, we could maybe use it to generate and distribute the keys securely.

## Benefits
* Creating the certificates automatically
* Distributing the keys via the Salt pillar, securely
* Creating 
* Getting rid of certificate warnings while browsing Kibana (maybe?)
  * (would require pre-installed root certificate on Firefox, at least)
