DROP TABLE Kurz cascade constraints;
DROP TABLE Sala cascade constraints;
DROP TABLE Lekcia cascade constraints;
DROP TABLE Zakaznik cascade constraints;
DROP TABLE Instruktor cascade constraints;
DROP TABLE Pouzivatel cascade constraints;

DROP MATERIALIZED VIEW materialized_pohlad;

CREATE TABLE Kurz(
        ID_kurzu int not null,
        narocnost char(50) not null,
        kapacita int not null,
        dlzka_trvania int not null,
        typ char(50) not null,
        popis char(100) not null,
        PRIMARY KEY(ID_kurzu)
);

CREATE TABLE Pouzivatel(
        rodne_cislo int not null,
        meno char(32) not null,
        priezvisko char(32) not null,
        telefonne_cislo char(32) not null,
        email char(50) not null,
        mesto char(50) not null,
        ulica char(50) not null,
        popisne_cislo int not null,
        PSC int not null,
        PRIMARY KEY(Rodne_cislo),

        CHECK(regexp_like(PSC, '^[0-9]{5}$')),
        CHECK(regexp_like(email, '^[^@]+@[^@]+\.[a-z]{2,6}'))
);

CREATE TABLE Instruktor(
        RC_instruktor int not null,
        PRIMARY KEY(RC_instruktor)
);

CREATE TABLE Sala(
        ID_saly int not null,
        nazov char(50) not null,
        pocet_miest int not null,
        poloha_saly char(50) not null,
        PRIMARY KEY(ID_saly)
);

CREATE TABLE Lekcia(
        ID_lekcie int not null,
        typ_lekcie char(32) not null,
        kapacita_miest int not null,
        cena decimal(10,2) not null,
        mena char(5) default '€',
        den char(50) not null,
        cas_zaciatku char(5) not null,
        cas_konca char(5) not null,
        ID_saly int not null,
        kurz int not null,
        rodne_cislo_instruktor int not null,
        PRIMARY KEY(ID_lekcie)
);

CREATE TABLE Zakaznik(
        rodne_cislo int not null,
        ID_lekcie int not null,
        PRIMARY KEY(Rodne_cislo, ID_lekcie)
);


ALTER TABLE Instruktor ADD CONSTRAINT FK_RCI FOREIGN KEY (RC_instruktor)
   REFERENCES Pouzivatel;
ALTER TABLE Lekcia ADD CONSTRAINT FK_idsaly FOREIGN KEY (ID_saly)
   REFERENCES Sala;
ALTER TABLE Lekcia ADD CONSTRAINT FK_idkurzu FOREIGN KEY (Kurz)
   REFERENCES Kurz;
ALTER TABLE Lekcia ADD CONSTRAINT FK_RCinstruktora FOREIGN KEY (Rodne_cislo_instruktor)
   REFERENCES Instruktor;
ALTER TABLE Zakaznik ADD CONSTRAINT FK_RC FOREIGN KEY (Rodne_cislo)
   REFERENCES Pouzivatel;
ALTER TABLE Zakaznik ADD CONSTRAINT FK_IDlekcie FOREIGN KEY (ID_lekcie)
   REFERENCES Lekcia;


CREATE SEQUENCE pouzivatel_seq START WITH 1 INCREMENT BY 1 NOCYCLE;
--CREATE SEQUENCE lekcia_seq START WITH 10 INCREMENT BY 1 NOCYCLE;

--TRIGGERS

--v pripade, že rodne čislo nie je zadané, alebo je NULL, generovanie primarneho kluča
CREATE OR REPLACE TRIGGER pouzivatel_seq_trigger
    BEFORE INSERT ON pouzivatel
    FOR EACH ROW
        WHEN (new.rodne_cislo is NULL)
    BEGIN
        :new.rodne_cislo := pouzivatel_seq.nextval;
    END;
/

-- Po ukončení kurzu nie je nutné naďalej viesť záznam o jeho lekciách
CREATE TRIGGER Koniec_kurzu
    AFTER DELETE ON Kurz
    FOR EACH ROW
BEGIN
    DELETE FROM Lekcia WHERE Lekcia.kurz = :OLD.ID_kurzu;
END;
/


