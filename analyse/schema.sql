-- ============================================================================
--  Script SQL d'analyse RestoManager — SYNTAXE HFSQL (WinDev 23)
--  ----------------------------------------------------------------------------
--  Utilisation :
--    1. Dans WinDev 23, ouvrir l'analyse (.WDA).
--    2. Menu  *Analyse*  ->  *Import*  ->  *Script SQL...*
--    3. Sélectionner ce fichier. Choisir "HFSQL" comme dialecte cible.
--
--  Remarque : ce script est écrit en syntaxe HFSQL native. Les types sont ceux
--  acceptés par l'éditeur d'analyse (VARCHAR, INT, BOOLEAN, NUMERIC, TEXT,
--  BLOB, DATETIME). Les clés auto sont déclarées avec AUTO_INCREMENT. Les
--  contraintes de clé étrangère sont posées *après* la création des tables
--  (ALTER TABLE) pour éviter les problèmes d'ordre de dépendance à l'import.
--
--  Si l'import échoue malgré tout (la compatibilité de l'importeur SQL de
--  WinDev 23 varie suivant les patchs), recréez les fichiers manuellement
--  dans l'éditeur d'analyse en suivant `analyse/schema_hfsql.txt` et le
--  guide `docs/CREATION_ANALYSE_WINDEV.md`.
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Tables principales
-- ----------------------------------------------------------------------------

CREATE TABLE Utilisateurs (
    IDUtilisateur   INT AUTO_INCREMENT PRIMARY KEY,
    Login           VARCHAR(32)  NOT NULL,
    MotDePasseHash  VARCHAR(64)  NOT NULL,
    SelMDP          VARCHAR(32)  NOT NULL,
    Nom             VARCHAR(64)  NOT NULL,
    Prenom          VARCHAR(64)  NOT NULL,
    Role            VARCHAR(16)  NOT NULL,
    Actif           BOOLEAN      NOT NULL DEFAULT 1,
    DateCreation    DATETIME     NOT NULL
);
CREATE UNIQUE INDEX IX_Utilisateurs_Login ON Utilisateurs(Login);

CREATE TABLE Categories (
    IDCategorie     INT AUTO_INCREMENT PRIMARY KEY,
    Nom             VARCHAR(32)  NOT NULL,
    OrdreAffichage  INT          NOT NULL DEFAULT 0,
    CouleurRGB      INT          NOT NULL DEFAULT 0
);
CREATE UNIQUE INDEX IX_Categories_Nom ON Categories(Nom);

CREATE TABLE Plats (
    IDPlat            INT AUTO_INCREMENT PRIMARY KEY,
    IDCategorie       INT           NOT NULL,
    Nom               VARCHAR(64)   NOT NULL,
    Description       TEXT,
    Prix              NUMERIC(10,2) NOT NULL,
    Actif             BOOLEAN       NOT NULL DEFAULT 1,
    TempsPreparation  INT           NOT NULL DEFAULT 10,
    Image             BLOB
);

CREATE TABLE Ingredients (
    IDIngredient       INT AUTO_INCREMENT PRIMARY KEY,
    Nom                VARCHAR(64)   NOT NULL,
    Unite              VARCHAR(8)    NOT NULL,
    StockActuel        NUMERIC(12,3) NOT NULL DEFAULT 0,
    StockMin           NUMERIC(12,3) NOT NULL DEFAULT 0,
    PrixAchatUnitaire  NUMERIC(10,2) NOT NULL DEFAULT 0
);
CREATE UNIQUE INDEX IX_Ingredients_Nom ON Ingredients(Nom);

CREATE TABLE PlatsIngredients (
    IDPlat        INT           NOT NULL,
    IDIngredient  INT           NOT NULL,
    Quantite      NUMERIC(12,3) NOT NULL,
    PRIMARY KEY (IDPlat, IDIngredient)
);

CREATE TABLE Tables (
    IDTable   INT AUTO_INCREMENT PRIMARY KEY,
    Numero    INT          NOT NULL,
    Capacite  INT          NOT NULL DEFAULT 2,
    Statut    VARCHAR(16)  NOT NULL DEFAULT 'Libre',
    Zone      VARCHAR(32)
);
CREATE UNIQUE INDEX IX_Tables_Numero ON Tables(Numero);

CREATE TABLE Clients (
    IDClient   INT AUTO_INCREMENT PRIMARY KEY,
    Nom        VARCHAR(64)  NOT NULL,
    Prenom     VARCHAR(64),
    Telephone  VARCHAR(20),
    Email      VARCHAR(128),
    Notes      TEXT
);

CREATE TABLE Reservations (
    IDReservation  INT AUTO_INCREMENT PRIMARY KEY,
    IDClient       INT          NOT NULL,
    IDTable        INT          NOT NULL,
    DateHeure      DATETIME     NOT NULL,
    NbPersonnes    INT          NOT NULL DEFAULT 1,
    Statut         VARCHAR(16)  NOT NULL DEFAULT 'Attente',
    Notes          TEXT
);

CREATE TABLE Commandes (
    IDCommande          INT AUTO_INCREMENT PRIMARY KEY,
    IDTable             INT           NOT NULL,
    IDServeur           INT           NOT NULL,
    DateHeureOuverture  DATETIME      NOT NULL,
    DateHeureCloture    DATETIME,
    Statut              VARCHAR(16)   NOT NULL DEFAULT 'EnCours',
    Notes               TEXT,
    TotalHT             NUMERIC(10,2) NOT NULL DEFAULT 0,
    TotalTVA            NUMERIC(10,2) NOT NULL DEFAULT 0,
    TotalTTC            NUMERIC(10,2) NOT NULL DEFAULT 0
);

