DROP DATABASE IF EXISTS Szkola;

CREATE DATABASE Szkola;

USE Szkola;

----------------------------------------------------------------------------------------------------
CREATE SEQUENCE SEQ_UczenId AS INT START
WITH
    1 INCREMENT BY 1 MINVALUE 1 CACHE 10;

CREATE TABLE
    Uczen (
        UczenId INT NOT NULL DEFAULT NEXT VALUE FOR SEQ_UczenId,
        KlasaId INT,
        Imie VARCHAR(30) NOT NULL,
        Nazwisko VARCHAR(50) NOT NULL,
        PESEL VARCHAR(11) NOT NULL,
        Miejscowosc VARCHAR(40) NOT NULL,
        Ulica VARCHAR(60),
        NumerDomu VARCHAR(10) NOT NULL,
        KodPocztowy VARCHAR(6) NOT NULL
    );

ALTER TABLE Uczen ADD CONSTRAINT PK_UczenId PRIMARY KEY (UczenId);

----------------------------------------------------------------------------------------------------
CREATE TABLE
    Rodzic (
        UczenId INT NOT NULL,
        ImieMatki VARCHAR(30),
        NazwiskoMatki VARCHAR(50),
        TelMatki VARCHAR(12),
        ImieOjca VARCHAR(30),
        NazwiskoOjca VARCHAR(50),
        TelOjca VARCHAR(12)
    );

ALTER TABLE Rodzic ADD CONSTRAINT FK_Rodzic_UczenId FOREIGN KEY (UczenId) REFERENCES Uczen (UczenId) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE Rodzic ADD CONSTRAINT CHK_Rodzice CHECK (
    (
        ImieMatki IS NOT NULL
        AND NazwiskoMatki IS NOT NULL
        AND TelMatki IS NOT NULL
    )
    OR (
        ImieOjca IS NOT NULL
        AND NazwiskoOjca IS NOT NULL
        AND TelOjca IS NOT NULL
    )
);

----------------------------------------------------------------------------------------------------
CREATE SEQUENCE SEQ_NauczycielId AS INT START
WITH
    1 INCREMENT BY 1 MINVALUE 1 CACHE 10;

CREATE TABLE
    Nauczyciel (
        NauczycielId INT NOT NULL DEFAULT NEXT VALUE FOR SEQ_NauczycielId,
        Imie VARCHAR(30) NOT NULL,
        Nazwisko VARCHAR(50) NOT NULL,
        PESEL VARCHAR(11) NOT NULL,
        Miejscowosc VARCHAR(40) NOT NULL,
        Ulica VARCHAR(60),
        NumerDomu VARCHAR(10) NOT NULL,
        KodPocztowy VARCHAR(6) NOT NULL
    );

ALTER TABLE Nauczyciel ADD CONSTRAINT PK_NauczycielId PRIMARY KEY (NauczycielId);

----------------------------------------------------------------------------------------------------
CREATE SEQUENCE SEQ_PrzedmiotId AS INT START
WITH
    1 INCREMENT BY 1 MINVALUE 1 CACHE 10;

CREATE TABLE
    Przedmiot (
        PrzedmiotId INT NOT NULL DEFAULT NEXT VALUE FOR SEQ_PrzedmiotId,
        NazwaPrzedmiotu VARCHAR(30) NOT NULL UNIQUE
    );

ALTER TABLE Przedmiot ADD CONSTRAINT PK_Przedmiot PRIMARY KEY (PrzedmiotId);

----------------------------------------------------------------------------------------------------
CREATE TABLE
    PrzedmiotNauczyciel (
        PrzedmiotId INT NOT NULL,
        NauczycielId INT NOT NULL
    );

ALTER TABLE PrzedmiotNauczyciel ADD CONSTRAINT FK_PrzedmiotNauczyciel_PrzedmiotId FOREIGN KEY (PrzedmiotId) REFERENCES Przedmiot (PrzedmiotId) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE PrzedmiotNauczyciel ADD CONSTRAINT FK_PrzedmiotNauczyciel_NauczycielId FOREIGN KEY (NauczycielId) REFERENCES Nauczyciel (NauczycielId) ON DELETE CASCADE ON UPDATE CASCADE;

----------------------------------------------------------------------------------------------------
CREATE TABLE
    Sala (
        NrSali INT NOT NULL,
        Pietro INT NOT NULL,
        LiczbaMiejsc INT NOT NULL,
        CzyPrzedmiotowa BIT NOT NULL,
        NazwaPrzedmiotu VARCHAR(30),
        OpiekunId INT
    );

