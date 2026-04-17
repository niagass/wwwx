// ============================================================================
//  Fenêtre : WIN_Caisse
//  Encaissement des commandes terminées.
// ============================================================================
//
// UI :
//   TBL_CommandesAEncaisser (Table : IDCommande, Numéro Table, Date, Total)
//   TBL_Ticket              (Table : aperçu du ticket de la commande sélectionnée)
//   LIB_TotalTTC            (Libellé gros)
//   RADIO_Mode              (Radio : "Espèces" / "Carte" / "Chèque")
//   SAI_MontantRecu         (Saisie monétaire)
//   LIB_Rendu               (Libellé : rendu calculé)
//   BTN_Valider             (Bouton)
//   BTN_Imprimer            (Bouton : imprime ticket de la dernière facture)
//   BTN_Rafraichir          (Bouton)
//   BTN_Retour              (Bouton)
// ============================================================================

gclCmdSel    est un cCommande    // commande sélectionnée
gclDerniereF est un cFacture     // dernière facture encaissée (pour impression)


// @Evt: Initialisation de WIN_Caisse
    SI PAS PROC_Auth.VerifierAcces("WIN_Caisse") ALORS Ferme() ; RETOUR FIN
    RADIO_Mode = 1   // Espèces par défaut
    ChargerListe()


// @Evt: Clic de BTN_Rafraichir
    ChargerListe()

// @Evt: Clic de BTN_Retour
    Ferme()


// @Evt: Sélection changée dans TBL_CommandesAEncaisser
    SI TBL_CommandesAEncaisser..Occurrence = 0 ALORS RETOUR
    nID est un entier = TBL_CommandesAEncaisser.COL_IDCommande
    gclCmdSel = allouer un cCommande
    SI PAS gclCmdSel:Charger(nID) ALORS RETOUR
    AfficherTicket()


// @Evt: Sélection changée de RADIO_Mode
    MettreAJourRendu()

// @Evt: Modification de SAI_MontantRecu
    MettreAJourRendu()


// @Evt: Clic de BTN_Valider
    SI gclCmdSel = Null ALORS
        Erreur("Sélectionnez une commande.")
        RETOUR
    FIN
    sMode est une chaîne
    SELON RADIO_Mode
        CAS 1 sMode = "Especes"
        CAS 2 sMode = "Carte"
        CAS 3 sMode = "Cheque"
    FIN
    nRecu est un monétaire = SAI_MontantRecu
    // Carte/Chèque : montant forcé au total (garde-fou).
    SI sMode <> "Especes" ALORS nRecu = gclCmdSel:m_TotalTTC

    gclDerniereF = allouer un cFacture
    SI gclDerniereF:Encaisser(gclCmdSel, sMode, nRecu, gclUserCourant:m_IDUtilisateur) ALORS
        Info("Paiement validé. Rendu : " + PROC_Utilitaires.FormaterMontant(gclDerniereF:m_Rendu))
        gclDerniereF:Imprimer()
        gclCmdSel = Null
        SAI_MontantRecu = 0
        TableRAZ(TBL_Ticket)
        LIB_TotalTTC = ""
        ChargerListe()
    FIN


// @Evt: Clic de BTN_Imprimer
    SI gclDerniereF = Null ALORS
        Erreur("Aucune facture à réimprimer pour cette session.")
        RETOUR
    FIN
    gclDerniereF:Imprimer()


// --- Procédures locales ---

PROCEDURE ChargerListe()
    TableRAZ(TBL_CommandesAEncaisser)
    POUR TOUT Commandes AVEC Statut = cCommande.STATUT_SERVIE TRIE PAR DateHeureOuverture
        HLitRecherchePremier(Tables, IDTable, Commandes.IDTable)
        TableAjouteLigne(TBL_CommandesAEncaisser, ...
            Commandes.IDCommande, ...
            Tables.Numero, ...
            DateHeureVersChaîne(Commandes.DateHeureOuverture, "HH:MM"), ...
            PROC_Utilitaires.FormaterMontant(Commandes.TotalTTC))
    FIN

PROCEDURE AfficherTicket()
    TableRAZ(TBL_Ticket)
    POUR TOUT LignesCommande AVEC IDCommande = gclCmdSel:m_IDCommande
        HLitRecherchePremier(Plats, IDPlat, LignesCommande.IDPlat)
        TableAjouteLigne(TBL_Ticket, Plats.Nom, LignesCommande.Quantite, ...
            PROC_Utilitaires.FormaterMontant(LignesCommande.PrixUnitaire), ...
            PROC_Utilitaires.FormaterMontant(LignesCommande.PrixUnitaire * LignesCommande.Quantite))
    FIN
    LIB_TotalTTC = PROC_Utilitaires.FormaterMontant(gclCmdSel:m_TotalTTC)
    MettreAJourRendu()

PROCEDURE MettreAJourRendu()
    SI gclCmdSel = Null ALORS LIB_Rendu = "" ; RETOUR FIN
    SI RADIO_Mode <> 1 ALORS
        // Carte / chèque : pas de rendu, montant forcé
        LIB_Rendu = "Rendu : —"
        RETOUR
    FIN
    nRendu est un monétaire = SAI_MontantRecu - gclCmdSel:m_TotalTTC
    LIB_Rendu = "Rendu : " + SiTernaire(nRendu < 0, ...
        "Manque " + PROC_Utilitaires.FormaterMontant(-nRendu), ...
        PROC_Utilitaires.FormaterMontant(nRendu))
