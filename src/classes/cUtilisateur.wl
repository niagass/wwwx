// ============================================================================
//  Classe : cUtilisateur
//  Représente un utilisateur connecté, porte les infos de session.
// ============================================================================

// --- MEMBRES ---
m_IDUtilisateur    est un entier
m_Login            est une chaîne
m_Nom              est une chaîne
m_Prenom           est une chaîne
m_Role             est une chaîne       // "Admin" / "Caissier" / "Serveur" / "Cuisine"
m_Actif            est un booléen
m_DateConnexion    est un DateHeure

// --- METHODES ---

// Constructeur : charge l'utilisateur depuis sa clé.
PROCEDURE Constructeur(nID est un entier = 0)
    SI nID = 0 ALORS RETOUR
    HLitRecherchePremier(Utilisateurs, IDUtilisateur, nID)
    SI PAS HTrouve(Utilisateurs) ALORS RETOUR
    :m_IDUtilisateur = Utilisateurs.IDUtilisateur
    :m_Login         = Utilisateurs.Login
    :m_Nom           = Utilisateurs.Nom
    :m_Prenom        = Utilisateurs.Prenom
    :m_Role          = Utilisateurs.Role
    :m_Actif         = Utilisateurs.Actif
    :m_DateConnexion = DateHeureSys()

// Destructeur
PROCEDURE Destructeur()
    // rien à libérer

// Retourne le nom complet "Prénom NOM".
PROCEDURE NomComplet() : chaîne
    RENVOYER :m_Prenom + " " + Majuscule(:m_Nom)

// Contrôle d'accès : renvoie vrai si le rôle a le droit d'utiliser la fenêtre.
// Table des ACLs — à étendre selon le périmètre.
PROCEDURE PeutAcceder(sFenetre est une chaîne) : booléen
    SI PAS :m_Actif ALORS RENVOYER Faux
    SELON :m_Role
        CAS "Admin"
            RENVOYER Vrai
        CAS "Caissier"
            RENVOYER sFenetre DANS ("WIN_Menu_Principal", "WIN_Caisse", ...
                                    "WIN_Historique_Commandes", "WIN_Clients")
        CAS "Serveur"
            RENVOYER sFenetre DANS ("WIN_Menu_Principal", "WIN_Plan_Salle", ...
                                    "WIN_Prise_Commande", "WIN_Reservations")
        CAS "Cuisine"
            RENVOYER sFenetre DANS ("WIN_Menu_Principal", "WIN_Cuisine")
        AUTRE CAS
            RENVOYER Faux
    FIN

// Vrai si l'utilisateur est admin.
PROCEDURE EstAdmin() : booléen
    RENVOYER :m_Role = "Admin"