INSERT into Sala values (10, 'Sala1', 150, 'BLOK 1');
INSERT into Sala values (11, 'Sala2', 120, 'BLOK 2');
INSERT into Sala values (12, 'Sala3', 80, 'BLOK 3');
INSERT into Sala values (13, 'Sala4', 80, 'BLOK 3');
INSERT into Sala values (14, 'Sala5', 60, 'BLOK 4');
INSERT into Sala values (15, 'Sala6', 60, 'BLOK 4');

INSERT into Kurz values (1, 'ťažká', 100, 20, 'skupinovy', 'Nohy');
INSERT into Kurz values (2, 'ľahká', 120, 60, 'jednotlivec', 'Brucho');
INSERT into Kurz values (3, 'stredná', 40, 30, 'jednotlivec', 'Celé telo');
INSERT into Kurz values (4, 'ťažká', 90, 30, 'skupinovy', 'Ruky');
INSERT into Kurz values (5, 'ľahká', 100, 40, 'skupinovy', 'Kondícia');
INSERT into Kurz values (6, 'stredná', 80, 40, 'skupinový', 'Chrbát');

INSERT into Pouzivatel values(15645121, 'Jozo', 'Frajer', +421831300509, 'jozofrajer@gmail.com', 'Bardejov', 'Hlavna', 450, 91500);
INSERT into Pouzivatel values(25645121, 'Maros', 'Kovac', +421968053532, 'marosko@gmail.com', 'Hlohovec', 'Stefanikova', 150, 91522);
INSERT into Pouzivatel values(35645121, 'Fero', 'Vegh',  +42167455493, 'vegh@gmail.com', 'Sala', 'Safrankova', 420, 91332);
INSERT into Pouzivatel values(45645121, 'Mario', 'Varga', +420418333748, 'mario4121@gmail.com', 'Brezno', 'Kupeckeho', 350, 91502);
INSERT into Pouzivatel values(55645121, 'Gramo', 'Rokaz', +42191492780, 'bengoro@gmail.com', 'Píšťany', 'Rytmusácka', 12, 97587);
INSERT into Pouzivatel values(65645121, 'Róbert', 'Andráši', +421311676858, 'roboandrasi@sala.sk', 'Trnovec nad Váhom', 'Poštová', 122, 92342);
INSERT into Pouzivatel values(75645121, 'Jana', 'Zlatá', +42057281850, 'jana.zlata@salamon.sk', 'Šaľa', 'M.R.Štefánika', 22, 92701);
INSERT into Pouzivatel values(85645121, 'Tomáš', 'Vozár', +420721214122, 'tomasvozar@gmail.com', 'Šaľa', 'Vinohradnícka', 3, 92701);
INSERT into Pouzivatel values(95645121, 'Veronika', 'Gállová', +420697656312, 'verca333@gmail.com', 'Štitáre', 'Fábryho', 65, 92903);
INSERT into Pouzivatel values(15645122, 'Vladimír', 'Gasior', +421491295959, 'vladogasior@gmail.com', 'Nitra', 'Pod Zoborom', 956, 94901);
INSERT into Pouzivatel values(15645123, 'Luboš', 'Janek', +421155790163, 'lubijepan@gmail.com', 'Nitra', 'Hlavna', 84, 94901);
--prezentácia trigeru, ktorý v prípade ak použivatel nezadá rodné číslo, doplní číslo zo sekvencie
INSERT into Pouzivatel values(NULL, 'Patrik', 'Mantak', +421142790163, 'mantak@gmail.com', 'Vlčany', 'Hlavna', 22, 92101);

INSERT into Instruktor values (15645121);
INSERT into Instruktor values (15645122);

