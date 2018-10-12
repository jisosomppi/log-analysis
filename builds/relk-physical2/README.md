# RELK-physical

This build is a second version of the physical stack, and attempts were made to make it work both with Logstash and without.
The configuration is non-functional, but stored for possible future use.

Techniques, changes, etc
* rsyslog.conf
  * actions rewritten into new syntax
  * all configuration consolidated into one file
* logstash.conf
  * elasticsearch output defined
