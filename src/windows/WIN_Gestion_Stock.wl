// ============================================================================
//  Fenêtre : WIN_Gestion_Stock
//  Liste des ingrédients, mouvements, inventaire.
// ============================================================================
//
// UI :
//   TBL_Ingredients     (Table : IDIng, Nom, Unité, Stock, Min, Prix, Valeur)
//   TBL_Mouvements      (Table historique : Date, Type, Qté, Motif, User)
//   SAI_Nom             / SAI_Unite / SAI_StockMin / SAI_PrixAchat (CRUD ingrédient)
//   BTN_NouveauIng / BTN_EnregistrerIng / BTN_SupprimerIng
//   RADIO_TypeMvt       (Entree / Sortie / Ajustement)
//   SAI_QteMvt / SAI_MotifMvt
//   BTN_AjouterMvt
//   BTN_ExportCSV
//   BTN_Retour
//   LIB_ValeurStock
//   LIB_Alerte          (rouge si sous seuil)
// ============================================================================

nIDIngCourant est un entier = 0


// @Evt: Initialisation de WIN_Gestion_Stock
    SI PAS PROC_Auth.VerifierAcces("WIN_Gestion_Stock") ALORS Ferme() ; RETOUR FIN
    RafraichirIngredients()
    NouveauFormulaire()


// @Evt: Sélection changée dans TBL_Ingredients
    SI TBL_Ingredients..Occurrence = 0 ALORS RETOUR
    HLitRecherchePremier(Ingredients, IDIngredient, TBL_Ingredients.COL_IDIng)
    SI PAS HTrouve(Ingredients) ALORS RETOUR
    nIDIngCourant       = Ingredients.IDIngredient
    SAI_Nom             = Ingredients.Nom
    SAI_Unite           = Ingredients.Unite
    SAI_StockMin        = Ingredients.StockMin
    SAI_PrixAchat       = Ingredients.PrixAchatUnitaire
    LIB_Alerte..Visible = Ingredients.StockActuel <= Ingredients.StockMin
    RafraichirMouvements(nIDIngCourant)


// @Evt: Clic de BTN_NouveauIng
    NouveauFormulaire()


// @Evt: Clic de BTN_EnregistrerIng
    SI SansEspace(SAI_Nom) = "" ALORS Erreur("Nom requis") ; RETOUR FIN
    SI SansEspace(SAI_Unite) = "" ALORS Erreur("Unité requise") ; RETOUR FIN
    SI SAI_StockMin < 0 OU SAI_PrixAchat < 0 ALORS Erreur("Valeurs négatives refusées") ; RETOUR FIN
    SI nIDIngCourant = 0 ALORS
        HRAZ(Ingredients)
        Ingredients.StockActuel = 0
    SINON
        HLitRecherchePremier(Ingredients, IDIngredient, nIDIngCourant)
    FIN
    Ingredients.Nom               = SAI_Nom
    Ingredients.Unite             = SAI_Unite
    Ingredients.StockMin          = SAI_StockMin
    Ingredients.PrixAchatUnitaire = SAI_PrixAchat
    SI nIDIngCourant = 0 ALORS
        HAjoute(Ingredients)
        nIDIngCourant = Ingredients.IDIngredient
    SINON
        HModifie(Ingredients)
    FIN
    Info("Ingrédient enregistré.")
    RafraichirIngredients()


// @Evt: Clic de BTN_SupprimerIng
    SI nIDIngCourant = 0 ALORS RETOUR
    // Vérifier qu'aucun plat ne l'utilise.
    HLitRecherchePremier(PlatsIngredients, IDIngredient, nIDIngCourant)
    SI HTrouve(PlatsIngredients) ALORS
        Erreur("Ingrédient utilisé par au moins un plat. Retirez-le des compositions d'abord.")
        RETOUR
    FIN
    SI PAS OuiNon("Supprimer cet ingrédient ? (les mouvements seront conservés)") ALORS RETOUR
    HLitRecherchePremier(Ingredients, IDIngredient, nIDIngCourant)
    HSupprime(Ingredients)
    NouveauFormulaire()
    RafraichirIngredients()


