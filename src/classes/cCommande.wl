// ============================================================================
//  Classe : cCommande
//  Agrégat commande + lignes. Encapsule les règles de cycle de vie.
// ============================================================================

// --- MEMBRES ---
m_IDCommande         est un entier
m_IDTable            est un entier
m_IDServeur          est un entier
m_DateOuverture      est un DateHeure
m_DateCloture        est un DateHeure
m_Statut             est une chaîne
m_Notes              est une chaîne
m_TotalHT            est un monétaire
m_TotalTVA           est un monétaire
m_TotalTTC           est un monétaire

// Constantes de statut — centralisées pour éviter les chaînes magiques.
CONSTANT
    STATUT_EN_COURS   = "EnCours"
    STATUT_ENVOYEE    = "Envoyee"
    STATUT_SERVIE     = "Servie"
    STATUT_PAYEE      = "Payee"
    STATUT_ANNULEE    = "Annulee"
FIN

// --- METHODES ---

// Ouvre une nouvelle commande sur une table donnée par le serveur courant.
PROCEDURE Ouvrir(nIDTable est un entier, nIDServeur est un entier) : booléen
    HRAZ(Commandes)
    Commandes.IDTable            = nIDTable
    Commandes.IDServeur          = nIDServeur
    Commandes.DateHeureOuverture = DateHeureSys()
    Commandes.Statut             = STATUT_EN_COURS
    Commandes.TotalHT            = 0
    Commandes.TotalTVA           = 0
    Commandes.TotalTTC           = 0
    SI PAS HAjoute(Commandes) ALORS
        Erreur("Impossible d'ouvrir la commande : " + HErreurInfo())
        RENVOYER Faux
    FIN
    :m_IDCommande    = Commandes.IDCommande
    :m_IDTable       = nIDTable
    :m_IDServeur     = nIDServeur
    :m_DateOuverture = Commandes.DateHeureOuverture
    :m_Statut        = STATUT_EN_COURS
    // Marquer la table occupée
    HLitRecherchePremier(Tables, IDTable, nIDTable)
    SI HTrouve(Tables) ALORS
        Tables.Statut = "Occupee"
        HModifie(Tables)
    FIN
    RENVOYER Vrai

// Charge une commande existante depuis la clé.
PROCEDURE Charger(nID est un entier) : booléen
    HLitRecherchePremier(Commandes, IDCommande, nID)
    SI PAS HTrouve(Commandes) ALORS RENVOYER Faux
    :m_IDCommande    = Commandes.IDCommande
    :m_IDTable       = Commandes.IDTable
    :m_IDServeur     = Commandes.IDServeur
    :m_DateOuverture = Commandes.DateHeureOuverture
    :m_DateCloture   = Commandes.DateHeureCloture
    :m_Statut        = Commandes.Statut
    :m_Notes         = Commandes.Notes
    :m_TotalHT       = Commandes.TotalHT
    :m_TotalTVA      = Commandes.TotalTVA
    :m_TotalTTC      = Commandes.TotalTTC
    RENVOYER Vrai

// Ajoute une ligne et recalcule les totaux.
PROCEDURE AjouterLigne(nIDPlat est un entier, nQuantite est un entier = 1, ...
                       sNotes est une chaîne = "") : booléen
    SI :m_Statut <> STATUT_EN_COURS ALORS
        Erreur("Impossible d'ajouter une ligne : commande non modifiable.")
        RENVOYER Faux
    FIN
    SI nQuantite <= 0 ALORS
        Erreur("Quantité invalide.")
        RENVOYER Faux
    FIN
    HLitRecherchePremier(Plats, IDPlat, nIDPlat)
    SI PAS HTrouve(Plats) OU PAS Plats.Actif ALORS
        Erreur("Plat introuvable ou inactif.")
        RENVOYER Faux
    FIN
    HRAZ(LignesCommande)
    LignesCommande.IDCommande   = :m_IDCommande
    LignesCommande.IDPlat       = nIDPlat
    LignesCommande.Quantite     = nQuantite
    LignesCommande.PrixUnitaire = Plats.Prix
    LignesCommande.Notes        = sNotes
    LignesCommande.Statut       = "Attente"
    SI PAS HAjoute(LignesCommande) ALORS
        Erreur("Ajout ligne impossible : " + HErreurInfo())
        RENVOYER Faux
    FIN
    :RecalculerTotaux()
    RENVOYER Vrai

