-- Script SQL équivalent de l'analyse HFSQL RestoManager.
-- Peut servir de base si on importe via l'assistant WinDev « Importer depuis un script SQL ».
-- Syntaxe HFSQL / ANSI SQL.

CREATE TABLE Utilisateurs (
    IDUtilisateur     INT IDENTITY(1,1) PRIMARY KEY,
    Login             NVARCHAR(32) NOT NULL UNIQUE,
    MotDePasseHash    NVARCHAR(64) NOT NULL,
    SelMDP            NVARCHAR(32) NOT NULL,
    Nom               NVARCHAR(64) NOT NULL,
    Prenom            NVARCHAR(64) NOT NULL,
    Role              NVARCHAR(16) NOT NULL,
    Actif             BIT NOT NULL DEFAULT 1,
    DateCreation      DATETIME NOT NULL
);

CREATE TABLE Categories (
    IDCategorie       INT IDENTITY(1,1) PRIMARY KEY,
    Nom               NVARCHAR(32) NOT NULL UNIQUE,
    OrdreAffichage    INT NOT NULL DEFAULT 0,
    CouleurRGB        INT NOT NULL DEFAULT 0
);

CREATE TABLE Plats (
    IDPlat            INT IDENTITY(1,1) PRIMARY KEY,
    IDCategorie       INT NOT NULL REFERENCES Categories(IDCategorie),
    Nom               NVARCHAR(64) NOT NULL,
    Description       NTEXT,
    Prix              MONEY NOT NULL,
    Actif             BIT NOT NULL DEFAULT 1,
    TempsPreparation  INT NOT NULL DEFAULT 10,
    Image             VARBINARY(MAX)
);

CREATE TABLE Ingredients (
    IDIngredient      INT IDENTITY(1,1) PRIMARY KEY,
    Nom               NVARCHAR(64) NOT NULL UNIQUE,
    Unite             NVARCHAR(8) NOT NULL,
    StockActuel       FLOAT NOT NULL DEFAULT 0,
    StockMin          FLOAT NOT NULL DEFAULT 0,
    PrixAchatUnitaire MONEY NOT NULL DEFAULT 0
);

CREATE TABLE PlatsIngredients (
    IDPlat            INT NOT NULL REFERENCES Plats(IDPlat),
    IDIngredient      INT NOT NULL REFERENCES Ingredients(IDIngredient),
    Quantite          FLOAT NOT NULL,
    PRIMARY KEY (IDPlat, IDIngredient)
);

CREATE TABLE Tables (
    IDTable           INT IDENTITY(1,1) PRIMARY KEY,
    Numero            INT NOT NULL UNIQUE,
    Capacite          INT NOT NULL DEFAULT 2,
    Statut            NVARCHAR(16) NOT NULL DEFAULT 'Libre',
    Zone              NVARCHAR(32) NULL
);

CREATE TABLE Clients (
    IDClient          INT IDENTITY(1,1) PRIMARY KEY,
    Nom               NVARCHAR(64) NOT NULL,
    Prenom            NVARCHAR(64) NULL,
    Telephone         NVARCHAR(20) NULL,
    Email             NVARCHAR(128) NULL,
    Notes             NTEXT NULL
);

CREATE TABLE Reservations (
    IDReservation     INT IDENTITY(1,1) PRIMARY KEY,
    IDClient          INT NOT NULL REFERENCES Clients(IDClient),
    IDTable           INT NOT NULL REFERENCES Tables(IDTable),
    DateHeure         DATETIME NOT NULL,
    NbPersonnes       INT NOT NULL DEFAULT 1,
    Statut            NVARCHAR(16) NOT NULL DEFAULT 'Attente',
    Notes             NTEXT NULL
);

CREATE TABLE Commandes (
    IDCommande        INT IDENTITY(1,1) PRIMARY KEY,
    IDTable           INT NOT NULL REFERENCES Tables(IDTable),
    IDServeur         INT NOT NULL REFERENCES Utilisateurs(IDUtilisateur),
    DateHeureOuverture DATETIME NOT NULL,
    DateHeureCloture  DATETIME NULL,
    Statut            NVARCHAR(16) NOT NULL DEFAULT 'EnCours',
    Notes             NTEXT NULL,
    TotalHT           MONEY NOT NULL DEFAULT 0,
    TotalTVA          MONEY NOT NULL DEFAULT 0,
    TotalTTC          MONEY NOT NULL DEFAULT 0
);

CREATE TABLE LignesCommande (
    IDLigne           INT IDENTITY(1,1) PRIMARY KEY,
    IDCommande        INT NOT NULL REFERENCES Commandes(IDCommande) ON DELETE CASCADE,
    IDPlat            INT NOT NULL REFERENCES Plats(IDPlat),
    Quantite          INT NOT NULL DEFAULT 1,
    PrixUnitaire      MONEY NOT NULL,
    Notes             NVARCHAR(255) NULL,
    Statut            NVARCHAR(16) NOT NULL DEFAULT 'Attente'
);

CREATE TABLE Factures (
    IDFacture         INT IDENTITY(1,1) PRIMARY KEY,
    IDCommande        INT NOT NULL UNIQUE REFERENCES Commandes(IDCommande),
    NumeroFacture     NVARCHAR(20) NOT NULL UNIQUE,
    DateHeure         DATETIME NOT NULL,
    IDCaissier        INT NOT NULL REFERENCES Utilisateurs(IDUtilisateur),
    TotalHT           MONEY NOT NULL,
    TotalTVA          MONEY NOT NULL,
    TotalTTC          MONEY NOT NULL,
    ModePaiement      NVARCHAR(16) NOT NULL,
    MontantRecu       MONEY NOT NULL,
    Rendu             MONEY NOT NULL DEFAULT 0
);

CREATE TABLE MouvementsStock (
    IDMouvement       INT IDENTITY(1,1) PRIMARY KEY,
    IDIngredient      INT NOT NULL REFERENCES Ingredients(IDIngredient),
    TypeMouvement     NVARCHAR(16) NOT NULL,
    Quantite          FLOAT NOT NULL,
    DateHeure         DATETIME NOT NULL,
    IDUtilisateur     INT NOT NULL REFERENCES Utilisateurs(IDUtilisateur),
    Motif             NVARCHAR(255) NULL,
    Reference         NVARCHAR(32) NULL
);

CREATE TABLE JournalAudit (
    IDAudit           INT IDENTITY(1,1) PRIMARY KEY,
    DateHeure         DATETIME NOT NULL,
    IDUtilisateur     INT NULL REFERENCES Utilisateurs(IDUtilisateur),
    Action            NVARCHAR(64) NOT NULL,
    Detail            NTEXT NULL,
    IPPoste           NVARCHAR(45) NULL
);

-- Index
CREATE INDEX IX_Commandes_Date ON Commandes(DateHeureOuverture);
CREATE INDEX IX_Commandes_Statut ON Commandes(Statut);
CREATE INDEX IX_LignesCde_Cde ON LignesCommande(IDCommande);
CREATE INDEX IX_Factures_Date ON Factures(DateHeure);
CREATE INDEX IX_MouvStock_Date ON MouvementsStock(DateHeure);
CREATE INDEX IX_MouvStock_Ingredient ON MouvementsStock(IDIngredient);