INSERT into Lekcia values(1, 'Lýtka', 60, 30, '€' , 'Utorok', '8:00', '9:00', 10, 1, 15645121);
INSERT into Lekcia values(2, 'Stehná', 60, 30, '€' ,'Streda', '9:00', '10:00', 10, 1, 15645121);
INSERT into Lekcia values(3, 'Chudnutie', 50, 50, '€' ,'Pondelok', '11:00', '12:00', 10, 2, 15645121);
INSERT into Lekcia values(4, 'Brušné svalstvo', 50, 40, '€' ,'Piatok', '12:00', '13:00', 10, 2, 15645121);
INSERT into Lekcia values(5, 'Udržiavanie formy', 50, 50, '€' ,'Pondelok', '13:00', '14:00', 10, 3, 15645122);
INSERT into Lekcia values(6, 'Biceps, triceps', 50, 60, '€' ,'Utorok', '8:00', '9:00', 10, 4, 15645122);
INSERT into Lekcia values(7, 'Zdravý pohyb', 50, 70, '€' ,'Streda', '9:00', '10:00', 11, 5, 15645122);
INSERT into Lekcia values(8, 'Priprava na maratón', 60, 50, '€' ,'Piatok', '10:00', '11:00', 13, 5, 15645122);
INSERT into Lekcia values(9, 'Bolesti chrbta a svalov', 30, 70, '€' ,'Utorok', '15:00', '16:00', 12, 6, 15645122);

INSERT into Zakaznik values (15645123,9);
INSERT into Zakaznik values (15645123,7);
INSERT into Zakaznik values (25645121,8);
INSERT into Zakaznik values (25645121,4);
INSERT into Zakaznik values (35645121,5);
INSERT into Zakaznik values (35645121,2);
INSERT into Zakaznik values (35645121,3);
INSERT into Zakaznik values (45645121,6);
INSERT into Zakaznik values (45645121,1);
INSERT into Zakaznik values (55645121,5);
INSERT into Zakaznik values (55645121,2);
INSERT into Zakaznik values (55645121,1);
INSERT into Zakaznik values (55645121,9);
INSERT into Zakaznik values (65645121,2);
INSERT into Zakaznik values (65645121,3);
INSERT into Zakaznik values (95645121,1);
INSERT into Zakaznik values (95645121,8);

SELECT * FROM Kurz;
SELECT * FROM Pouzivatel;
SELECT * FROM Sala;
SELECT * FROM Lekcia;
SELECT * FROM Instruktor;
SELECT * FROM Zakaznik;


--Vypise klientov a ich zapisane lekcie (SPAJANIE 3 TABULIEK)
SELECT Pouzivatel.rodne_cislo, Pouzivatel.meno, Pouzivatel.priezvisko, Zakaznik.rodne_cislo, Zakaznik.ID_lekcie
FROM Pouzivatel
INNER JOIN Zakaznik ON Zakaznik.rodne_cislo = Pouzivatel.rodne_cislo
INNER JOIN Lekcia ON Zakaznik.ID_lekcie = Lekcia.ID_lekcie
ORDER BY meno ASC;

--Vypise lekcie, ktora su lacnejsie ako 50€
SELECT
    ID_lekcie, typ_lekcie, cena, mena
FROM Lekcia
WHERE cena < 50;

--Vypise lekcie, do ktorych kurzov patria + ich cenu (SPAJANIE 2 TABULIEK)
SELECT
    kurz, typ_lekcie, cena, mena
FROM
    Lekcia
    RIGHT JOIN Kurz
ON Lekcia.kurz = Kurz.ID_kurzu
ORDER BY kurz ASC;

--Vypise pocet zakaznikov z daneho mesta a zoradi zostupne (GROUP BY)
SELECT
    COUNT(mesto) AS POCET_ZAKAZNIKOV, mesto
FROM
    Pouzivatel
GROUP BY mesto
ORDER BY COUNT(mesto) DESC;

--Vypise pocet tazkych, stredne tazkych a lahkych kurzov (GROUP BY)
SELECT COUNT(*) AS POCET_KURZOV, narocnost
FROM Kurz
GROUP BY narocnost
ORDER BY COUNT(*) DESC;

--Vypise zakaznikov, ktory maju zapisanu aspon 1 lekciu (SPAJANIE 2 TABULIEK + EXISTS)
SELECT meno, priezvisko
FROM Pouzivatel
WHERE EXISTS(SELECT *
                FROM Zakaznik
                WHERE Pouzivatel.rodne_cislo = Zakaznik.rodne_cislo)
ORDER BY meno;

--Vypise kurzy, ktore začínajú o 8:00 alebo 12:00
SELECT
    *
FROM
    Kurz
WHERE
    ID_kurzu
IN
    (
        SELECT
            Lekcia.kurz
        FROM
            Lekcia
        INNER JOIN Instruktor
        ON Lekcia.rodne_cislo_instruktor = Instruktor.RC_instruktor
        WHERE
            Lekcia.cas_zaciatku = '8:00'
            OR Lekcia.cas_zaciatku = '12:00'
    );


