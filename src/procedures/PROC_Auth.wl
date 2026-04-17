// ============================================================================
//  Ensemble de procédures globales : PROC_Auth
//  Authentification, contrôle d'accès.
// ============================================================================

// Variable globale : utilisateur courant. Accessible partout.
gclUserCourant est un cUtilisateur          // déclarer en global du projet

// Tentative de connexion. Renvoie Vrai si OK et initialise gclUserCourant.
PROCEDURE Connecter(sLogin est une chaîne, sMdp est une chaîne) : booléen
    HLitRecherchePremier(Utilisateurs, Login, sLogin)
    SI PAS HTrouve(Utilisateurs) ALORS
        PROC_Utilitaires.JournaliserAction(0, "LOGIN_ECHEC", "login=" + sLogin + ";raison=inconnu")
        RENVOYER Faux
    FIN
    SI PAS Utilisateurs.Actif ALORS
        PROC_Utilitaires.JournaliserAction(Utilisateurs.IDUtilisateur, "LOGIN_ECHEC", "raison=desactive")
        RENVOYER Faux
    FIN
    sHashCalcule est une chaîne = PROC_Utilitaires.HasherMDP(sMdp, Utilisateurs.SelMDP)
    SI sHashCalcule <> Utilisateurs.MotDePasseHash ALORS
        PROC_Utilitaires.JournaliserAction(Utilisateurs.IDUtilisateur, "LOGIN_ECHEC", "raison=mdp")
        RENVOYER Faux
    FIN
    gclUserCourant = allouer un cUtilisateur(Utilisateurs.IDUtilisateur)
    PROC_Utilitaires.JournaliserAction(gclUserCourant:m_IDUtilisateur, "LOGIN_OK", "")
    RENVOYER Vrai

// Déconnexion : journalise et libère l'objet.
PROCEDURE Deconnecter()
    SI gclUserCourant <> Null ALORS
        PROC_Utilitaires.JournaliserAction(gclUserCourant:m_IDUtilisateur, "LOGOUT", "")
        libérer gclUserCourant
    FIN

// Vérifie que l'utilisateur courant peut accéder à la fenêtre.
// À appeler dans l'événement "Initialisation" de chaque fenêtre protégée.
PROCEDURE VerifierAcces(sFenetre est une chaîne) : booléen
    SI gclUserCourant = Null ALORS
        Erreur("Session expirée. Veuillez vous reconnecter.")
        RENVOYER Faux
    FIN
    SI PAS gclUserCourant:PeutAcceder(sFenetre) ALORS
        Erreur("Accès refusé pour votre rôle (" + gclUserCourant:m_Role + ").")
        RENVOYER Faux
    FIN
    RENVOYER Vrai

// Crée un utilisateur (Admin uniquement).
PROCEDURE CreerUtilisateur(sLogin est une chaîne, sMdpClair est une chaîne, ...
                           sNom est une chaîne, sPrenom est une chaîne, ...
                           sRole est une chaîne) : entier
    SI gclUserCourant = Null OU PAS gclUserCourant:EstAdmin() ALORS
        Erreur("Réservé à l'administrateur.")
        RENVOYER 0
    FIN
    SI Taille(sMdpClair) < 6 ALORS
        Erreur("Mot de passe trop court (6 caractères minimum).")
        RENVOYER 0
    FIN
    SI PAS (sRole DANS ("Admin", "Caissier", "Serveur", "Cuisine")) ALORS
        Erreur("Rôle invalide.")
        RENVOYER 0
    FIN
    HLitRecherchePremier(Utilisateurs, Login, sLogin)
    SI HTrouve(Utilisateurs) ALORS
        Erreur("Login déjà utilisé.")
        RENVOYER 0
    FIN
    sSel est une chaîne = PROC_Utilitaires.GenererSel()
    HRAZ(Utilisateurs)
    Utilisateurs.Login          = sLogin
    Utilisateurs.SelMDP         = sSel
    Utilisateurs.MotDePasseHash = PROC_Utilitaires.HasherMDP(sMdpClair, sSel)
    Utilisateurs.Nom            = sNom
    Utilisateurs.Prenom         = sPrenom
    Utilisateurs.Role           = sRole
    Utilisateurs.Actif          = Vrai
    Utilisateurs.DateCreation   = DateHeureSys()
    SI PAS HAjoute(Utilisateurs) ALORS RENVOYER 0
    PROC_Utilitaires.JournaliserAction(gclUserCourant:m_IDUtilisateur, "USER_CREATED", ...
        "id=" + Utilisateurs.IDUtilisateur + ";login=" + sLogin + ";role=" + sRole)
    RENVOYER Utilisateurs.IDUtilisateur

// Réinitialise un mot de passe.
PROCEDURE ReinitialiserMDP(nIDUser est un entier, sNouveauMdp est une chaîne) : booléen
    SI gclUserCourant = Null OU PAS gclUserCourant:EstAdmin() ALORS RENVOYER Faux
    SI Taille(sNouveauMdp) < 6 ALORS RENVOYER Faux
    HLitRecherchePremier(Utilisateurs, IDUtilisateur, nIDUser)
    SI PAS HTrouve(Utilisateurs) ALORS RENVOYER Faux
    sSel est une chaîne = PROC_Utilitaires.GenererSel()
    Utilisateurs.SelMDP         = sSel
    Utilisateurs.MotDePasseHash = PROC_Utilitaires.HasherMDP(sNouveauMdp, sSel)
    HModifie(Utilisateurs)
    PROC_Utilitaires.JournaliserAction(gclUserCourant:m_IDUtilisateur, "USER_MDP_RESET", "id=" + nIDUser)
    RENVOYER Vrai

// Active / désactive un utilisateur.
PROCEDURE BasculerActif(nIDUser est un entier) : booléen
    SI gclUserCourant = Null OU PAS gclUserCourant:EstAdmin() ALORS RENVOYER Faux
    HLitRecherchePremier(Utilisateurs, IDUtilisateur, nIDUser)
    SI PAS HTrouve(Utilisateurs) ALORS RENVOYER Faux
    Utilisateurs.Actif = PAS Utilisateurs.Actif
    HModifie(Utilisateurs)
    PROC_Utilitaires.JournaliserAction(gclUserCourant:m_IDUtilisateur, "USER_TOGGLE", ...
        "id=" + nIDUser + ";actif=" + Utilisateurs.Actif)
    RENVOYER Vrai
