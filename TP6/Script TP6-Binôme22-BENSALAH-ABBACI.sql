/*
  Script TP 6
  Réalisé en binome par: BENSALAH Kawthar / ABBACI Khaled
  Numéro du Binome : 22
  Master 2 IL - Groupe 1
  USTHB 2019/2020
*/

/*Réponse 1*/
/*Activation des options autotrace et timing de oracle*/
set timing on;
set autotrace on explain;

/*Vider les buffers*/
alter system flush shared_pool;
alter system flush buffer_cache;

 /*Ecriture et exécution de la requête R1 qui donne le nombre d'opérations réalisées dans les agences de la wilaya d’Alger*/ 
select DA.CodeWilaya, 
        sum(FO.NbOperationR+FO.NbOperationV)
        as NbOperation
  from FOperation FO, DAgence DA
 where FO.NumAgence = DA.NumAgence
 and DA.CodeWilaya = 16
 group by DA.CodeWilaya;

/*Réponse 2*/
/*Création de la vue matérialisée VMWilaya*/
CREATE MATERIALIZED VIEW VMWilaya
    BUILD IMMEDIATE REFRESH COMPLETE ON DEMAND
    enable query rewrite
    AS select DA.CodeWilaya, DA.NomWilaya, 
                sum(FO.NbOperationR+FO.NbOperationV) as NbOperation
       from DAgence DA, FOperation FO
      where FO.NumAgence = DA.NumAgence
      group by DA.CodeWilaya, DA.NomWilaya
      order by DA.CodeWilaya;

/*Réponse 3*/
/*Vider les buffers*/
alter system flush shared_pool;
alter system flush buffer_cache;

 /*Réexécution de la requête R1*/ 
select DA.CodeWilaya, 
        sum(FO.NbOperationR+FO.NbOperationV)
        as NbOperation
  from FOperation FO, DAgence DA
 where FO.NumAgence = DA.NumAgence
 and DA.CodeWilaya = 16
 group by DA.CodeWilaya;

 /*Création de la vue matérialisée VMMontantVMensuel*/

CREATE MATERIALIZED VIEW VMMontantVMensuel
    BUILD IMMEDIATE REFRESH COMPLETE ON DEMAND
    enable query rewrite
    AS select DT.Mois, 
            sum(FO.MontantV) as MVMensuel
       from DTemps DT, FOperation FO
      where FO.CodeTemps = DT.CodeTemps
      group by DT.Mois
      order by DT.Mois;


/*Ecriture et Exécution de la requête R2*/
alter system flush shared_pool;
alter system flush buffer_cache;

select DT.Année, 
        sum(FO.MontantV) as MVAnnuel
from DTemps DT, FOperation FO
where FO.CodeTemps = DT.CodeTemps
group by DT.Année
order by DT.Année;

/*Création des méta données de toutes les dimensions*/
create dimension DIMTemps 
level NTemps1 is (DTemps.CodeTemps)
level NTemps2 is (DTemps.Mois)
level NTemps3 is (DTemps.Année)
hierarchy HTemps1 (NTemps1 child of NTemps2 child of NTemps3)
attribute NTemps1 determines (DTemps.Jour, DTemps.LibJour)
attribute NTemps2 determines (DTemps.LibMois)
;


create dimension DIMAgence
LEVEL NAgence1 IS DAgence.NumAgence
LEVEL NAgence2 IS DAgence.CodeBanque
LEVEL NAgence3 IS DAgence.CodeVille
LEVEL NAgence4 IS DAgence.CodeWilaya
HIERARCHY HAgence1(NAgence1 child of NAgence2 CHILD OF NAgence3  CHILD OF NAgence4)
ATTRIBUTE NAgence1 DETERMINES DAgence.NomAgence
ATTRIBUTE NAgence2 DETERMINES DAgence.NomBanque
ATTRIBUTE NAgence3 DETERMINES DAgence.NomVille
ATTRIBUTE NAgence4 DETERMINES DAgence.NomWilaya;


create dimension DIMClient
LEVEL NClient1 IS DClient.NumClient
ATTRIBUTE NClient1 determines (DClient.NomClient, DClient.DNClient);


create dimension DIMTypeCompte 
level NTypeCompte1 is (DTypeCompte.CodeType)
attribute NTypeCompte1 determines (DTypeCompte.LibType);

Alter session set query_rewrite_integrity = trusted;


/*Réexécution de la requête R2*/
alter system flush shared_pool;
alter system flush buffer_cache;

select DT.Année, 
        sum(FO.MontantV) as MVAnnuel
from DTemps DT, FOperation FO
where FO.CodeTemps = DT.CodeTemps
group by DT.Année
order by DT.Année;

/*Création de la vue matérialisée VMMontantVVille*/
CREATE MATERIALIZED VIEW VMMontantVVille
    BUILD IMMEDIATE REFRESH COMPLETE ON DEMAND
    enable query rewrite
    AS select DA.CodeVille, DA.NomVille, 
            sum(FO.MontantV) as MontantVille
       from FOperation FO, DAgence DA
      where FO.NumAgence = DA.NumAgence
      group by DA.CodeVille, DA.NomVille
      order by DA.CodeVille;

/*Ecriture de la requête R3*/
alter system flush shared_pool;
alter system flush buffer_cache;
select DA.CodeWilaya, DA.NomWilaya,
            sum(FO.MontantV) as MontantWilaya
       from FOperation FO, DAgence DA
      where FO.NumAgence = DA.NumAgence
      group by DA.CodeWilaya, DA.NomWilaya
      order by DA.CodeWilaya;

/*Suppression des méta données de la dimensions DIMAgence*/
drop dimension DIMAgence;

/*Réexécution de la requête R3*/
alter system flush shared_pool;
alter system flush buffer_cache;
select DA.CodeWilaya, DA.NomWilaya,
            sum(FO.MontantV) as MontantWilaya
       from FOperation FO, DAgence DA
      where FO.NumAgence = DA.NumAgence
      group by DA.CodeWilaya, DA.NomWilaya
      order by DA.CodeWilaya;
