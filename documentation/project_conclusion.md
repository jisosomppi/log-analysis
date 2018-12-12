## Project conclusion ##  

### What we set out to do ###  
Our aim with this project was to create a centralized logging solution, with ease of use and data security in mind. Our solution was to rely on Saltstack for centralized management, and on encryption and SSL/TLS certificates for data security. We also aimed to write scripts to make the setup process easy and consistent, so that each installation would lead to the same end result.
 
 
### Project results ###  
The project outcome was an automated setup script for log server and clients, utilizing Salt. We achieved all of out original main goals and more.
- We passed log data from multiple clients to a server.
  - All clients distinguishable from each other.
- We configured firewall to only allow traffic to the programs that require it and only from the authorized network.
- We utilized both SSL/TLS encryption and basic http authentication.
- We made installation and setup scripts for automating the whole process with very little user input required.
- Most of the configuration is managed using Salt states.
  - Salt is used to achieve idempotency. This means that the same end result is always achieved, when the setup is ran.
- We used the open source version of the ELK stack, and replaced several parts that weren't open source.
  - Replaced parts include: X-pack (ElasticSearch module) and Beats (Data shippers) 

### Room to improve ###  
The project version was frozen on week 15. We had few more things under construction, that unfortunately did not make it into our latest version. These features include:  
- Importing the root certificate to Firefox automatically. In the current build, this has to be done manually through a few clicks.
- Importing dashboards to Kibana automatically. Currently, when you load the Kibana main page, you have to manually import the premade dashboard.
- Generating keypairs for more than 1 client through Salt module.
- Automated identification for new log files to forward. Only those log files specified on salt rsyslog conf are forwarded, and to add more log gathering locations, one would have to add them to salt rsyslog configuration (imfile action).


### Thoughts ###  
Centralized management with Salt ate a lot of working hours towards the end of this project. Only Jussi was adept with it and and sometimes it also required other group members to go trough together how aspects of the project worked in order to automate them.

Using Salt was time consuming, but it also saved us a ton of effort once it was working to a certain degree. It was also a good learning opportunity for the rest of our group (As Jussi was the only one of us, who had prior experience), since we had only used Puppet before this project. 

We are very content with our end results. We missed some of our early goals, but came up with additional features, that we never thought about earlier. We created the encryption setup with Certificate Authority -generated certificates and keys, and therefore ended up with quite a "professional" end result. Our Salt states and structures are handmade, even though readily made solutions would have been available.

Our process during the course seemed very natural, as we kept working partly independently on our own topics, but also tightly as a group while working on more complex parts of the overall solution.

### Merits ###
- Our project was tested by around 20 outside users
- We put in a lot of effort to ensure, that our whole project was built on open source components. This lead us to abandon and ignore some solutions, that would've made our work significantly faster and easier.
  - In the start of the project, we read that Beats (ElasticSearch plugins) are under Elastic Licence and could not be used. This meant that we had to start working on Rsyslog. On the same week that the project was frozen, we found out there has been an open source version of different Beats.
- We traded some planned goals for additional security (basic HTTP authentication, HTTPS)




