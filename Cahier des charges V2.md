# Cahier des charges :

texte en italique = optionnel si le temps nous permet

## Contraintes

- 1 switch physique, 2 postes client
- 4 VMs (1 Windows Server, 1 Serveur Linux MQTT, 1 serveur BDD)
- Service informatique sécurisé et redondant 

## Réseaux :

- Plan IP réseaux complet
- Configuration routeurs/switch
- Création/acces VLANS
- OSPF
- DHCP/DNS (Windows Server)
- AD, utilisateurs avec droits selon status (chirugiens, infirmières...)
- Partages NFS selon status utilsateurs
- BDD médicale (dont une à proteger)
- Liste de données sensible
- Tableau de patient
- Radius ?
- *Téléphonie Xlite*
- *Acces fibre*
- *Logiciel Supervision*
- *Roaming*

### Partie FW

- Acces internet (portail captif IUT)
- portail Stormshield LDAP (avec création users/droits)
- Acces sites internet sans passer par le portail
- Bloquer certain sites
  
## Cyber :

- VRRP
- VPN (se concentrer sur un échange précis)
- Pentest
- Prévoir possibles attques (au moins 1 vulnérabilité) et contre mesures (+ verif bon fonctionnent contre mesures)
- Systeme de détection, message d'alerte (Sur FW ?)


## IOM :

- Configuration borne wifi
- Serveur MQTT
- Sécurisation MQTTS
- Programme capteur RFID
- Nodered (logique après lecture RFID)

## PILPRO :

- cahier des charges
- Trello (évolutif)
- Gant (évolutif)
- Contact DSI hopital
- Cahier financier (budget global, cyber, iom, infra ect...) 
- Contact entreprise (réel ou fictive)
- Diagram
- Plan 