ALTER TABLE Sala ADD CONSTRAINT PK_NrSali PRIMARY KEY (NrSali);

ALTER TABLE Sala ADD CONSTRAINT FK_Sala_OpiekunId FOREIGN KEY (OpiekunId) REFERENCES Nauczyciel (NauczycielId) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE Sala ADD CONSTRAINT FK_Sala_NazwaPrzedmiotu FOREIGN KEY (NazwaPrzedmiotu) REFERENCES Przedmiot (NazwaPrzedmiotu) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE Sala ADD CONSTRAINT CHK_Przedmiot CHECK (
    (
        CzyPrzedmiotowa = 1
        AND NazwaPrzedmiotu IS NOT NULL
    )
    OR (
        CzyPrzedmiotowa = 0
        AND NazwaPrzedmiotu IS NULL
    )
);

----------------------------------------------------------------------------------------------------
CREATE SEQUENCE SEQ_KlasaId AS INT START
WITH
    1 INCREMENT BY 1 MINVALUE 1 CACHE 10;

CREATE TABLE
    Klasa (
        KlasaId INT NOT NULL DEFAULT NEXT VALUE FOR SEQ_KlasaId,
        NrKlasy INT NOT NULL,
        Oznaczenie VARCHAR(5),
        Typ VARCHAR(10),
        OpiekunId INT,
        NrSali INT
    );

ALTER TABLE Klasa ADD CONSTRAINT PK_KlasaId PRIMARY KEY (KlasaId);

ALTER TABLE Klasa ADD CONSTRAINT FK_Klasa_OpiekunId FOREIGN KEY (OpiekunId) REFERENCES Nauczyciel (NauczycielId) ON DELETE NO ACTION ON UPDATE NO ACTION;

ALTER TABLE Klasa ADD CONSTRAINT FK_Klasa_NrSali FOREIGN KEY (NrSali) REFERENCES Sala (NrSali) ON DELETE NO ACTION ON UPDATE NO ACTION;

ALTER TABLE Klasa ADD CONSTRAINT CHK_Klasa CHECK (
    (NrKlasy BETWEEN 1 AND 5)
    AND (Typ IN ('technikum', 'liceum', 'branżowa'))
);

----------------------------------------------------------------------------------------------------
ALTER TABLE Uczen ADD CONSTRAINT FK_Uczen_KlasaId FOREIGN KEY (KlasaId) REFERENCES Klasa (KlasaId) ON DELETE SET NULL ON UPDATE CASCADE;

----------------------------------------------------------------------------------------------------
CREATE SEQUENCE SEQ_OcenaId AS INT START
WITH
    1 INCREMENT BY 1 MINVALUE 1 CACHE 10;

CREATE TABLE
    Ocena (
        OcenaId INT NOT NULL DEFAULT NEXT VALUE FOR SEQ_OcenaId,
        UczenId INT NOT NULL,
        PrzedmiotId INT NOT NULL,
        Ocena TINYINT NOT NULL,
        NauczycielId INT NOT NULL,
        DataWystawienia DATE DEFAULT GETDATE ()
    );

ALTER TABLE Ocena ADD CONSTRAINT PK_Ocena PRIMARY KEY (OcenaId);

ALTER TABLE Ocena ADD CONSTRAINT FK_Ocena_UczenId FOREIGN KEY (UczenId) REFERENCES Uczen (UczenId) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE Ocena ADD CONSTRAINT FK_Ocena_PrzedmiotId FOREIGN KEY (PrzedmiotId) REFERENCES Przedmiot (PrzedmiotId) ON DELETE CASCADE ON UPDATE CASCADE;

-- FIXME
ALTER TABLE Ocena ADD CONSTRAINT FK_Ocena_NauczycielId FOREIGN KEY (NauczycielId) REFERENCES Nauczyciel (NauczycielId) ON DELETE NO ACTION ON UPDATE NO ACTION;

ALTER TABLE Ocena ADD CONSTRAINT CHK_Ocena CHECK (Ocena IN (1, 2, 3, 4, 5, 6));

----------------------------------------------------------------------------------------------------
CREATE TABLE
    Lekcja (
        DzienTygodnia VARCHAR(12) NOT NULL,
        NrLekcji INT NOT NULL,
        PrzedmiotId INT NOT NULL,
        NauczycielId INT NOT NULL,
        KlasaId INT NOT NULL,
        NrSali INT NOT NULL
    );

