// ============================================================================
//  Ensemble de procédures globales : PROC_Init
//  Création des fichiers HFSQL au 1er lancement + jeu de données de démo.
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

// Peuple la base avec un jeu de données d'exemple. Idempotent : ne refait pas
// si un utilisateur "admin" existe déjà.
PROCEDURE InitialiserDonneesExemple()
    HLitRecherchePremier(Utilisateurs, Login, "admin")
    SI HTrouve(Utilisateurs) ALORS RETOUR     // déjà initialisé

    // -- Utilisateur admin
    sSel est une chaîne = PROC_Utilitaires.GenererSel()
    HRAZ(Utilisateurs)
    Utilisateurs.Login          = "admin"
    Utilisateurs.SelMDP         = sSel
    Utilisateurs.MotDePasseHash = PROC_Utilitaires.HasherMDP("admin", sSel)
    Utilisateurs.Nom            = "Admin"
    Utilisateurs.Prenom         = "Compte"
    Utilisateurs.Role           = "Admin"
    Utilisateurs.Actif          = Vrai
    Utilisateurs.DateCreation   = DateHeureSys()
    HAjoute(Utilisateurs)

    // -- Serveur et caissier de démo (mdp = "demo")
    POUR EACH trio PARMI [["serveur1", "Serveur"], ["caisse1", "Caissier"], ["cuisine1", "Cuisine"]]
        sSelD est une chaîne = PROC_Utilitaires.GenererSel()
        HRAZ(Utilisateurs)
        Utilisateurs.Login          = trio[1]
        Utilisateurs.SelMDP         = sSelD
        Utilisateurs.MotDePasseHash = PROC_Utilitaires.HasherMDP("demo", sSelD)
        Utilisateurs.Nom            = "Démo"
        Utilisateurs.Prenom         = trio[1]
        Utilisateurs.Role           = trio[2]
        Utilisateurs.Actif          = Vrai
        Utilisateurs.DateCreation   = DateHeureSys()
        HAjoute(Utilisateurs)
    FIN

    // -- Catégories
    POUR i = 1 À 3
        HRAZ(Categories)
        SELON i
            CAS 1 Categories.Nom = "Entrées"  ; Categories.OrdreAffichage = 1 ; Categories.CouleurRGB = RVB(200, 230, 200)
            CAS 2 Categories.Nom = "Plats"    ; Categories.OrdreAffichage = 2 ; Categories.CouleurRGB = RVB(230, 210, 180)
            CAS 3 Categories.Nom = "Desserts" ; Categories.OrdreAffichage = 3 ; Categories.CouleurRGB = RVB(230, 200, 230)
        FIN
        HAjoute(Categories)
    FIN

    // -- Plats
    PROCEDURE INTERNE AjoutPlat(sCat est une chaîne, sNom est une chaîne, nPrix est un monétaire, nTemps est un entier)
        HLitRecherchePremier(Categories, Nom, sCat)
        HRAZ(Plats)
        Plats.IDCategorie      = Categories.IDCategorie
        Plats.Nom              = sNom
        Plats.Prix             = nPrix
        Plats.Actif            = Vrai
        Plats.TempsPreparation = nTemps
        HAjoute(Plats)
    FIN
    AjoutPlat("Entrées", "Salade César",     8.50, 7)
    AjoutPlat("Entrées", "Soupe à l'oignon", 7.00, 10)
    AjoutPlat("Entrées", "Terrine maison",   9.00, 5)
    AjoutPlat("Entrées", "Œuf mimosa",       6.50, 5)
    AjoutPlat("Plats",   "Steak frites",    18.00, 15)
    AjoutPlat("Plats",   "Magret de canard",22.00, 20)
    AjoutPlat("Plats",   "Poisson du jour", 19.00, 18)
    AjoutPlat("Plats",   "Risotto",         16.00, 15)
    AjoutPlat("Desserts","Crème brûlée",     7.00, 3)
    AjoutPlat("Desserts","Tarte Tatin",      7.50, 3)
    AjoutPlat("Desserts","Mousse chocolat",  6.50, 2)
    AjoutPlat("Desserts","Café gourmand",    8.00, 3)

    // -- Tables (20 tables réparties en zones)
    POUR i = 1 À 20
        HRAZ(Tables)
        Tables.Numero    = i
        Tables.Capacite  = SiTernaire(i <= 10, 2, 4)
        Tables.Statut    = "Libre"
        Tables.Zone      = SiTernaire(i <= 10, "Salle", "Terrasse")
        HAjoute(Tables)
    FIN

    // -- Ingrédients de démo
    PROCEDURE INTERNE AjoutIng(sNom est une chaîne, sUnite est une chaîne, nStock est un réel, nMin est un réel, nPrix est un monétaire)
        HRAZ(Ingredients)
        Ingredients.Nom               = sNom
        Ingredients.Unite             = sUnite
        Ingredients.StockActuel       = nStock
        Ingredients.StockMin          = nMin
        Ingredients.PrixAchatUnitaire = nPrix
        HAjoute(Ingredients)
    FIN
    AjoutIng("Pomme de terre", "kg",    20.0, 5.0,  1.20)
    AjoutIng("Bœuf",           "kg",     8.0, 2.0, 18.00)
    AjoutIng("Salade",         "pièce", 15,   3,    0.80)
    AjoutIng("Œuf",            "pièce", 60,  12,    0.20)
    AjoutIng("Chocolat",       "kg",     2.0, 0.5, 12.00)
    AjoutIng("Farine",         "kg",    10.0, 2.0,  0.90)
    AjoutIng("Crème",          "L",      4.0, 1.0,  3.50)

    // -- Compositions (simplifiées)
    PROCEDURE INTERNE AjoutComposition(sPlat est une chaîne, sIng est une chaîne, nQte est un réel)
        HLitRecherchePremier(Plats, Nom, sPlat)
        nIDPlat est un entier = Plats.IDPlat
        HLitRecherchePremier(Ingredients, Nom, sIng)
        nIDIng est un entier = Ingredients.IDIngredient
        HRAZ(PlatsIngredients)
        PlatsIngredients.IDPlat       = nIDPlat
        PlatsIngredients.IDIngredient = nIDIng
        PlatsIngredients.Quantite     = nQte
        HAjoute(PlatsIngredients)
    FIN
    AjoutComposition("Steak frites",     "Bœuf",          0.25)
    AjoutComposition("Steak frites",     "Pomme de terre",0.30)
    AjoutComposition("Salade César",     "Salade",        1)
    AjoutComposition("Salade César",     "Œuf",           1)
    AjoutComposition("Crème brûlée",     "Œuf",           2)
    AjoutComposition("Crème brûlée",     "Crème",         0.20)
    AjoutComposition("Mousse chocolat",  "Chocolat",      0.10)
    AjoutComposition("Mousse chocolat",  "Œuf",           2)
    AjoutComposition("Tarte Tatin",      "Pomme de terre",0) // placeholder (pomme)
    AjoutComposition("Tarte Tatin",      "Farine",        0.10)

    Info("Données d'exemple créées. Connexion : admin / admin")
