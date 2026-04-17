// ============================================================================
//  Fenêtre : WIN_Clients
//  Fiche client : CRUD + historique.
// ============================================================================
//
// UI :
//   TBL_Clients     (Table : Nom, Prénom, Tél., Email)
//   SAI_Nom / SAI_Prenom / SAI_Telephone / SAI_Email / SAI_Notes
//   BTN_Nouveau / BTN_Enregistrer / BTN_Supprimer / BTN_Retour
//   TBL_Historique  (visites : Date, Total, Mode paiement)
// ============================================================================

nIDClientCourant est un entier = 0


// @Evt: Initialisation de WIN_Clients
    SI PAS PROC_Auth.VerifierAcces("WIN_Clients") ALORS Ferme() ; RETOUR FIN
    RafraichirListe()
    NouveauFormulaire()


// @Evt: Sélection changée dans TBL_Clients
    SI TBL_Clients..Occurrence = 0 ALORS RETOUR
    HLitRecherchePremier(Clients, IDClient, TBL_Clients.COL_IDClient)
    nIDClientCourant = Clients.IDClient
    SAI_Nom          = Clients.Nom
    SAI_Prenom       = Clients.Prenom
    SAI_Telephone    = Clients.Telephone
    SAI_Email        = Clients.Email
    SAI_Notes        = Clients.Notes
    RafraichirHistorique()


// @Evt: Clic de BTN_Nouveau
    NouveauFormulaire()

// @Evt: Clic de BTN_Retour
    Ferme()

// @Evt: Clic de BTN_Enregistrer
    SI SansEspace(SAI_Nom) = "" ALORS Erreur("Nom requis") ; RETOUR FIN
    SI PAS PROC_Utilitaires.EmailValide(SAI_Email) ALORS Erreur("Email invalide") ; RETOUR FIN
    SI nIDClientCourant = 0 ALORS HRAZ(Clients) SINON HLitRecherchePremier(Clients, IDClient, nIDClientCourant)
    Clients.Nom       = SAI_Nom
    Clients.Prenom    = SAI_Prenom
    Clients.Telephone = SAI_Telephone
    Clients.Email     = SAI_Email
    Clients.Notes     = SAI_Notes
    SI nIDClientCourant = 0 ALORS HAjoute(Clients) SINON HModifie(Clients)
    nIDClientCourant = Clients.IDClient
    Info("Client enregistré.")
    RafraichirListe()

// @Evt: Clic de BTN_Supprimer
    SI nIDClientCourant = 0 ALORS RETOUR
    // Vérifier s'il a des réservations
    HLitRecherchePremier(Reservations, IDClient, nIDClientCourant)
    SI HTrouve(Reservations) ALORS
        Erreur("Client lié à des réservations ; suppression refusée.")
        RETOUR
    FIN
    SI PAS OuiNon("Supprimer définitivement ?") ALORS RETOUR
    HLitRecherchePremier(Clients, IDClient, nIDClientCourant)
    HSupprime(Clients)
    NouveauFormulaire()
    RafraichirListe()


// --- Procédures locales ---

PROCEDURE RafraichirListe()
    TableRAZ(TBL_Clients)
    POUR TOUT Clients TRIE PAR Nom, Prenom
        TableAjouteLigne(TBL_Clients, Clients.IDClient, Clients.Nom, Clients.Prenom, ...
                         Clients.Telephone, Clients.Email)
    FIN

PROCEDURE RafraichirHistorique()
    TableRAZ(TBL_Historique)
    // Heuristique : on cherche les factures dont la commande a été ouverte sur
    // une table correspondant à une réservation du client. (modèle simplifié)
    sReq est une chaîne = [
        SELECT F.DateHeure, F.TotalTTC, F.ModePaiement
        FROM Factures F
        INNER JOIN Commandes C ON C.IDCommande = F.IDCommande
        INNER JOIN Reservations R ON R.IDTable = C.IDTable
        WHERE R.IDClient = {pID}
        ORDER BY F.DateHeure DESC
    ]
    HExécuteRequêteSQL(REQ_HistClient, sReq, hRequêteDéfaut, nIDClientCourant)
    POUR TOUT REQ_HistClient
        TableAjouteLigne(TBL_Historique, ...
            DateHeureVersChaîne(REQ_HistClient.DateHeure, "JJ/MM/AAAA HH:MM"), ...
            PROC_Utilitaires.FormaterMontant(REQ_HistClient.TotalTTC), ...
            REQ_HistClient.ModePaiement)
    FIN
    HAnnuleDéclaration(REQ_HistClient)

PROCEDURE NouveauFormulaire()
    nIDClientCourant = 0
    SAI_Nom = "" ; SAI_Prenom = "" ; SAI_Telephone = "" ; SAI_Email = "" ; SAI_Notes = ""
    TableRAZ(TBL_Historique)