// Retire une ligne par IDLigne.
PROCEDURE RetirerLigne(nIDLigne est un entier) : booléen
    SI :m_Statut <> STATUT_EN_COURS ALORS RENVOYER Faux
    HLitRecherchePremier(LignesCommande, IDLigne, nIDLigne)
    SI PAS HTrouve(LignesCommande) OU LignesCommande.IDCommande <> :m_IDCommande ALORS
        RENVOYER Faux
    FIN
    HSupprime(LignesCommande)
    :RecalculerTotaux()
    RENVOYER Vrai

// Recalcule TotalHT, TotalTVA, TotalTTC et persiste.
PROCEDURE RecalculerTotaux()
    sReq est une chaîne = [
        SELECT SUM(PrixUnitaire * Quantite) AS Total FROM LignesCommande
        WHERE IDCommande = {pID}
    ]
    HExécuteRequêteSQL(REQ_Total, sReq, hRequêteDéfaut, :m_IDCommande)
    HLitPremier(REQ_Total)
    nTTC est un monétaire = REQ_Total.Total
    HAnnuleDéclaration(REQ_Total)

    nTauxTVA est un réel = PROC_Utilitaires.TauxTVA()  // ex. 20
    nHT est un monétaire  = Arrondi(nTTC / (1 + nTauxTVA / 100), 2)
    nTVA est un monétaire = nTTC - nHT

    HLitRecherchePremier(Commandes, IDCommande, :m_IDCommande)
    Commandes.TotalHT  = nHT
    Commandes.TotalTVA = nTVA
    Commandes.TotalTTC = nTTC
    HModifie(Commandes)

    :m_TotalHT  = nHT
    :m_TotalTVA = nTVA
    :m_TotalTTC = nTTC

// Vérifie la validité d'une transition de statut.
PROCEDURE TransitionAutorisee(sNouveauStatut est une chaîne) : booléen
    SELON :m_Statut
        CAS STATUT_EN_COURS
            RENVOYER sNouveauStatut DANS (STATUT_ENVOYEE, STATUT_ANNULEE)
        CAS STATUT_ENVOYEE
            RENVOYER sNouveauStatut DANS (STATUT_SERVIE, STATUT_ANNULEE)
        CAS STATUT_SERVIE
            RENVOYER sNouveauStatut = STATUT_PAYEE
        CAS STATUT_PAYEE, STATUT_ANNULEE
            RENVOYER Faux      // états terminaux
    FIN
    RENVOYER Faux

// Change l'état + effets de bord (stock, table).
PROCEDURE ChangerStatut(sNouveauStatut est une chaîne, nIDUser est un entier, ...
                        sMotif est une chaîne = "") : booléen
    SI PAS :TransitionAutorisee(sNouveauStatut) ALORS
        Erreur("Transition non autorisée : " + :m_Statut + " -> " + sNouveauStatut)
        RENVOYER Faux
    FIN
    HTransactionDébut()
    QUAND EXCEPTION
        HTransactionAnnule()
        Erreur("Changement de statut échoué : " + ExceptionInfo(errMessage))
        RENVOYER Faux
    FIN

    HLitRecherchePremier(Commandes, IDCommande, :m_IDCommande)
    Commandes.Statut = sNouveauStatut
    SI sNouveauStatut = STATUT_PAYEE OU sNouveauStatut = STATUT_ANNULEE ALORS
        Commandes.DateHeureCloture = DateHeureSys()
    FIN
    HModifie(Commandes)

    // Effets de bord
    SELON sNouveauStatut
        CAS STATUT_ENVOYEE
            // Décrément stock par composition
            PROC_Stock.DecrementerPourCommande(:m_IDCommande, nIDUser)
        CAS STATUT_ANNULEE
            // Réincrémenter si déjà envoyée
            SI :m_Statut = STATUT_ENVOYEE ALORS
                PROC_Stock.IncrementerPourCommande(:m_IDCommande, nIDUser, "Annulation commande")
            FIN
            // Libérer la table
            HLitRecherchePremier(Tables, IDTable, :m_IDTable)
            SI HTrouve(Tables) ALORS
                Tables.Statut = "Libre"
                HModifie(Tables)
            FIN
        CAS STATUT_PAYEE
            // La table est libérée lors du paiement.
            HLitRecherchePremier(Tables, IDTable, :m_IDTable)
            SI HTrouve(Tables) ALORS
                Tables.Statut = "Libre"
                HModifie(Tables)
            FIN
    FIN

    PROC_Utilitaires.JournaliserAction(nIDUser, "STATUT_CHANGE", ...
        "commande=" + :m_IDCommande + ";ancien=" + :m_Statut + ";nouveau=" + sNouveauStatut + ...
        ";motif=" + sMotif)

    :m_Statut = sNouveauStatut
    HTransactionFin()
    RENVOYER Vrai
