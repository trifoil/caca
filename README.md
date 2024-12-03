# winserv


initialduprenom.nom
sinon, 
initialduprenom.initialnom

concaténer les noms composés

quotas : limites hard

on ne renomme pas le site par défaut, on en crée d'autres

bien comprendre la réplication, pq la replication entre les domain controllers

DC : RW partout sauf pour emulateur pdc(réglere l'horloge de tt le monde), DNM(domain naming master, qui attribue les noms de domaine), RID master(depend du SID=DID+RID), IM (infrastructure master, un utilisateur change de domaine, donc comme le rid change, le did doit être mis à jour), SM (maitre de schéma, toutes les classes de tous les objets qu'on va créer dans l'AD et il faut savoir où ils sont)

GC global catalog : annuaire qui reprend tous les objets de l'AD, 
