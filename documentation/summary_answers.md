## 1. Projektin kuvaus
>Kopioikaa tähän projektisuunnitelmasta projektin tehtävä, tavoite ja odotettavat tulokset.
### Project background
The subject of our ICT infrastructure project is the collection and analysis of log data in a local network. The goal is to automate and centralize control, and to create a comprehensive view of security for basic-level users. 

Our purpose is to create a complete product, that utilizes the Elastic software stack, aimed in its free form at small and medium sized companies. Additionally, the installation and usage of our solution should be easy and effortless.

### Project goals 
1) Log data collection, control ja analysis in a small network.  
2) Encrypted traffic between clients and host.
3) Recognition of exceptions and anomalies in the data.  
4) Representing data in easily understandable form.  

By using the school's lab network, we can simulate a normal working enviroment. On a personal level, our aim is to learn to identify relevant log data and get familiar with the tools we're using.  
Our project requires requires strict scheduling and documentation. The latter of which is achieved by uploading everything to Github. Our team is slightly smaller than what we're used to, and this will bring it's own advantages and challenges.

## 2. Projektin tulokset
>Esittäkää projektin aikaansaama tulos kokonaisuutena. Esittäkää mahdolliset projektin päätyttyä myöhemmin toteutettaviksi siirtyvät toimenpiteet sekä mahdolliset jatkokehittämiseen liittyvät toimenpiteet.

### Project results
The project outcome was an automated setup script for log server and clients, utilizing Salt. We achieved all of out original main goals and more.
- We passed log data from multiple clients to a server.
  - All clients distinguishable from each other.
- We configured firewall to only allow traffic to the progrhttps://github.com/jisosomppi/log-analysis/blob/master/documentation/project_conclusion.mdams that require it and only from the authorized network.
- We utilized both SSL/TLS encryption and basic http authentication.
- We made installation and setup scripts for automating the whole process with very little user input required.
- Most of the configuration is managed using Salt states.
  - Salt is used to achieve idempotency. This means that the same end result is always achieved, when the setup is ran.
- We used the open source version of the ELK stack, and replaced several parts that weren't open source.
  - Replaced parts include: X-pack (ElasticSearch module) and Beats (Data shippers) 

### Room to improve
The project version was frozen on week 15. We had few more things under construction, that unfortunately did not make it into our latest version. These features include:  
- Importing self-signed certificates to Firefox automatically. In the current build, this has to be done manually through few clicks.
- Importing dashboards to Kibana automatically. Currently, when you load the Kibana main page, you have no dashboards to show until you make some.
- Generating keypairs for more than 1 client trough salt module.
- Automated identification for new log files to forward. Only those log files specified on salt rsyslog conf are forwarded, and to add more log gathering locations, one would have to add them to salt rsyslog configuration (imfile action).

## 3. Projektin onnistuminen & kokemukset
>Laatikaa lyhyt yhteenveto projektin kulusta. Analysoikaa projektille suunniteltua tehtävää suhteessa toteutuneeseen. Kuvatkaa projektin tulosten saavuttamista suhteessa suunniteltuun.
>Kerätkää tähän kokemukset, joista arvelette olevan hyötyä tulevissa projekteissa. Verratkaa opittua projektisuunnitelmassa asetettuihin tavoitteisiin.

### Thoughts
Centralized management with Salt ate a lot of working hours towards the end of this project. Only Jussi was adept with it and and sometimes it also required other group members to go trough together how aspects of the project worked in order to automate them.

Using Salt was time consuming, but it also saved us a ton of effort once it was working to a certain degree. It was also a good learning opportunity for the rest of our group (As Jussi was the only one of us, who had prior experience), since we had only used Puppet before this project. 

We are very content with our end results. We missed some of our early goals, but came up with additional features, that we never thought about earlier. We created the encryption setup with Certificate Authority -generated certificates and keys, and therefore ended up with quite a "professional" end result. Our Salt states and structures are handmade, even though readily made solutions would have been available.

Our process during the course seemed very natural, as we kept working partly independently on our own topics, but also tightly as a group while working on more complex parts of the overall solution.


4. Projektiryhmän suoriutuminen
* Kuvatkaa projektiryhmän jäsenten roolia ja tehtäviä projektissa sekä raportoikaa projektiin käytetyt työtunnit 
```
Nimi  
Tehtävät ja vastuut projektissa  
Projektityötunnit  
```
* Nostakaa myös esille tilanteet, joilla oli vaikutusta projektin toteutukseen, esimerkiksi päätökset, lisäkoulutustarpeet, resurssien saatavuus sekä merkitys. 
Kuvailkaa kommunikaation merkitystä projektiryhmän työssä.