ALTER TABLE Lekcja ADD CONSTRAINT FK_Lekcja_PrzedmiotId FOREIGN KEY (PrzedmiotId) REFERENCES Przedmiot (PrzedmiotId) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE Lekcja ADD CONSTRAINT FK_Lekcja_NauczycielId FOREIGN KEY (NauczycielId) REFERENCES Nauczyciel (NauczycielId) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE Lekcja ADD CONSTRAINT FK_Lekcja_KlasaId FOREIGN KEY (KlasaId) REFERENCES Klasa (KlasaId) ON DELETE NO ACTION ON UPDATE NO ACTION;

ALTER TABLE Lekcja ADD CONSTRAINT FK_Lekcja_NrSali FOREIGN KEY (NrSali) REFERENCES Sala (NrSali) ON DELETE NO ACTION ON UPDATE NO ACTION;

ALTER TABLE Lekcja ADD CONSTRAINT CHK_Lekcja CHECK (
    DzienTygodnia IN (
        'Poniedziałek',
        'Wtorek',
        'Środa',
        'Czwartek',
        'Piątek'
    )
);
GO

----------------------------------------------------------------------------------------------------
CREATE VIEW
    SredniaOcenKlasy AS
SELECT
    Klasa.NrKlasy,
    Klasa.Oznaczenie,
    AVG(Ocena.Ocena) AS SredniaOcenKlasy
FROM
    (
        Klasa
        INNER JOIN Uczen ON Klasa.KlasaId = uczen.UczenId
    )
    INNER JOIN Ocena ON Uczen.UczenId = Ocena.UczenId
GROUP BY
    Uczen.KlasaId,
    Klasa.NrKlasy,
    Klasa.Oznaczenie;
GO

----------------------------------------------------------------------------------------------------
CREATE VIEW
    IlosciSalPrzedmiotowych AS
SELECT
    Sala.NazwaPrzedmiotu,
    COUNT(NrSali) AS IloscSal
FROM
    Sala
GROUP BY
    Sala.NazwaPrzedmiotu;
GO

----------------------------------------------------------------------------------------------------
CREATE VIEW
    NauczycieleWychowawcy AS
SELECT
    Klasa.NrKlasy,
    Klasa.Oznaczenie,
    Nauczyciel.Imie,
    Nauczyciel.Nazwisko
FROM
    Klasa
    INNER JOIN Nauczyciel ON Klasa.OpiekunId = Nauczyciel.NauczycielId;
GO

----------------------------------------------------------------------------------------------------
CREATE VIEW
    SrednieUczniow AS
SELECT
    Uczen.Imie,
    Uczen.Nazwisko,
    Klasa.NrKlasy,
    Klasa.Oznaczenie,
    Klasa.Typ,
    AVG(Ocena.Ocena) AS SredniaOcen
FROM
    (
        Uczen
        INNER JOIN Klasa ON Uczen.KlasaId = Klasa.KlasaId
    )
    INNER JOIN Ocena ON Uczen.UczenId = Ocena.OcenaId
GROUP BY
    Uczen.Imie,
    Uczen.Nazwisko,
    Klasa.NrKlasy,
    Klasa.Oznaczenie,
    Klasa.Typ;
GO

----------------------------------------------------------------------------------------------------
CREATE VIEW
    IloscOcenNauczyciela AS
SELECT
    Nauczyciel.Imie,
    Nauczyciel.Nazwisko,
    COUNT(Ocena.OcenaId) AS IloscWystawionychOcen
FROM
    Nauczyciel
    LEFT JOIN Ocena ON Nauczyciel.NauczycielId = Ocena.NauczycielId
GROUP BY
    Nauczyciel.NauczycielId,
    Nauczyciel.Imie,
    Nauczyciel.Nazwisko;
GO

----------------------------------------------------------------------------------------------------
CREATE VIEW
    IloscGodzinTygodniowoKlasa AS
SELECT
    Klasa.NrKlasy,
    Klasa.Oznaczenie,
    COUNT(Lekcja.KlasaId) AS IloscLekcjiTygodniowo
FROM
    Klasa
    INNER JOIN Lekcja ON Klasa.KlasaId = Lekcja.KlasaId
GROUP BY
    Klasa.NrKlasy,
    Klasa.Oznaczenie;
