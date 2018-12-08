# Meeting notes, log analysis project
This file contains notes of meetings held between the project group and our supervisor. We log all agreed upon matters as well as ideas and propositions.

## Project organisation
Name|Position
----|--------
Tero Karvinen|Supervisor
Jussi Isosomppi|Team member
Eino Kupias|Team member
Saku Kähäri|Team member

## Progress review, 26.09.18
*Present: everyone*

**We updated our supervisor on the current status of our project:**
* We have built a few different versions of our setup
  * The only fully working iteration was ELK Stack in Docker containers + Beats collecting data
  * At best, other setups had problems with sending data from Rsyslog to Elasticsearch
* We're currently working on separate parts of the project, as opposed to the earlier joint approach
* We're slightly behind on our working hour target

**Agreed next steps:**
* Packet capture to find correct syntax from data sent from Beats
* Better notekeeping, all in-progress notes as well as personal notes in the same repository
* Share all in-progress tasks with other group members
* Research ways to make connections more secure

## Progress review, 05.12.18
*Present: everyone*

**Showed a short demo of the system to our supervisor:**
* Salt state used to configure almost all parts of the system
* Encryption between clients and server implemented using CA certificates with two-way trust

**Agreed next steps:**
* Freezing the project
* Working on documentation