CREATE OR REPLACE FUNCTION kapacitaSpolu
RETURN NUMBER
AS
    CURSOR cur IS SELECT pocet_miest FROM Sala;
    celkovy_pocet NUMBER;
    iter Sala.pocet_miest%TYPE;
BEGIN
    IF cur %ISOPEN THEN
        CLOSE cur ;
    END IF;
    OPEN cur;

    celkovy_pocet := 0;

    LOOP
        FETCH cur INTO iter;
        EXIT WHEN cur%NOTFOUND;
        celkovy_pocet := celkovy_pocet + iter;
    END LOOP;

    CLOSE cur;

    RETURN celkovy_pocet;
END;
/


CREATE OR REPLACE PROCEDURE podielZKapacity
AS
    CURSOR cur IS SELECT * FROM Sala;
    curs_var cur%ROWTYPE;
    celkova_kapacita NUMBER;
    percenta NUMBER;
BEGIN
    IF cur %ISOPEN THEN
        CLOSE cur ;
    END IF;
    OPEN cur;

    celkova_kapacita := kapacitaSpolu();

    LOOP
        FETCH cur INTO curs_var;
        EXIT WHEN cur%NOTFOUND;
        percenta := vypocitaj_percent_podiel(celkova_kapacita, curs_var.pocet_miest);
        percenta := ROUND(percenta);
        DBMS_OUTPUT.put_line('Sála s ID ' ||curs_var.ID_saly|| ' má kapacitu ' ||curs_var.pocet_miest|| ' čo je '||percenta|| ' % z celkovej kapacity.');
    END LOOP;
    DBMS_OUTPUT.put_line('Celková kapacita v miestnostiach je ' ||celkova_kapacita);
    CLOSE cur;
END;
/


CREATE OR REPLACE FUNCTION vypocitaj_percent_podiel(celkovy_pocet IN NUMBER, miestnost IN number)
RETURN NUMBER
AS
    vysledok NUMBER;
BEGIN
    vysledok := (miestnost * 100) / celkovy_pocet;
    RETURN vysledok;

    EXCEPTION WHEN zero_divide THEN
        RETURN 0;
END;
/

CALL podielZKapacity();

--explain plan
EXPLAIN PLAN FOR
SELECT
    COUNT(mesto) AS POCET_ZAKAZNIKOV, mesto
FROM
    Pouzivatel
GROUP BY mesto
ORDER BY COUNT(mesto) DESC;
SELECT * FROM TABLE(dbms_xplan.display);


EXPLAIN PLAN FOR
    SELECT meno, priezvisko
FROM Pouzivatel
WHERE EXISTS(SELECT *
                FROM Zakaznik
                WHERE Pouzivatel.rodne_cislo = Zakaznik.rodne_cislo)
ORDER BY meno;
SELECT * FROM TABLE(dbms_xplan.display);

--explain plan with index

CREATE INDEX idx ON Zakaznik(rodne_cislo);

EXPLAIN PLAN FOR
    SELECT meno, priezvisko
FROM Pouzivatel
WHERE EXISTS(SELECT *
                FROM Zakaznik
                WHERE Pouzivatel.rodne_cislo = Zakaznik.rodne_cislo)
ORDER BY meno;
SELECT * FROM TABLE(dbms_xplan.display);

DROP INDEX idx;

-- Pridelenie prav
GRANT ALL ON Pouzivatel TO XCECHV03;
GRANT ALL ON Kurz TO XCECHV03;
GRANT ALL ON Lekcia TO XCECHV03;
GRANT ALL ON Sala TO XCECHV03;
GRANT ALL ON Instruktor TO XCECHV03;
GRANT ALL ON Zakaznik TO XCECHV03;

-- Vytvorenie materializovaneho pohladu

CREATE MATERIALIZED VIEW materialized_pohlad

NOLOGGING
CACHE
BUILD IMMEDIATE
REFRESH ON COMMIT

AS
    SELECT Meno, Priezvisko FROM Pouzivatel p JOIN Instruktor i ON p.rodne_cislo = i.RC_instruktor;

GRANT ALL ON materialized_pohlad TO XCECHV03;
