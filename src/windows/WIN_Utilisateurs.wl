// ============================================================================
//  Fenêtre : WIN_Utilisateurs
//  Administration des comptes utilisateurs (Admin uniquement).
// ============================================================================
//
// UI :
//   TBL_Utilisateurs    (Login, Nom, Prénom, Rôle, Actif)
//   SAI_Login / SAI_Nom / SAI_Prenom / SAI_Mdp / COMBO_Role / INT_Actif
//   BTN_Nouveau / BTN_Enregistrer / BTN_ResetMDP / BTN_Basculer / BTN_Retour
// ============================================================================

nIDUserCourant est un entier = 0


// @Evt: Initialisation de WIN_Utilisateurs
    SI PAS PROC_Auth.VerifierAcces("WIN_Utilisateurs") ALORS Ferme() ; RETOUR FIN
    SI PAS gclUserCourant:EstAdmin() ALORS Ferme() ; RETOUR FIN
    COMBO_Role..ValeursAffichées = "Admin" + TAB + "Caissier" + TAB + "Serveur" + TAB + "Cuisine"
    RafraichirListe()
    NouveauFormulaire()


// @Evt: Sélection changée dans TBL_Utilisateurs
    SI TBL_Utilisateurs..Occurrence = 0 ALORS RETOUR
    HLitRecherchePremier(Utilisateurs, IDUtilisateur, TBL_Utilisateurs.COL_IDUser)
    nIDUserCourant = Utilisateurs.IDUtilisateur
    SAI_Login      = Utilisateurs.Login
    SAI_Nom        = Utilisateurs.Nom
    SAI_Prenom     = Utilisateurs.Prenom
    COMBO_Role     = Utilisateurs.Role
    INT_Actif      = Utilisateurs.Actif
    SAI_Mdp        = ""


// @Evt: Clic de BTN_Nouveau
    NouveauFormulaire()

// @Evt: Clic de BTN_Retour
    Ferme()


// @Evt: Clic de BTN_Enregistrer
    SI nIDUserCourant = 0 ALORS
        // création → mdp obligatoire
        SI Taille(SAI_Mdp) < 6 ALORS Erreur("Mot de passe requis (6+ car.)") ; RETOUR FIN
        nID est un entier = PROC_Auth.CreerUtilisateur(SAI_Login, SAI_Mdp, SAI_Nom, SAI_Prenom, COMBO_Role)
        SI nID = 0 ALORS RETOUR
    SINON
        // mise à jour (sans mdp)
        HLitRecherchePremier(Utilisateurs, IDUtilisateur, nIDUserCourant)
        Utilisateurs.Login  = SAI_Login
        Utilisateurs.Nom    = SAI_Nom
        Utilisateurs.Prenom = SAI_Prenom
        Utilisateurs.Role   = COMBO_Role
        Utilisateurs.Actif  = INT_Actif
        HModifie(Utilisateurs)
    FIN
    Info("Enregistré.")
    RafraichirListe()


// @Evt: Clic de BTN_ResetMDP
    SI nIDUserCourant = 0 ALORS RETOUR
    sNouveau est une chaîne = Saisie("Nouveau mot de passe (6+ car.)", "")
    SI Taille(sNouveau) < 6 ALORS Erreur("Trop court") ; RETOUR FIN
    SI PROC_Auth.ReinitialiserMDP(nIDUserCourant, sNouveau) ALORS
        Info("Mot de passe réinitialisé.")
    FIN


// @Evt: Clic de BTN_Basculer
    SI nIDUserCourant = 0 ALORS RETOUR
    SI nIDUserCourant = gclUserCourant:m_IDUtilisateur ALORS
        Erreur("Impossible de se désactiver soi-même.")
        RETOUR
    FIN
    SI PROC_Auth.BasculerActif(nIDUserCourant) ALORS RafraichirListe()


// --- Procédures locales ---

PROCEDURE RafraichirListe()
    TableRAZ(TBL_Utilisateurs)
    POUR TOUT Utilisateurs TRIE PAR Login
        TableAjouteLigne(TBL_Utilisateurs, Utilisateurs.IDUtilisateur, Utilisateurs.Login, ...
                         Utilisateurs.Nom, Utilisateurs.Prenom, Utilisateurs.Role, ...
                         SiTernaire(Utilisateurs.Actif, "Oui", "Non"))
    FIN

PROCEDURE NouveauFormulaire()
    nIDUserCourant = 0
    SAI_Login = "" ; SAI_Nom = "" ; SAI_Prenom = "" ; SAI_Mdp = ""
    COMBO_Role = "Serveur"
    INT_Actif  = Vrai
