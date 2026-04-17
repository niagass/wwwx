// ============================================================================
//  Fenêtre : WIN_Gestion_Plats
//  CRUD des plats et gestion du menu. Admin uniquement.
// ============================================================================
//
// UI :
//   TBL_Plats           (Table : IDPlat, Catégorie, Nom, Prix, Actif, Temps)
//   COMBO_Categorie     (Combo des catégories, pour filtrer ou éditer)
//   SAI_Nom             (Saisie texte)
//   SAI_Prix            (Saisie monétaire)
//   SAI_Temps           (Saisie numérique)
//   SAI_Description     (Saisie multi-lignes)
//   INT_Actif           (Interrupteur)
//   BTN_Nouveau         (Bouton)
//   BTN_Enregistrer     (Bouton)
//   BTN_Supprimer       (Bouton)
//   BTN_Retour          (Bouton)
// ============================================================================

nIDPlatCourant est un entier   // 0 = mode "nouveau"


// @Evt: Initialisation de WIN_Gestion_Plats
    SI PAS PROC_Auth.VerifierAcces("WIN_Gestion_Plats") ALORS Ferme() ; RETOUR FIN
    RafraichirCategories()
    RafraichirPlats()
    NouveauFormulaire()


// @Evt: Clic de BTN_Nouveau
    NouveauFormulaire()

// @Evt: Clic de BTN_Retour
    Ferme()


// @Evt: Sélection changée dans TBL_Plats
    SI TBL_Plats..Occurrence = 0 ALORS RETOUR
    HLitRecherchePremier(Plats, IDPlat, TBL_Plats.COL_IDPlat)
    SI PAS HTrouve(Plats) ALORS RETOUR
    nIDPlatCourant = Plats.IDPlat
    COMBO_Categorie..ValeurMemorisée = Plats.IDCategorie
    SAI_Nom            = Plats.Nom
    SAI_Prix           = Plats.Prix
    SAI_Temps          = Plats.TempsPreparation
    SAI_Description    = Plats.Description
    INT_Actif          = Plats.Actif


// @Evt: Clic de BTN_Enregistrer
    SI SansEspace(SAI_Nom) = "" ALORS Erreur("Nom requis") ; RETOUR FIN
    SI SAI_Prix <= 0 ALORS Erreur("Prix invalide") ; RETOUR FIN
    SI COMBO_Categorie..ValeurMemorisée = 0 ALORS Erreur("Catégorie requise") ; RETOUR FIN

    nAncienPrix est un monétaire = 0
    SI nIDPlatCourant = 0 ALORS
        HRAZ(Plats)
    SINON
        HLitRecherchePremier(Plats, IDPlat, nIDPlatCourant)
        nAncienPrix = Plats.Prix
    FIN
    Plats.IDCategorie      = COMBO_Categorie..ValeurMemorisée
    Plats.Nom              = SAI_Nom
    Plats.Prix             = SAI_Prix
    Plats.Description      = SAI_Description
    Plats.TempsPreparation = SAI_Temps
    Plats.Actif            = INT_Actif
    bOk est un booléen
    SI nIDPlatCourant = 0 ALORS
        bOk = HAjoute(Plats)
        nIDPlatCourant = Plats.IDPlat
    SINON
        bOk = HModifie(Plats)
        SI bOk ET nAncienPrix <> SAI_Prix ALORS
            PROC_Utilitaires.JournaliserAction(gclUserCourant:m_IDUtilisateur, ...
                "PRIX_MODIFIE", "plat=" + nIDPlatCourant + ";ancien=" + nAncienPrix + ";nouveau=" + SAI_Prix)
        FIN
    FIN
    SI bOk ALORS
        Info("Plat enregistré.")
        RafraichirPlats()
    SINON
        Erreur("Échec enregistrement : " + HErreurInfo())
    FIN


// @Evt: Clic de BTN_Supprimer
    SI nIDPlatCourant = 0 ALORS RETOUR
    SI PAS OuiNon("Supprimer le plat sélectionné ?", "Les commandes passées sont conservées.") ALORS RETOUR
    // Soft delete = désactivation, pour conserver l'historique.
    HLitRecherchePremier(Plats, IDPlat, nIDPlatCourant)
    Plats.Actif = Faux
    HModifie(Plats)
    RafraichirPlats()
    NouveauFormulaire()


// --- Procédures locales ---

PROCEDURE RafraichirCategories()
    COMBO_Categorie..ValeursAffichées = ""
    POUR TOUT Categories TRIE PAR OrdreAffichage
        ComboAjoute(COMBO_Categorie, Categories.Nom, Categories.IDCategorie)
    FIN

PROCEDURE RafraichirPlats()
    TableRAZ(TBL_Plats)
    POUR TOUT Plats TRIE PAR IDCategorie, Nom
        HLitRecherchePremier(Categories, IDCategorie, Plats.IDCategorie)
        TableAjouteLigne(TBL_Plats, Plats.IDPlat, Categories.Nom, Plats.Nom, ...
                         PROC_Utilitaires.FormaterMontant(Plats.Prix), ...
                         SiTernaire(Plats.Actif, "Oui", "Non"), Plats.TempsPreparation)
    FIN

PROCEDURE NouveauFormulaire()
    nIDPlatCourant         = 0
    SAI_Nom                = ""
    SAI_Prix               = 0
    SAI_Temps              = 10
    SAI_Description        = ""
    INT_Actif              = Vrai
    SI COMBO_Categorie..Occurrence > 0 ALORS COMBO_Categorie = 1
