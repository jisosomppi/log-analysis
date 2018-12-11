## Project conclusion ##  

**What we set out to do**  
Our aim with this project was to create a centralized logging solution, with ease of use and data security in mind. Our solution was to rely on Saltstack for centralized management, and on encryption and SSL/TLS certificates for data security. We also aimed to write scripts to make the setup process easy and consistent, so that each installation would lead to the same end result.
 
 
**Project results**  
The project outcome was an automated setup script for log server and clients, utilizing Salt. We achieved all of out original main goals and more.
- We passed log data from multiple clients to a server.
  - All clients distinguishable from each other.
- We configured firewall to only allow traffic to the programs that require it and only from the authorized network.
- We utilized both SSL/TLS encryption and basic http authentication.
- We made installation and setup scripts for automating the whole process with very little user input required.
- Most of the configuration is managed using Salt states.
  - Salt is used to achieve idempotency. This means that the same end result is always achieved, when the setup is ran.

### Room to improve ###  
The project version was frozen on week 15. We had few more things under construction that unfortunately did not make it into our latest version. These features include:  
- Importing self-signed certificates to Firefox automatically. In the current build, this has to be done manually through few clicks.
- Importing dashboards to Kibana automatically. Currently, when you load the Kibana main page, you have no dashboards to show until you make some.
- Generating keypairs for more than 1 client trough salt module.
- Automated identification for new log files to forward. Only those log files specified on salt rsyslog conf are forwarded, and to add more log gathering locations, one would have to add them to salt rsyslog configuration (imfile action).

### Thoughts ###  
