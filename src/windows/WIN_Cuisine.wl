// ============================================================================
//  Fenêtre : WIN_Cuisine
//  Écran pour la brigade : lignes de commande à préparer. Lecture seule sauf
//  bouton "Prêt" / "Servi" sur chaque ligne.
// ============================================================================
//
// UI :
//   TBL_Lignes    (Table : Table, Plat, Qté, Notes, Statut, ElapsedMinutes)
//   TIMER_Rafraichir  (1000 ms)
//   BTN_MarquerPret  (Bouton : passe la ligne sélectionnée à Pret)
//   BTN_MarquerServi (Bouton : passe à Servi)
//   BTN_Retour
// ============================================================================


// @Evt: Initialisation de WIN_Cuisine
    SI PAS PROC_Auth.VerifierAcces("WIN_Cuisine") ALORS Ferme() ; RETOUR FIN
    Rafraichir()


// @Evt: Tous les évènements de TIMER_Rafraichir
    Rafraichir()

// @Evt: Clic de BTN_Retour
    Ferme()


// @Evt: Clic de BTN_MarquerPret
    ChangerStatutLigne("Pret")

// @Evt: Clic de BTN_MarquerServi
    ChangerStatutLigne("Servi")


// --- Procédures locales ---

PROCEDURE Rafraichir()
    nSel est un entier = TBL_Lignes
    TableRAZ(TBL_Lignes)
    // Lignes des commandes Envoyée ou partiellement servies.
    sReq est une chaîne = [
        SELECT L.IDLigne, T.Numero AS NumTable, P.Nom AS Plat, L.Quantite, L.Notes, L.Statut,
               C.DateHeureOuverture
        FROM LignesCommande L
        INNER JOIN Commandes C ON C.IDCommande = L.IDCommande
        INNER JOIN Tables T    ON T.IDTable    = C.IDTable
        INNER JOIN Plats P     ON P.IDPlat     = L.IDPlat
        WHERE C.Statut IN ('Envoyee', 'Servie')
          AND L.Statut IN ('Attente', 'EnPreparation', 'Pret')
        ORDER BY C.DateHeureOuverture
    ]
    HExécuteRequêteSQL(REQ_Cuisine, sReq, hRequêteDéfaut)
    POUR TOUT REQ_Cuisine
        nMin est un entier = Entier((DateHeureSys() - REQ_Cuisine.DateHeureOuverture) / 60)
        TableAjouteLigne(TBL_Lignes, REQ_Cuisine.IDLigne, REQ_Cuisine.NumTable, REQ_Cuisine.Plat, ...
                         REQ_Cuisine.Quantite, REQ_Cuisine.Notes, REQ_Cuisine.Statut, ...
                         nMin + " min")
    FIN
    HAnnuleDéclaration(REQ_Cuisine)
    SI nSel > 0 ET nSel <= TBL_Lignes..Occurrence ALORS TBL_Lignes = nSel

PROCEDURE ChangerStatutLigne(sNouveau est une chaîne)
    SI TBL_Lignes..Occurrence = 0 ALORS RETOUR
    oL est un cLigneCommande
    SI oL:Charger(TBL_Lignes.COL_IDLigne) ALORS
        oL:ChangerStatut(sNouveau)
        Rafraichir()
    FIN
