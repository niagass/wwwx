// ============================================================================
//  Ensemble de procédures globales : PROC_Init
//  Création des fichiers HFSQL au 1er lancement + jeu de données de démo.
//  >>> Compatible WinDev 23 (pas de PROCEDURE INTERNE, pas de tableaux
//      littéraux multidim) <<<
// ============================================================================

// À appeler dans PROJET.Initialisation.
PROCEDURE InitialiserFichiers()
    // HCréationSiInexistant crée les .FIC/.NDX/.MMO si absents.
    HCréationSiInexistant(Utilisateurs)
    HCréationSiInexistant(Categories)
    HCréationSiInexistant(Plats)
    HCréationSiInexistant(Ingredients)
    HCréationSiInexistant(PlatsIngredients)
    HCréationSiInexistant(Tables)
    HCréationSiInexistant(Clients)
    HCréationSiInexistant(Reservations)
    HCréationSiInexistant(Commandes)
    HCréationSiInexistant(LignesCommande)
    HCréationSiInexistant(Factures)
    HCréationSiInexistant(MouvementsStock)
    HCréationSiInexistant(JournalAudit)

// ----------------------------------------------------------------------------
// Helpers d'insertion (procédures globales au lieu de PROCEDURE INTERNE,
// qui n'existe qu'à partir de WinDev 24).
// ----------------------------------------------------------------------------

PROCEDURE CreerUtilisateurDemo(sLogin est une chaîne, sMdp est une chaîne, ...
                               sRole est une chaîne, sNom est une chaîne, ...
                               sPrenom est une chaîne)
    sSel est une chaîne = PROC_Utilitaires.GenererSel()
    HRAZ(Utilisateurs)
    Utilisateurs.Login          = sLogin
    Utilisateurs.SelMDP         = sSel
    Utilisateurs.MotDePasseHash = PROC_Utilitaires.HasherMDP(sMdp, sSel)
    Utilisateurs.Nom            = sNom
    Utilisateurs.Prenom         = sPrenom
    Utilisateurs.Role           = sRole
    Utilisateurs.Actif          = Vrai
    Utilisateurs.DateCreation   = DateHeureSys()
    HAjoute(Utilisateurs)

PROCEDURE CreerCategorie(sNom est une chaîne, nOrdre est un entier, nCouleur est un entier)
    HRAZ(Categories)
    Categories.Nom            = sNom
    Categories.OrdreAffichage = nOrdre
    Categories.CouleurRGB     = nCouleur
    HAjoute(Categories)

PROCEDURE CreerPlat(sCategorie est une chaîne, sNom est une chaîne, ...
                    nPrix est un monétaire, nTempsPrep est un entier)
    HLitRecherchePremier(Categories, Nom, sCategorie)
    SI PAS HTrouve(Categories) ALORS RETOUR
    HRAZ(Plats)
    Plats.IDCategorie      = Categories.IDCategorie
    Plats.Nom              = sNom
    Plats.Prix             = nPrix
    Plats.Actif            = Vrai
    Plats.TempsPreparation = nTempsPrep
    HAjoute(Plats)

PROCEDURE CreerIngredient(sNom est une chaîne, sUnite est une chaîne, ...
                          nStock est un réel, nMin est un réel, nPrix est un monétaire)
    HRAZ(Ingredients)
    Ingredients.Nom               = sNom
    Ingredients.Unite             = sUnite
    Ingredients.StockActuel       = nStock
    Ingredients.StockMin          = nMin
    Ingredients.PrixAchatUnitaire = nPrix
    HAjoute(Ingredients)

PROCEDURE CreerComposition(sPlat est une chaîne, sIngredient est une chaîne, nQte est un réel)
    HLitRecherchePremier(Plats, Nom, sPlat)
    SI PAS HTrouve(Plats) ALORS RETOUR
    nIDPlat est un entier = Plats.IDPlat
    HLitRecherchePremier(Ingredients, Nom, sIngredient)
    SI PAS HTrouve(Ingredients) ALORS RETOUR
    nIDIng est un entier = Ingredients.IDIngredient
    HRAZ(PlatsIngredients)
    PlatsIngredients.IDPlat       = nIDPlat
    PlatsIngredients.IDIngredient = nIDIng
    PlatsIngredients.Quantite     = nQte
    HAjoute(PlatsIngredients)

