# Tietoturvalokien analysointi
***Haaga-Helian monialaprojekti syksyllä 2018***  
*Jussi Isosomppi, Eino Kupias, Saku Kähäri*

Projektin tavoitteena on luoda keskitetty ratkaisu, joka analysoi verkossa olevien laitteiden lokitietoja keskitetysti, ja pyrkii tunnistamaan niistä tietoturvauhkia. Lokitiedot toimitetaan työasemilta ja/tai muilta laitteilta palvelimelle, jossa suoritetaan niiden käsittely, analysointi ja suodatus.  
Lopputuloksena haetaan palvelua, jonka kautta PK-yrityksen henkiökunta saisi helposti ja selkeästi kuvan yrityksen tietoturvatilanteesta. Tämä edellyttää helppoa käyttöönottoa (Salt) ja ylläpitoa (Elkstack), sekä tietojen helppolukuisuutta (Grafana?).

### Milestonet
1. Lokipalvelimen käyttöönotto ja testaus yhdellä clientilla  
2. Asennuksen automatisointi Saltilla  
3. Useiden yhtäaikaisten järjestelmien toiminta  
* Bonus: Reitittimen konfigurointi toimittamaan lokeja  
* Bonus: Korvataan Logstash syslogilla (kevyempi)  

# Työkaluja
* ELK stack  
* Grafana: Lokitietojen visualisointi eri näkymään
* Salt: Työasemien asetusten automatisointi


# Luettavana
ELK stackista:  
https://app.logz.io/#/dashboard/data-sources/rsyslog  
https://logz.io/learn/complete-guide-elk-stack/#installing-elk
