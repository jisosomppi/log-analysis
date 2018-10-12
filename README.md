# Logging and analysis of security data in a network
***Multidisciplinary Software Project, fall 2018***  
***Haaga-Helia University of Applied Sciences***  
*[Jussi Isosomppi](https://github.com/jisosomppi), [Eino Kupias](https://github.com/einokupias), [Saku Kähäri](https://github.com/nauskis)*

Our goal for this project is to create a solution that analyzes multiple kinds of data sent from multiple devices to a centralized server. The server processes, filters and stores the data in a form that is suitable for further analysis using graphical tools such as Kibana or Grafana. This solution should be suitable for use in small to medium companies, being sophisticated enough to offer valuable data while still being clear enough to also be usable for others than system administrators. 

Part of the tools and methods we're planning to use to achieve these goals are:
* Using a centralized management solution (such as Salt) to ensure all workstations and others devices have the correct software setup for reporting
* Using graphical tools (Kibana, Grafana) to allow data to avoid handling data in the CLI
* Using open source code to ensure availability and low-to-zero cost for the solution

## Milestones
1. Setting up a logging server and passing data to it from one client  
2. Passing data from several (distinguishable) clients  
3. Automating client setup via Salt  
* Extra: Setting up a router to send log data  
* Extra: Replacing Logstash with syslog to reduce resource use

## Tools
* ELK stack  
* Grafana: Setting up a simple dashboard for preset data
* Salt: Automating client setup
* Docker: For quick testing and failing
  * Portainer: For easier control over Docker containers

## Project diary
### Week 1
We installed ELK Stack succesfully through docker, and managed to pass data from the host computer to ElasticSearch running inside the container. This data was sent with MetricBeat and viewed through Kibana's GUI.

### Week 2
We formed our project plan, and created other required documents for the course. We created scripts to automate installation of services, hopefully reducing downtime in the coming weeks. 

On the technical side: we tested the setup scripts and got them to work. We passed data from a few different beats to ElasticSearch and managed to get some nice visualizations with Kibana.

![Image1](https://github.com/jisosomppi/log-analysis/blob/master/images/Screenshot_2018-08-31_15-19-31.png)

### Week 3
#### Monday
We started researching the use of purely open source components, replacing the Beats and Logstash with rsyslog. Rsyslog can be configured to run as both a client and a server, and accepts configuration files to shape the log outputs into a form that is readable in Elasticsearch. We had some progress with setting up rsyslog, but didn't yet manage to display results in Elasticsearch/Kibana.

#### Wednesday
We were assigned a server from Servula and started setting it up for use. We decided to use Ubuntu Server 18.04.1 LTS, as the LTS gave us confidence it would be supported. We started immediately running into issues with the OS installation:
* Hostname would change into `localhost.localdomain` with the first startup
* User account created during install could not be used to log in  

We managed to gain access to the system by booting it into single user mode (Hold ESC after BIOS and add `single` to launch parameters. From the root shell we could identify some problems:
* No network connectivity (despite setting it up succesfully during install)
* No user account present
* Network interface settings missing (/etc/network/interfaces empty, ifconfig only showing loopback)
* No SSH access for any users, even from the same system. Turns out `root` owns all SSL keyfiles.

Some solutions to our problems:
* Creating user account again from within the single user root shell
* Ubuntu 18.04 uses Netplan to configure interfaces, so we needed to write a `.yaml` file for the default interface. This _should_ have been generated with the install but for some reason the `/etc/netplan` folder was completely empty.
``` yaml
network:
 version: 2
 renderer: networkd
 ethernets:
   eno1:
     dhcp4: yes
     dhcp6: yes
```
This file and `sudo netplan apply` gave us internet connectivity.


We configured a client computer and sent identifiable log data to server via Rsyslog. Next we find out how to pass log data from Rsyslog to ElasticSearch and Kibana.

#### Friday
We started our server setup from scratch, this time with Ubuntu Server 16.04 (problem-free install!). We setup the basics for the computer (accounts, security, remote access) and began configuring our stack for use. We started with Docker containers, but ran into some issues with forwarding traffic from Rsyslog clients to the Elasticsearch backend. We moved to locally installed versions of Elasticsearch and Kibana, to make the testing of configurations easier. 

We spent a couple of hours building our configuration files, but did not have success in making the data available on Kibana. However, we managed to get our log forwarding to work on clients. Our clients are now sending select log entries to our Rsyslog server, where the entries are grouped under a comprehensive folder structure. We managed to input monitoring data from the server into Elasticsearch, and were able to view graphs of it on Kibana.

At this point in the project, Kibana and Elasticsearch seem to be functioning properly, while Rsyslog has currently unidentified issues. 

### Week 4
#### Monday
More work on the logging setup. Rsyslog is still causing trouble, not forwarding logs like it should. We spent hours reading guides and documentation, but had no luck making the information accessible.

On the upside: service monitoring works! We enabled monitoring services in both Elasticsearch and Kibana, and we can now view data on amount of queries processed, response times etc.

#### Wednesday
Project presentations.

#### Thursday
We rebuilt the logging server. Due to numerous issues with our previous setup, we decided to start with a clean slate. A fresh install of Ubuntu Server 16.04.5 and our necessary components solved most of our issues, which were likely caused by tired tinkering of system settings and file/directory permissions.

### Week 5
#### Monday
We did indeed generate more log data over the weekend, however our Rsyslog settings seemed to be a bit off. the `/var/log/client_logs` folder was over 200Gb in size, while other files in `/var/log/` (all 80Gb+ of it) were affected too. It seems our problem is handling input and output on the same machine, with Rsyslog forwarding each incoming message to itself in an infinite loop. All of this data exists, despite the fact we had enabled rate limitation, which seemed to work as planned (confirmed by log messages of tens of thousands of messages being blocked by rate limitations).

Here are the clearly affected files in `/var/log`:
```
jussi@logmaster:/var/log$ ls -lah
total 83G
-rw-r-----  1 syslog        adm           9.2G Sep 17 12:36 auth.log
-rw-r-----  1 syslog        adm            15G Sep 16 06:38 auth.log.1
-rw-r-----  1 syslog        adm           732M Sep 17 12:11 kern.log
-rw-r-----  1 syslog        adm           932M Sep 16 06:38 kern.log.1
-rw-r-----  1 syslog        adm            12G Sep 17 12:36 syslog
-rw-r-----  1 syslog        adm            45G Sep 17 06:33 syslog.1
-rw-r-----  1 syslog        adm           506M Sep 16 06:38 syslog.2.gz
-rw-r-----  1 syslog        adm           844M Sep 15 06:25 syslog.3.gz
```

Changing back to our earlier setup (with Docker containers running the ELK components) and sending data with FileBeat resulted in a working setup. In our minds, this confirms that our problems lie within Rsyslogs configuration. 
#### Wednesday
We started work on our own sub-projects, dividing our research and workload into different builds. The builds aim to reach the same end result with different setups. The builds can be found in their own folder.
### Week 6
We continued work on the builds
### Week 7
Breakthrough! Combining previous config files and a crucial new piece of information, we got our Rsyslog clients sending data directly to the Elasticsearch server! Of course, this isn't the ideal setup (thanks to weak security), but the satisfaction of seeing Rsyslog messages on Kibana was immense!

The critical piece we missed was adding `*.*  ` to our `elasticsearch.conf` file (used to define Rsyslog's ouput to Elasticsearch). We found this error by analyzing outbound traffic from an Rsyslog client with Wireshark. This revealed that despite an error-free debug check of Rsyslog, no data was leaving the client system. `*.*  ` was added to the "action" part of the configuration, which defines which logs should be affected by the action. This addition was not documented in any of our third-party source materials, and was a discovery from a few different official documents from Rsyslog.

Next steps for this configuration:
* Changing the dataflow to utilize a centralized Rsyslog server
  * Reduces security risks
  * Saves logs in case of incidents
* Securing the log data between client and server
* Moving Elasticsearch and Kibana out of Docker containers

In our minds, this solved the single biggest problem we had with the project, getting Rsyslog to talk to Elasticsearch.
### Week 8
Work on builds continued. We're working on implementing certificates in our Rsyslog client-server communication. 

#### Removing X-pack  
X-pack is usually bundled with Elasticsearch and Kibana and uses Elastic license. Thus, we should remove it from our solution and replace it with Search Guard (for now).  

https://www.elastic.co/guide/en/x-pack/current/xpack-uninstalling.html  

#### Working build
**The most complete build is currently [RELK-physical](https://github.com/jisosomppi/log-analysis/tree/master/builds/rek-physical).**

The build has no authentication, but does store the log files in both local folders (on the server) and in Logstash/Elasticsearch. In its current form, the build works from start to finish accurately.