CREATE TABLE LignesCommande (
    IDLigne       INT AUTO_INCREMENT PRIMARY KEY,
    IDCommande    INT           NOT NULL,
    IDPlat        INT           NOT NULL,
    Quantite      INT           NOT NULL DEFAULT 1,
    PrixUnitaire  NUMERIC(10,2) NOT NULL,
    Notes         VARCHAR(255),
    Statut        VARCHAR(16)   NOT NULL DEFAULT 'Attente'
);

CREATE TABLE Factures (
    IDFacture      INT AUTO_INCREMENT PRIMARY KEY,
    IDCommande     INT           NOT NULL,
    NumeroFacture  VARCHAR(20)   NOT NULL,
    DateHeure      DATETIME      NOT NULL,
    IDCaissier     INT           NOT NULL,
    TotalHT        NUMERIC(10,2) NOT NULL,
    TotalTVA       NUMERIC(10,2) NOT NULL,
    TotalTTC       NUMERIC(10,2) NOT NULL,
    ModePaiement   VARCHAR(16)   NOT NULL,
    MontantRecu    NUMERIC(10,2) NOT NULL,
    Rendu          NUMERIC(10,2) NOT NULL DEFAULT 0
);
CREATE UNIQUE INDEX IX_Factures_IDCommande ON Factures(IDCommande);
CREATE UNIQUE INDEX IX_Factures_Numero    ON Factures(NumeroFacture);

CREATE TABLE MouvementsStock (
    IDMouvement    INT AUTO_INCREMENT PRIMARY KEY,
    IDIngredient   INT           NOT NULL,
    TypeMouvement  VARCHAR(16)   NOT NULL,
    Quantite       NUMERIC(12,3) NOT NULL,
    DateHeure      DATETIME      NOT NULL,
    IDUtilisateur  INT           NOT NULL,
    Motif          VARCHAR(255),
    Reference      VARCHAR(32)
);

CREATE TABLE JournalAudit (
    IDAudit        INT AUTO_INCREMENT PRIMARY KEY,
    DateHeure      DATETIME      NOT NULL,
    IDUtilisateur  INT,
    Action         VARCHAR(64)   NOT NULL,
    Detail         TEXT,
    IPPoste        VARCHAR(45)
);

-- ----------------------------------------------------------------------------
-- Clés étrangères (posées après coup pour éviter les dépendances à l'import)
-- ----------------------------------------------------------------------------

ALTER TABLE Plats
    ADD CONSTRAINT FK_Plats_Categorie
    FOREIGN KEY (IDCategorie) REFERENCES Categories(IDCategorie);

ALTER TABLE PlatsIngredients
    ADD CONSTRAINT FK_PI_Plat
    FOREIGN KEY (IDPlat) REFERENCES Plats(IDPlat);

ALTER TABLE PlatsIngredients
    ADD CONSTRAINT FK_PI_Ingredient
    FOREIGN KEY (IDIngredient) REFERENCES Ingredients(IDIngredient);

ALTER TABLE Reservations
    ADD CONSTRAINT FK_Res_Client
    FOREIGN KEY (IDClient) REFERENCES Clients(IDClient);

ALTER TABLE Reservations
    ADD CONSTRAINT FK_Res_Table
    FOREIGN KEY (IDTable) REFERENCES Tables(IDTable);

ALTER TABLE Commandes
    ADD CONSTRAINT FK_Cmd_Table
    FOREIGN KEY (IDTable) REFERENCES Tables(IDTable);

ALTER TABLE Commandes
    ADD CONSTRAINT FK_Cmd_Serveur
    FOREIGN KEY (IDServeur) REFERENCES Utilisateurs(IDUtilisateur);

ALTER TABLE LignesCommande
    ADD CONSTRAINT FK_LCde_Cde
    FOREIGN KEY (IDCommande) REFERENCES Commandes(IDCommande);

ALTER TABLE LignesCommande
    ADD CONSTRAINT FK_LCde_Plat
    FOREIGN KEY (IDPlat) REFERENCES Plats(IDPlat);

ALTER TABLE Factures
    ADD CONSTRAINT FK_Fac_Cde
    FOREIGN KEY (IDCommande) REFERENCES Commandes(IDCommande);

ALTER TABLE Factures
    ADD CONSTRAINT FK_Fac_Caissier
    FOREIGN KEY (IDCaissier) REFERENCES Utilisateurs(IDUtilisateur);

ALTER TABLE MouvementsStock
    ADD CONSTRAINT FK_Mvt_Ingredient
    FOREIGN KEY (IDIngredient) REFERENCES Ingredients(IDIngredient);

ALTER TABLE MouvementsStock
    ADD CONSTRAINT FK_Mvt_Utilisateur
    FOREIGN KEY (IDUtilisateur) REFERENCES Utilisateurs(IDUtilisateur);

ALTER TABLE JournalAudit
    ADD CONSTRAINT FK_Audit_Utilisateur
    FOREIGN KEY (IDUtilisateur) REFERENCES Utilisateurs(IDUtilisateur);

-- ----------------------------------------------------------------------------
-- Index non uniques (pour les recherches fréquentes)
-- ----------------------------------------------------------------------------

CREATE INDEX IX_Cmd_Date     ON Commandes(DateHeureOuverture);
CREATE INDEX IX_Cmd_Statut   ON Commandes(Statut);
CREATE INDEX IX_LCde_Cde     ON LignesCommande(IDCommande);
CREATE INDEX IX_Fac_Date     ON Factures(DateHeure);
CREATE INDEX IX_Mvt_Date     ON MouvementsStock(DateHeure);
CREATE INDEX IX_Mvt_Ing      ON MouvementsStock(IDIngredient);
CREATE INDEX IX_Res_Date     ON Reservations(DateHeure);
CREATE INDEX IX_Audit_Date   ON JournalAudit(DateHeure);
