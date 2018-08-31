# Logging and analysis of security data in a network
***Multidisciplinary Software Project, fall 2018***  
***Haaga-Helia University of Applied Sciences***  
*[Jussi Isosomppi](https://github.com/jisosomppi), [Eino Kupias](https://github.com/einokupias), [Saku Kähäri](https://github.com/nauskis)*

Our goal for this project is to create a solution that analyzes multiple kinds of data sent from multiple devices to a centralized server. The server processes, filters and stores the data in a form that is suitable for further analysis using graphical tools such as Kibana or Grafana. This solution should be suitable for use in small to medium companies, being sophisticated enough to offer valuable data while still being clear enough to also be usable for others than system administrators. 

Part of the tools and methods we're planning to use to achieve these goals are:
* Using a centralized management solution (such as Salt) to ensure all workstations and others devices have the correct software setup for reporting
* Using graphical tools (Kibana, Grafana) to allow data to avoid handling data in the CLI
* Using open source code to ensure availability and low-to-zero cost for the solution

## Existing solutions
### ELK Stack

## Milestones
1. Setting up a logging server and passing data to it from one client  
2. Passing data from several (distinguishable) clients  
3. Automating client setup via Salt  
* Extra: Setting up a router to send log data  
* Extra: Replacing Logstash with syslog to reduce resource use
  * Possible logstash alternative: https://www.elastic.co/blog/logstash-forwarder-0-4-0-released


### Tools
* ELK stack  
* Grafana: Setting up a simple dashboard for preset data
* Salt: Automating client setup
* Docker: For quick testing and failing
  * Portainer: For easier control over Docker containers

### Week 1
We installed ELK Stack succesfully through docker, and managed to pass data from the host computer to ElasticSearch running inside the container. This data was sent with MetricBeat and viewed through Kibana's GUI.

### Week 2
We formed our project plan, and created other required documents for the course. We created scripts to automate installation of services, hopefully reducing downtime in the coming weeks. 
