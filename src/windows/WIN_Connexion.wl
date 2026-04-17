// ============================================================================
//  Fenêtre : WIN_Connexion
//  Authentification initiale.
// ============================================================================
//
// UI (à créer dans l'IDE WinDev) :
//   SAI_Login       (Champ de saisie,   libellé "Identifiant")
//   SAI_MotDePasse  (Champ de saisie,   libellé "Mot de passe", option "mot de passe")
//   BTN_Connecter   (Bouton,            libellé "Se connecter", bouton par défaut)
//   BTN_Quitter     (Bouton,            libellé "Quitter")
//   IMG_Logo        (Image statique,    logo du resto)
//   LIB_Message     (Libellé,           couleur rouge, invisible par défaut)
// ============================================================================


// @Evt: Initialisation de WIN_Connexion
    // Assure l'existence des fichiers HFSQL et du compte admin au premier lancement.
    PROC_Init.InitialiserFichiers()
    PROC_Init.InitialiserDonneesExemple()
    SAI_Login = "admin"
    SAI_MotDePasse = ""
    LIB_Message..Visible = Faux


// @Evt: Clic de BTN_Connecter
    LIB_Message..Visible = Faux
    SI SansEspace(SAI_Login) = "" ALORS
        LIB_Message = "Identifiant requis"
        LIB_Message..Visible = Vrai
        PriseFocus(SAI_Login)
        RETOUR
    FIN
    SI SansEspace(SAI_MotDePasse) = "" ALORS
        LIB_Message = "Mot de passe requis"
        LIB_Message..Visible = Vrai
        PriseFocus(SAI_MotDePasse)
        RETOUR
    FIN

    SI PAS PROC_Auth.Connecter(SAI_Login, SAI_MotDePasse) ALORS
        LIB_Message = "Identifiant ou mot de passe invalide"
        LIB_Message..Visible = Vrai
        RETOUR
    FIN

    // Succès → ouvre le menu principal puis ferme
    Ouvre(WIN_Menu_Principal)
    Ferme()


// @Evt: Clic de BTN_Quitter
    SI OuiNon("Quitter l'application ?") ALORS
        FinProgramme()
    FIN