GO

----------------------------------------------------------------------------------------------------
CREATE FUNCTION SrednieUczniowKlasaPrzedmiot (
    @NrKlasy INT,
    @OznaczenieKlasy VARCHAR(5),
    @NazwaPrzedmiotu VARCHAR(15)
)
RETURNS TABLE AS
RETURN
    SELECT 
        Uczen.Imie,
        Uczen.Nazwisko,
        AVG(Ocena.Ocena) AS SredniaOcen
        FROM ((Uczen INNER JOIN Ocena ON Uczen.UczenId = Ocena.UczenId) INNER JOIN Przedmiot ON Ocena.PrzedmiotId = Przedmiot.PrzedmiotId) INNER JOIN Klasa ON Uczen.KlasaId = Klasa.KlasaId
        WHERE Przedmiot.NazwaPrzedmiotu = @NazwaPrzedmiotu AND Klasa.NrKlasy = @NrKlasy AND Klasa.Oznaczenie = @OznaczenieKlasy
        GROUP BY Uczen.Imie, Uczen.Nazwisko;
GO

----------------------------------------------------------------------------------------------------
CREATE FUNCTION PlanNauczycielaDzienTygodnia (
    @ImieNauczyciela VARCHAR(30),
    @NazwiskoNauczyciela VARCHAR(50),
    @DzienTygodnia VARCHAR(12)
)
RETURNS TABLE AS
RETURN
    SELECT
        Lekcja.DzienTygodnia,
        Lekcja.NrLekcji,
        Przedmiot.NazwaPrzedmiotu
        FROM (Lekcja INNER JOIN Przedmiot ON Lekcja.PrzedmiotId = Przedmiot.PrzedmiotId) INNER JOIN Nauczyciel ON Lekcja.NauczycielId = Nauczyciel.NauczycielId
        WHERE Nauczyciel.Imie = @ImieNauczyciela AND Nauczyciel.Nazwisko = @NazwiskoNauczyciela AND Lekcja.DzienTygodnia = @DzienTygodnia;
GO

----------------------------------------------------------------------------------------------------

CREATE PROCEDURE DodajLekcję (
    @NrKlasy INT,
    @OznaczenieKlasy VARCHAR(5),
    @DzienTygodnia VARCHAR(12),
    @NrLekcji INT,
    @NazwaPrzedmiotu VARCHAR(30),
    @ImieNauczyciela VARCHAR(30),
    @NazwiskoNauczyciela VARCHAR(50),
    @NrSali INT
) 
AS
BEGIN
IF (SELECT Lekcja.NauczycielId FROM Lekcja INNER JOIN Nauczyciel ON Lekcja.NauczycielId = Nauczyciel.NauczycielId WHERE Lekcja.DzienTygodnia = @DzienTygodnia AND Lekcja.NrLekcji = @NrLekcji AND Nauczyciel.Imie = @ImieNauczyciela AND Nauczyciel.Nazwisko = @NazwiskoNauczyciela) IS NULL
    BEGIN
        DECLARE @PrzedmiotId INT, @NauczycielId INT, @KlasaId INT;
        SELECT @PrzedmiotId = Przedmiot.PrzedmiotId FROM Przedmiot WHERE Przedmiot.NazwaPrzedmiotu = @NazwaPrzedmiotu;
        SELECT @NauczycielId = Nauczyciel.NauczycielId FROM Nauczyciel WHERE Nauczyciel.Imie = @ImieNauczyciela AND Nauczyciel.Nazwisko = @NazwiskoNauczyciela;
        SELECT @KlasaId = Klasa.KlasaId FROM KLasa WHERE Klasa.NrKlasy = @NrKlasy AND Klasa.Oznaczenie = @OznaczenieKlasy;

        INSERT INTO Lekcja VALUES (@DzienTygodnia, @NrLekcji, @PrzedmiotId, @NauczycielId, @KlasaId, @NrSali);
    END;
ELSE
    SELECT 'Nauczyciel już jest zajęty tego dnia na tej lekcji';
END;
GO

----------------------------------------------------------------------------------------------------

