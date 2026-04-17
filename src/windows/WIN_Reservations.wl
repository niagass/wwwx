// ============================================================================
//  Fenêtre : WIN_Reservations
//  Planifier et gérer les réservations.
// ============================================================================
//
// UI :
//   CAL_Jour            (Calendrier : choix du jour affiché)
//   TBL_Reservations    (Table : Heure, Client, Table, NbPers, Statut, Notes)
//   COMBO_Client        (Combo : clients existants) / BTN_NouveauClient
//   COMBO_Table         (Combo : tables libres)
//   SAI_Heure           (Saisie heure)
//   SAI_NbPers          (Saisie numérique)
//   SAI_Notes           (Saisie multi-lignes)
//   BTN_Creer           (Bouton)
//   BTN_Confirmer       / BTN_Honorer / BTN_Annuler
//   BTN_Retour
// ============================================================================


// @Evt: Initialisation de WIN_Reservations
    SI PAS PROC_Auth.VerifierAcces("WIN_Reservations") ALORS Ferme() ; RETOUR FIN
    CAL_Jour = DateSys()
    RafraichirListes()
    RafraichirReservations()


// @Evt: Sélection changée de CAL_Jour
    RafraichirReservations()

// @Evt: Clic de BTN_Retour
    Ferme()


// @Evt: Clic de BTN_NouveauClient
    Ouvre(WIN_Clients)
    RafraichirListes()


// @Evt: Clic de BTN_Creer
    SI COMBO_Client..ValeurMemorisée = 0 ALORS Erreur("Client requis") ; RETOUR FIN
    SI COMBO_Table..ValeurMemorisée = 0 ALORS Erreur("Table requise") ; RETOUR FIN
    SI SAI_NbPers <= 0 ALORS Erreur("Nombre de personnes invalide") ; RETOUR FIN
    dtRes est un DateHeure = DateHeure(CAL_Jour, SAI_Heure)
    SI PasseAvant(dtRes, DateHeureSys()) ALORS
        Erreur("Impossible de réserver dans le passé.")
        RETOUR
    FIN

    HRAZ(Reservations)
    Reservations.IDClient     = COMBO_Client..ValeurMemorisée
    Reservations.IDTable      = COMBO_Table..ValeurMemorisée
    Reservations.DateHeure    = dtRes
    Reservations.NbPersonnes  = SAI_NbPers
    Reservations.Statut       = "Attente"
    Reservations.Notes        = SAI_Notes
    HAjoute(Reservations)
    Info("Réservation créée.")
    SAI_Notes = "" ; SAI_NbPers = 0
    RafraichirReservations()


// @Evt: Clic de BTN_Confirmer
    ChangerStatutResa("Confirmee")

// @Evt: Clic de BTN_Annuler
    ChangerStatutResa("Annulee")

// @Evt: Clic de BTN_Honorer
    // Honorer = transformer en ouverture de commande sur la table
    SI TBL_Reservations..Occurrence = 0 ALORS RETOUR
    HLitRecherchePremier(Reservations, IDReservation, TBL_Reservations.COL_IDResa)
    SI Reservations.Statut DANS ("Honoree", "Annulee") ALORS
        Erreur("Réservation déjà traitée.")
        RETOUR
    FIN
    Reservations.Statut = "Honoree"
    HModifie(Reservations)
    WIN_Prise_Commande.nIDCommandeOuverte = 0
    WIN_Prise_Commande.nIDTableCible      = Reservations.IDTable
    Ouvre(WIN_Prise_Commande)
    RafraichirReservations()


// --- Procédures locales ---

PROCEDURE RafraichirListes()
    COMBO_Client..ValeursAffichées = ""
    ComboAjoute(COMBO_Client, "-- Choisir --", 0)
    POUR TOUT Clients TRIE PAR Nom, Prenom
        ComboAjoute(COMBO_Client, Clients.Nom + " " + Clients.Prenom, Clients.IDClient)
    FIN
    COMBO_Table..ValeursAffichées = ""
    ComboAjoute(COMBO_Table, "-- Choisir --", 0)
    POUR TOUT Tables TRIE PAR Numero
        ComboAjoute(COMBO_Table, "Table " + Tables.Numero + " (" + Tables.Capacite + " pers)", Tables.IDTable)
    FIN

PROCEDURE RafraichirReservations()
    TableRAZ(TBL_Reservations)
    dtDeb est un DateHeure = DateHeure(CAL_Jour, 0)
    dtFin est un DateHeure = DateHeure(DateVersChaîne(CAL_Jour + 1, "AAAAMMJJ"), 0)
    POUR TOUT Reservations TRIE PAR DateHeure
        SI Reservations.DateHeure < dtDeb OU Reservations.DateHeure >= dtFin ALORS ITÉRER
        HLitRecherchePremier(Clients, IDClient, Reservations.IDClient)
        sClient est une chaîne = Clients.Nom + " " + Clients.Prenom
        HLitRecherchePremier(Tables, IDTable, Reservations.IDTable)
        TableAjouteLigne(TBL_Reservations, ...
            Reservations.IDReservation, ...
            DateHeureVersChaîne(Reservations.DateHeure, "HH:MM"), ...
            sClient, ...
            "Table " + Tables.Numero, ...
            Reservations.NbPersonnes, ...
            Reservations.Statut, ...
            Reservations.Notes)
    FIN

PROCEDURE ChangerStatutResa(sNouveau est une chaîne)
    SI TBL_Reservations..Occurrence = 0 ALORS RETOUR
    HLitRecherchePremier(Reservations, IDReservation, TBL_Reservations.COL_IDResa)
    Reservations.Statut = sNouveau
    HModifie(Reservations)
    RafraichirReservations()
