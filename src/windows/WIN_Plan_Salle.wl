// ============================================================================
//  Fenêtre : WIN_Plan_Salle
//  Représentation visuelle des tables. Clic sur une table -> ouvre la
//  commande (ou en crée une nouvelle).
// ============================================================================
//
// UI :
//   ZR_Salle            (Zone répétée ou grille de tuiles représentant les tables)
//     - Colonnes (attributs liés) : IDTable, Numero, Capacite, Statut, Zone
//   COMBO_Zone          (Combo : "Toutes", "Salle", "Terrasse") -> filtre
//   BTN_Rafraichir      (Bouton)
//   BTN_Retour          (Bouton)
//   LIB_Legende         (Libellé : Vert=Libre, Rouge=Occupée, Orange=Réservée)
// ============================================================================


// @Evt: Initialisation de WIN_Plan_Salle
    SI PAS PROC_Auth.VerifierAcces("WIN_Plan_Salle") ALORS Ferme() ; RETOUR FIN
    COMBO_Zone..ValeursAffichées = "Toutes" + TAB + "Salle" + TAB + "Terrasse"
    COMBO_Zone = "Toutes"
    ChargerTables()


// @Evt: Sélection changée de COMBO_Zone
    ChargerTables()

// @Evt: Clic de BTN_Rafraichir
    ChargerTables()


// @Evt: Sélection d'une ligne dans ZR_Salle (double-clic)
    nIDTable est un entier = ZR_Salle.COL_IDTable
    nIDCmd est un entier = PROC_Commandes.CommandeOuverteSurTable(nIDTable)
    SI nIDCmd > 0 ALORS
        WIN_Prise_Commande.nIDCommandeOuverte = nIDCmd
    SINON
        WIN_Prise_Commande.nIDCommandeOuverte = 0
        WIN_Prise_Commande.nIDTableCible      = nIDTable
    FIN
    Ouvre(WIN_Prise_Commande)
    ChargerTables()   // au retour, refléter le changement d'état

// @Evt: Clic de BTN_Retour
    Ferme()


// --- Procédures locales ---

// Recharge la zone répétée.
PROCEDURE ChargerTables()
    TableRAZ(ZR_Salle)
    sFiltre est une chaîne = ""
    SI COMBO_Zone <> "Toutes" ALORS sFiltre = COMBO_Zone
    POUR TOUT Tables TRIE PAR Numero
        SI sFiltre <> "" ET Tables.Zone <> sFiltre ALORS ITÉRER
        TableAjouteLigne(ZR_Salle, Tables.IDTable, Tables.Numero, Tables.Capacite, ...
                         Tables.Statut, Tables.Zone, CouleurStatut(Tables.Statut))
    FIN

// Couleur de fond selon statut.
PROCEDURE CouleurStatut(sStatut est une chaîne) : entier
    SELON sStatut
        CAS "Libre"    RENVOYER RVB(180, 230, 180)
        CAS "Occupee"  RENVOYER RVB(240, 180, 180)
        CAS "Reservee" RENVOYER RVB(245, 215, 160)
    FIN
    RENVOYER RVB(220, 220, 220)
