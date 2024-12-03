# winserv

```
Set-ExecutionPolicy Unrestricted
```


initialduprenom.nom
sinon, 
initialduprenom.initialnom

concaténer les noms composés

si doublon, demander à l'utilisateur

quotas : limites hard

on ne renomme pas le site par défaut, on en crée d'autres

bien comprendre la réplication, pq la replication entre les domain controllers

DC : RW partout sauf pour emulateur pdc(réglere l'horloge de tt le monde), DNM(domain naming master, qui attribue les noms de domaine), RID master(depend du SID=DID+RID), IM (infrastructure master, un utilisateur change de domaine, donc comme le rid change, le did doit être mis à jour), SM (maitre de schéma, toutes les classes de tous les objets qu'on va créer dans l'AD et il faut savoir où ils sont)

GC global catalog : annuaire qui reprend tous les objets de l'AD, 



pour le sprint review, présentation de manière positive et préparée. Chaque personne doit interagir

si commun (general), tt le monde a acces en lecture mais l'utilisateur ne peut pas créer dans le dossier

premier sprint review : jeudi matin 11h



* Nom du serveur : ad-server-07
* Nom du domaine : belgique.lan
* Nom de la forêt : belgique.lan
* Nom du site dans lequel ce DC se trouve : bxl-site
* Configuration IPv4 : 
  * IPv4/Mask :
  * Passerelle :
  * DNS :
