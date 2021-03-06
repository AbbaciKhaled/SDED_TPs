/*
  Script TP 8
  Réalisé en binome par: BENSALAH Kawthar / ABBACI Khaled
  Numéro du Binome : 22
  Master 2 IL - Groupe 1
  USTHB 2019/2020
*/

/*Réponse 1*/
/*Activation des options autotrace et timing de oracle*/
set timing on;
set autotrace on explain;

/*Ecriture et exécution de la requête R1 qui donne le nombre d’une banque donnée*/
alter system flush shared_pool;
alter system flush buffer_cache;

Select count(NumAgence) as NbAgences
From DAgence where NomBanque like 'BNA 1';

/*Réponse 2*/
/*Création d’un index B-Arbre de la table DAgence sur l’attribut NomBanque :*/
CREATE Index Index_Banque on DAgence(NomBanque) TABLESPACE DefaultTBS2 ;

/*Réponse 3*/
/*Réexécution de la requête R1*/
alter system flush shared_pool;
alter system flush buffer_cache;

Select count(NumAgence) as NbAgences
From DAgence where NomBanque like 'BNA 9';

/*Réponse 4*/
/*Suppression de l’index B-Arbre*/
Drop Index Index_Banque;

/*Création d’un index bitmap sur la même table*/
Create Bitmap Index Index_Banque on DAgence(NomBanque) TABLESPACE DefaultTBS2;

/*Réponse 5*/
/*Réexécution de la requête R1*/
alter system flush shared_pool;
alter system flush buffer_cache;

Select count(NumAgence) as NbAgences
From DAgence where NomBanque like 'BNA 1';

/*Réponse 6*/
/*Ecriture de la requête R2 qui donne le montant versé global dans des comptes d’épargne*/
alter system flush shared_pool;
alter system flush buffer_cache;

Select sum(FO.MontantV) as MontV 
From FOperation FO, DTypeCompte DTC  
where FO.CodeTypeCompte = DTC.CodeType
and DTC.LibType = 'Epargne';

/*Réponse 7*/
/*Création d’un index bitmap de jointure entre FOperation et DTypeCompte*/
Create Bitmap Index Intex_Bitmap on Foperation(DTC.LibType)
FROM FOperation FO,
DTypeCompte DTC 
Where (FO.CodeTypeCompte=DTC.CodeType) TABLESPACE DefaultTBS2;

/*Réponse 8*/
/*Réexécution de la requête R2*/

alter system flush shared_pool;
alter system flush buffer_cache;

Select sum(FO.MontantV) as MontV 
From FOperation FO, DTypeCompte DTC  
where FO.CodeTypeCompte = DTC.CodeType
and DTC.LibType = 'Epargne';

/*Réponse 9*/
/*Ecriture de la requête R3 qui donne le montant versé global dans dans la wilaya d’alger*/
alter system flush shared_pool;
alter system flush buffer_cache;

Select sum(FO.MontantV) as MontV 
From FOperation FO, DAgence DA  
where FO.NumAgence = DA.NumAgence
and DA.CodeWilaya = 16;

/*Réponse 10*/
/*Création d’un index bitmap de jointure entre FOperation et DAgence*/
Create Bitmap Index Intex_Bitmap2 on Foperation(DA.NumAgence)
FROM FOperation FO,
DAgence DA 
Where (FO.NumAgence=DA.NumAgence) TABLESPACE DefaultTBS2;

/*Réponse 11*/
/*Réexécution de la requête R3*/
alter system flush shared_pool;
alter system flush buffer_cache;

Select sum(FO.MontantV) as MontV 
From FOperation FO, DAgence DA  
where FO.NumAgence = DA.NumAgence
and DA.CodeWilaya = 16;

/*Réponse 12*/
/*Création d’un table FOpération2 identique à FOpération avec partitions*/

CREATE TABLE FOperation2 (
    NumClient Number(10),
    NumAgence Number(10),
    CodeTypeCompte Number(10),
    CodeTemps Number(10),
    NbOperationR Number(10),
    NbOperationV Number(10),
    MontantR number(10,2), 
    MontantV number(10,2),
    CONSTRAINT FK_O12 
        FOREIGN KEY (NumClient) 
        REFERENCES DClient(NumClient),
    CONSTRAINT FK_O22 
        FOREIGN KEY (NumAgence) 
        REFERENCES DAgence(NumAgence),
    CONSTRAINT FK_O32 
        FOREIGN KEY (CodeTypeCompte) 
        REFERENCES DTypeCompte(CodeType),
    CONSTRAINT FK_O42 
        FOREIGN KEY (CodeTemps) 
        REFERENCES DTemps(CodeTemps),
    CONSTRAINT PK_O2 
        PRIMARY KEY (NumClient, NumAgence,CodeTypeCompte, CodeTemps)
)
PARTITION BY range(NumAgence)
(
partition P1 values LESS THAN (4000),
partition P2 values LESS THAN (7000),
partition P3 values LESS THAN (10000),
partition P4 values LESS THAN (MAXVALUE)
);

/*Réponse 13*/
/*Remplissage de la table FOperation2*/
begin
  for i in (
    SELECT NumClient, NumAgence, CodeTypeCompte, CodeTemps, NbOperationR, NbOperationV, MontantR, MontantV
    FROM FOperation)  
    loop
        insert into FOperation2 values (i.NumClient, i.NumAgence, i.CodeTypeCompte, 
        i.CodeTemps, i.NbOperationR, i.NbOperationV, i.MontantR, i.MontantV); 
  end loop;
COMMIT;
end;
/

/*Réponse 14*/
/*Ecriture de la requête R4 qui donne le montant versé global dans l’agence N°12014*/
alter system flush shared_pool;
alter system flush buffer_cache;

select sum(MontantV) as montVGlobal
from FOperation
where NumAgence= '12014';

/*Réponse 15*/
/*Modification de la requête R4 pour utiliser FOpération2*/
alter system flush shared_pool;
alter system flush buffer_cache;

select sum(MontantV) as montVGlobal
from FOperation2
where NumAgence= '12014';