// @Evt: Clic de BTN_AjouterMvt
    SI nIDIngCourant = 0 ALORS Erreur("Sélectionnez un ingrédient") ; RETOUR FIN
    SI SAI_QteMvt <= 0 ALORS Erreur("Quantité invalide") ; RETOUR FIN
    sType est une chaîne
    SELON RADIO_TypeMvt
        CAS 1 sType = "Entree"
        CAS 2 sType = "Sortie"
        CAS 3 sType = "Ajustement"
    FIN
    oStk est un cStock
    oStk:Charger(nIDIngCourant)
    SI oStk:AjouterMouvement(sType, SAI_QteMvt, gclUserCourant:m_IDUtilisateur, SAI_MotifMvt) ALORS
        Info("Mouvement enregistré.")
        SAI_QteMvt    = 0
        SAI_MotifMvt  = ""
        RafraichirIngredients()
        RafraichirMouvements(nIDIngCourant)
    SINON
        Erreur("Échec du mouvement.")
    FIN


// @Evt: Clic de BTN_ExportCSV
    sChemin est une chaîne = fSélecteur("", "", "Export stock", "CSV (*.csv)" + TAB + "*.csv", ...
                                        "csv", fselCrée)
    SI sChemin = "" ALORS RETOUR
    SI PROC_Utilitaires.ExporterTableCSV(TBL_Ingredients, sChemin) ALORS
        Info("Export OK.")
    SINON
        Erreur("Export en échec.")
    FIN


// @Evt: Clic de BTN_Retour
    Ferme()


// --- Procédures locales ---

PROCEDURE RafraichirIngredients()
    TableRAZ(TBL_Ingredients)
    POUR TOUT Ingredients TRIE PAR Nom
        nValeur est un monétaire = Ingredients.StockActuel * Ingredients.PrixAchatUnitaire
        nCouleur est un entier = SiTernaire(Ingredients.StockActuel <= Ingredients.StockMin, ...
                                            RVB(250, 210, 210), Blanc)
        TableAjouteLigne(TBL_Ingredients, ...
            Ingredients.IDIngredient, Ingredients.Nom, Ingredients.Unite, ...
            Ingredients.StockActuel, Ingredients.StockMin, ...
            PROC_Utilitaires.FormaterMontant(Ingredients.PrixAchatUnitaire), ...
            PROC_Utilitaires.FormaterMontant(nValeur), nCouleur)
    FIN
    LIB_ValeurStock = "Valeur totale du stock : " + PROC_Utilitaires.FormaterMontant(PROC_Stock.ValeurStock())

PROCEDURE RafraichirMouvements(nIDIng est un entier)
    TableRAZ(TBL_Mouvements)
    POUR TOUT MouvementsStock AVEC IDIngredient = nIDIng TRIE PAR -DateHeure
        HLitRecherchePremier(Utilisateurs, IDUtilisateur, MouvementsStock.IDUtilisateur)
        TableAjouteLigne(TBL_Mouvements, ...
            DateHeureVersChaîne(MouvementsStock.DateHeure, "JJ/MM/AAAA HH:MM"), ...
            MouvementsStock.TypeMouvement, ...
            MouvementsStock.Quantite, ...
            MouvementsStock.Motif, ...
            Utilisateurs.Login)
    FIN

PROCEDURE NouveauFormulaire()
    nIDIngCourant       = 0
    SAI_Nom             = ""
    SAI_Unite           = ""
    SAI_StockMin        = 0
    SAI_PrixAchat       = 0
    SAI_QteMvt          = 0
    SAI_MotifMvt        = ""
    RADIO_TypeMvt       = 1
    LIB_Alerte..Visible = Faux
    TableRAZ(TBL_Mouvements)
