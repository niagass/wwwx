// ============================================================================
//  Fenêtre : WIN_Menu_Principal
//  Tableau de bord + tuiles d'accès aux modules (selon rôle).
// ============================================================================
//
// UI :
//   LIB_Utilisateur     (Libellé dynamique : "Bonjour Jean DUPONT (Admin)")
//   LIB_Date            (Libellé dynamique : date & heure temps réel)
//   TIMER_Horloge       (Champ Timer, période 1000ms)
//   BTN_PlanSalle       (Bouton tuile  "Plan de salle")
//   BTN_Caisse          (Bouton tuile  "Caisse")
//   BTN_Reservations    (Bouton tuile  "Réservations")
//   BTN_Plats           (Bouton tuile  "Plats")
//   BTN_Stock           (Bouton tuile  "Stock")
//   BTN_Clients         (Bouton tuile  "Clients")
//   BTN_Stats           (Bouton tuile  "Statistiques")
//   BTN_Utilisateurs    (Bouton tuile  "Utilisateurs" — Admin uniquement)
//   BTN_Deconnexion     (Bouton        "Se déconnecter")
//   LIB_AlerteStock     (Libellé rouge : "X ingrédients sous seuil")
// ============================================================================


// @Evt: Initialisation de WIN_Menu_Principal
    SI PAS PROC_Auth.VerifierAcces("WIN_Menu_Principal") ALORS
        Ouvre(WIN_Connexion)
        Ferme()
        RETOUR
    FIN

    LIB_Utilisateur = "Bonjour " + gclUserCourant:NomComplet() + ...
                      " (" + gclUserCourant:m_Role + ")"

    // Visibilité selon rôle
    BTN_Utilisateurs..Visible = gclUserCourant:EstAdmin()
    BTN_Plats..Visible        = gclUserCourant:EstAdmin()
    BTN_Stats..Visible        = gclUserCourant:m_Role DANS ("Admin", "Caissier")
    BTN_Caisse..Visible       = gclUserCourant:m_Role DANS ("Admin", "Caissier")
    BTN_PlanSalle..Visible    = gclUserCourant:m_Role DANS ("Admin", "Serveur")
    BTN_Stock..Visible        = gclUserCourant:m_Role DANS ("Admin", "Caissier")
    BTN_Reservations..Visible = gclUserCourant:m_Role DANS ("Admin", "Serveur", "Caissier")
    BTN_Clients..Visible      = gclUserCourant:m_Role DANS ("Admin", "Caissier")

    // Alerte stock bas
    nAlerte est un entier = PROC_Stock.NbIngredientsSousSeuil()
    LIB_AlerteStock = SiTernaire(nAlerte > 0, nAlerte + " ingrédient(s) sous seuil", "")
    LIB_AlerteStock..Visible = nAlerte > 0


// @Evt: Tous les évènements de TIMER_Horloge
    LIB_Date = DateVersChaîne(DateSys(), "JJJJ JJ MMMM AAAA") + "   " + HeureSys()


// @Evt: Clic de BTN_PlanSalle
    Ouvre(WIN_Plan_Salle)

// @Evt: Clic de BTN_Caisse
    Ouvre(WIN_Caisse)

// @Evt: Clic de BTN_Reservations
    Ouvre(WIN_Reservations)

// @Evt: Clic de BTN_Plats
    Ouvre(WIN_Gestion_Plats)

// @Evt: Clic de BTN_Stock
    Ouvre(WIN_Gestion_Stock)

// @Evt: Clic de BTN_Clients
    Ouvre(WIN_Clients)

// @Evt: Clic de BTN_Stats
    Ouvre(WIN_Statistiques)

// @Evt: Clic de BTN_Utilisateurs
    Ouvre(WIN_Utilisateurs)


// @Evt: Clic de BTN_Deconnexion
    SI OuiNon("Se déconnecter ?") ALORS
        PROC_Auth.Deconnecter()
        Ouvre(WIN_Connexion)
        Ferme()
    FIN
