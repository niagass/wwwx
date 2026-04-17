// ============================================================================
//  Fenêtre : WIN_Statistiques
//  Tableaux de bord et KPIs.
// ============================================================================
//
// UI :
//   SAI_DateDebut / SAI_DateFin    (Saisies date)
//   COMBO_Periode                  (Jour / Semaine / Mois / Personnalisé)
//   LIB_CA_TTC                     (Gros libellé)
//   LIB_NbFactures
//   LIB_TicketMoyen
//   LIB_NbCouverts
//   GR_VentesJour                  (Graphe barres : CA par jour)
//   TBL_TopPlats                   (Plat, Qté vendue, CA)
//   TBL_ParServeur                 (Serveur, Nb commandes, CA)
//   BTN_Actualiser / BTN_ExportCSV / BTN_Retour
// ============================================================================


// @Evt: Initialisation de WIN_Statistiques
    SI PAS PROC_Auth.VerifierAcces("WIN_Statistiques") ALORS Ferme() ; RETOUR FIN
    COMBO_Periode..ValeursAffichées = "Jour" + TAB + "Semaine" + TAB + "Mois" + TAB + "Personnalisé"
    COMBO_Periode = "Jour"
    AppliquerPeriode()
    Calculer()


// @Evt: Sélection changée de COMBO_Periode
    AppliquerPeriode()
    Calculer()

// @Evt: Clic de BTN_Actualiser
    Calculer()

// @Evt: Clic de BTN_Retour
    Ferme()

// @Evt: Clic de BTN_ExportCSV
    sChemin est une chaîne = fSélecteur("", "", "Export stats", "CSV (*.csv)" + TAB + "*.csv", "csv", fselCrée)
    SI sChemin = "" ALORS RETOUR
    PROC_Utilitaires.ExporterTableCSV(TBL_TopPlats, sChemin)


// --- Procédures locales ---

PROCEDURE AppliquerPeriode()
    dtAuj est une date = DateSys()
    SELON COMBO_Periode
        CAS "Jour"
            SAI_DateDebut = dtAuj
            SAI_DateFin   = dtAuj
        CAS "Semaine"
            SAI_DateDebut = dtAuj - (JourDeLaSemaine(dtAuj) - 1)
            SAI_DateFin   = SAI_DateDebut + 6
        CAS "Mois"
            SAI_DateDebut = DateVersChaîne(dtAuj, "AAAAMM") + "01"
            SAI_DateFin   = DernierJourDuMois(dtAuj)
    FIN

PROCEDURE Calculer()
    dtDeb est un DateHeure = DateHeure(SAI_DateDebut, 0)
    dtFin est un DateHeure = DateHeure(SAI_DateFin + 1, 0)

    // KPIs globaux
    sReq est une chaîne = [
        SELECT COUNT(*) AS NbF, SUM(TotalTTC) AS CA
        FROM Factures
        WHERE DateHeure >= {pD} AND DateHeure < {pF}
    ]
    HExécuteRequêteSQL(REQ_KPI, sReq, hRequêteDéfaut, dtDeb, dtFin)
    HLitPremier(REQ_KPI)
    nNbF est un entier    = REQ_KPI.NbF
    nCA  est un monétaire = REQ_KPI.CA
    HAnnuleDéclaration(REQ_KPI)

    LIB_CA_TTC      = "CA TTC : " + PROC_Utilitaires.FormaterMontant(nCA)
    LIB_NbFactures  = "Factures : " + nNbF
    LIB_TicketMoyen = "Ticket moyen : " + SiTernaire(nNbF = 0, "—", ...
                                                     PROC_Utilitaires.FormaterMontant(nCA / nNbF))

    // Couverts (sommes des NbPersonnes des réservations honorées sur la période)
    sReq2 est une chaîne = [
        SELECT SUM(NbPersonnes) AS Nb
        FROM Reservations
        WHERE Statut = 'Honoree'
          AND DateHeure >= {pD} AND DateHeure < {pF}
    ]
    HExécuteRequêteSQL(REQ_Couverts, sReq2, hRequêteDéfaut, dtDeb, dtFin)
    HLitPremier(REQ_Couverts)
    LIB_NbCouverts = "Couverts : " + SiVide(REQ_Couverts.Nb, 0)
    HAnnuleDéclaration(REQ_Couverts)

    // Top plats
    TableRAZ(TBL_TopPlats)
    sReq3 est une chaîne = [
        SELECT P.Nom AS Nom, SUM(L.Quantite) AS Qte, SUM(L.Quantite * L.PrixUnitaire) AS CA
        FROM LignesCommande L
        INNER JOIN Plats P ON P.IDPlat = L.IDPlat
        INNER JOIN Commandes C ON C.IDCommande = L.IDCommande
        WHERE C.Statut = 'Payee'
          AND C.DateHeureCloture >= {pD} AND C.DateHeureCloture < {pF}
        GROUP BY P.Nom
        ORDER BY Qte DESC
    ]
    HExécuteRequêteSQL(REQ_TopPlats, sReq3, hRequêteDéfaut, dtDeb, dtFin)
    POUR TOUT REQ_TopPlats
        TableAjouteLigne(TBL_TopPlats, REQ_TopPlats.Nom, REQ_TopPlats.Qte, ...
                         PROC_Utilitaires.FormaterMontant(REQ_TopPlats.CA))
    FIN
    HAnnuleDéclaration(REQ_TopPlats)

    // Par serveur
    TableRAZ(TBL_ParServeur)
    sReq4 est une chaîne = [
        SELECT U.Login AS Serveur, COUNT(DISTINCT C.IDCommande) AS Nb, SUM(F.TotalTTC) AS CA
        FROM Commandes C
        INNER JOIN Utilisateurs U ON U.IDUtilisateur = C.IDServeur
        INNER JOIN Factures F ON F.IDCommande = C.IDCommande
        WHERE F.DateHeure >= {pD} AND F.DateHeure < {pF}
        GROUP BY U.Login
        ORDER BY CA DESC
    ]
    HExécuteRequêteSQL(REQ_Serveur, sReq4, hRequêteDéfaut, dtDeb, dtFin)
    POUR TOUT REQ_Serveur
        TableAjouteLigne(TBL_ParServeur, REQ_Serveur.Serveur, REQ_Serveur.Nb, ...
                         PROC_Utilitaires.FormaterMontant(REQ_Serveur.CA))
    FIN
    HAnnuleDéclaration(REQ_Serveur)

    // Graphe CA par jour
    grDétruit(GR_VentesJour)
    sReq5 est une chaîne = [
        SELECT CAST(DateHeure AS DATE) AS J, SUM(TotalTTC) AS CA
        FROM Factures
        WHERE DateHeure >= {pD} AND DateHeure < {pF}
        GROUP BY CAST(DateHeure AS DATE)
        ORDER BY J
    ]
    HExécuteRequêteSQL(REQ_JourCA, sReq5, hRequêteDéfaut, dtDeb, dtFin)
    nSerie est un entier = grAjouteSérie(GR_VentesJour, "CA")
    POUR TOUT REQ_JourCA
        grAjouteDonnée(GR_VentesJour, nSerie, REQ_JourCA.CA, ...
                       DateVersChaîne(REQ_JourCA.J, "JJ/MM"))
    FIN
    grDessine(GR_VentesJour)
    HAnnuleDéclaration(REQ_JourCA)