PROCEDURE CreerTableResto(nNumero est un entier, nCapacite est un entier, sZone est une chaîne)
    HRAZ(Tables)
    Tables.Numero   = nNumero
    Tables.Capacite = nCapacite
    Tables.Statut   = "Libre"
    Tables.Zone     = sZone
    HAjoute(Tables)

// ----------------------------------------------------------------------------
// Peuple la base avec un jeu de données d'exemple.
// Idempotent : ne refait rien si l'utilisateur "admin" existe déjà.
// ----------------------------------------------------------------------------
PROCEDURE InitialiserDonneesExemple()
    HLitRecherchePremier(Utilisateurs, Login, "admin")
    SI HTrouve(Utilisateurs) ALORS RETOUR

    // -- Utilisateurs
    CreerUtilisateurDemo("admin",    "admin", "Admin",    "Admin", "Compte")
    CreerUtilisateurDemo("serveur1", "demo",  "Serveur",  "Démo",  "serveur1")
    CreerUtilisateurDemo("caisse1",  "demo",  "Caissier", "Démo",  "caisse1")
    CreerUtilisateurDemo("cuisine1", "demo",  "Cuisine",  "Démo",  "cuisine1")

    // -- Catégories
    CreerCategorie("Entrées",  1, RVB(200, 230, 200))
    CreerCategorie("Plats",    2, RVB(230, 210, 180))
    CreerCategorie("Desserts", 3, RVB(230, 200, 230))

    // -- Plats
    CreerPlat("Entrées",  "Salade César",      8.50,  7)
    CreerPlat("Entrées",  "Soupe à l'oignon",  7.00, 10)
    CreerPlat("Entrées",  "Terrine maison",    9.00,  5)
    CreerPlat("Entrées",  "Œuf mimosa",        6.50,  5)
    CreerPlat("Plats",    "Steak frites",     18.00, 15)
    CreerPlat("Plats",    "Magret de canard", 22.00, 20)
    CreerPlat("Plats",    "Poisson du jour",  19.00, 18)
    CreerPlat("Plats",    "Risotto",          16.00, 15)
    CreerPlat("Desserts", "Crème brûlée",      7.00,  3)
    CreerPlat("Desserts", "Tarte Tatin",       7.50,  3)
    CreerPlat("Desserts", "Mousse chocolat",   6.50,  2)
    CreerPlat("Desserts", "Café gourmand",     8.00,  3)

    // -- Tables (20 tables réparties en zones)
    i est un entier
    POUR i = 1 À 20
        SI i <= 10 ALORS
            CreerTableResto(i, 2, "Salle")
        SINON
            CreerTableResto(i, 4, "Terrasse")
        FIN
    FIN

    // -- Ingrédients de démo
    CreerIngredient("Pomme de terre", "kg",    20.0, 5.0,  1.20)
    CreerIngredient("Bœuf",           "kg",     8.0, 2.0, 18.00)
    CreerIngredient("Salade",         "pièce", 15,   3,    0.80)
    CreerIngredient("Œuf",            "pièce", 60,  12,    0.20)
    CreerIngredient("Chocolat",       "kg",     2.0, 0.5, 12.00)
    CreerIngredient("Farine",         "kg",    10.0, 2.0,  0.90)
    CreerIngredient("Crème",          "L",      4.0, 1.0,  3.50)

    // -- Compositions simplifiées
    CreerComposition("Steak frites",    "Bœuf",           0.25)
    CreerComposition("Steak frites",    "Pomme de terre", 0.30)
    CreerComposition("Salade César",    "Salade",         1)
    CreerComposition("Salade César",    "Œuf",            1)
    CreerComposition("Crème brûlée",    "Œuf",            2)
    CreerComposition("Crème brûlée",    "Crème",          0.20)
    CreerComposition("Mousse chocolat", "Chocolat",       0.10)
    CreerComposition("Mousse chocolat", "Œuf",            2)
    CreerComposition("Tarte Tatin",     "Farine",         0.10)

    Info("Données d'exemple créées. Connexion : admin / admin")