CREATE PROCEDURE ArchiwizujCzyscTabele (
    @NazwaTabeli VARCHAR(15)
)
AS
BEGIN
    IF @NazwaTabeli LIKE 'Uczen'
        BEGIN
            SELECT * INTO ArchiwumUczen FROM Uczen;
            ALTER TABLE Uczen NOCHECK CONSTRAINT ALL;
            DELETE Uczen;
            ALTER TABLE Uczen CHECK CONSTRAINT ALL;
        END;
    ELSE IF @NazwaTabeli LIKE 'Nauczyciel'
        BEGIN
            SELECT * INTO ArchiwumNauczyciel FROM Nauczyciel;
            ALTER TABLE Nauczyciel NOCHECK CONSTRAINT ALL;
            DELETE Nauczyciel;
            ALTER TABLE Nauczyciel CHECK CONSTRAINT ALL;
        END;
    ELSE IF @NazwaTabeli LIKE 'Klasa'
        BEGIN
            SELECT * INTO ArchiwumKlasa FROM Klasa;
            ALTER TABLE Klasa NOCHECK CONSTRAINT ALL;
            DELETE Klasa;
            ALTER TABLE Klasa CHECK CONSTRAINT ALL;
        END;
    ELSE IF @NazwaTabeli LIKE 'Ocena'
        BEGIN
            SELECT * INTO ArchiwumOcena FROM Ocena;
            ALTER TABLE Ocena NOCHECK CONSTRAINT ALL;
            DELETE Ocena;
            ALTER TABLE Ocena CHECK CONSTRAINT ALL;
        END;
    ELSE IF @NazwaTabeli LIKE 'Rodzic'
        BEGIN
            SELECT * INTO ArchiwumRodzic FROM Rodzic;
            ALTER TABLE Rodzic NOCHECK CONSTRAINT ALL;
            DELETE Rodzic;
            ALTER TABLE Rodzic CHECK CONSTRAINT ALL;
        END;
    ELSE IF @NazwaTabeli LIKE 'Lekcja'
        BEGIN
            SELECT * INTO ArchiwumLekcja FROM Lekcja;
            ALTER TABLE Lekcja NOCHECK CONSTRAINT ALL;
            DELETE Lekcja;
            ALTER TABLE Lekcja CHECK CONSTRAINT ALL;
        END;
    ELSE IF @NazwaTabeli LIKE 'Sala'
        BEGIN
            SELECT * INTO ArchiwumSala FROM Sala;
            ALTER TABLE Sala NOCHECK CONSTRAINT ALL;
            DELETE Sala;
            ALTER TABLE Sala CHECK CONSTRAINT ALL;
        END;
    ELSE IF @NazwaTabeli LIKE 'Przedmiot'
        BEGIN
            SELECT * INTO ArchiwumPrzedmiot FROM Przedmiot;
            ALTER TABLE Przedmiot NOCHECK CONSTRAINT ALL;
            DELETE Przedmiot;
            ALTER TABLE Przedmiot CHECK CONSTRAINT ALL;
        END;
    ELSE
        SELECT 'Nie ma takiej tabeli';
END;
GO

----------------------------------------------------------------------------------------------------
CREATE TABLE ZarchiwizowanyUczen (
        UczenId INT PRIMARY KEY NOT NULL,
        Imie VARCHAR(30) NOT NULL,
        Nazwisko VARCHAR(50) NOT NULL,
        Miejscowosc VARCHAR(40) NOT NULL,
        Ulica VARCHAR(60),
        NumerDomu VARCHAR(10) NOT NULL,
        KodPocztowy VARCHAR(6) NOT NULL
);

GO

CREATE TRIGGER TR_ArchiwizujUcznia ON Uczen
FOR DELETE
AS
BEGIN
    INSERT INTO ZarchiwizowanyUczen SELECT UczenId, Imie, Nazwisko, Miejscowosc, Ulica, NumerDomu, KodPocztowy FROM deleted;
END;
GO

----------------------------------------------------------------------------------------------------
CREATE TRIGGER TR_SprawdzKlase ON Klasa
INSTEAD OF INSERT, UPDATE
AS
BEGIN
    IF EXISTS (SELECT Klasa.KlasaId FROM Klasa, inserted WHERE Klasa.NrKlasy = inserted.NrKlasy AND Klasa.Oznaczenie = inserted.Oznaczenie)
    BEGIN
        SELECT 'Istnieje już taka klasa';
        DELETE Klasa FROM Klasa INNER JOIN inserted ON Klasa.KlasaId = inserted.KlasaId;
    END;
    ELSE
        INSERT INTO Klasa SELECT * FROM inserted;
END;
GO

----------------------------------------------------------------------------------------------------
USE tempdb;