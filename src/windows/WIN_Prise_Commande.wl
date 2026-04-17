// ============================================================================
//  Fenêtre : WIN_Prise_Commande
//  Écran serveur pour ajouter/retirer des plats et envoyer en cuisine.
// ============================================================================
//
// Paramètres globaux fenêtre :
//   nIDCommandeOuverte est un entier   (0 si à créer)
//   nIDTableCible      est un entier   (si nouvelle commande)
//
// UI :
//   TAB_Categories      (Onglet ou boutons dynamiques : une case par Catégorie)
//   ZR_Plats            (Zone répétée : plats de la catégorie active)
//   TBL_Lignes          (Table : lignes de la commande)
//     COL_IDLigne, COL_Plat, COL_Qte, COL_PrixU, COL_Total, COL_Notes, COL_Statut
//   SAI_QuantiteDefaut  (Saisie numérique, défaut 1)
//   LIB_Total           (Libellé : "Total : 42,50 €")
//   LIB_Etat            (Libellé : statut commande)
//   BTN_AjouterPlat     (Bouton)
//   BTN_SupprLigne      (Bouton)
//   BTN_NoteLigne       (Bouton : édite note sur ligne)
//   BTN_EnvoyerCuisine  (Bouton : passe en "Envoyee")
//   BTN_MarquerServie   (Bouton : passe en "Servie")
//   BTN_Annuler         (Bouton : annule la commande)
//   BTN_Fermer          (Bouton : ferme la fenêtre sans modifier)
// ============================================================================

nIDCommandeOuverte est un entier       // param
nIDTableCible      est un entier       // param
gclCmd             est un cCommande    // instance chargée/ouverte


// @Evt: Initialisation de WIN_Prise_Commande
    SI PAS PROC_Auth.VerifierAcces("WIN_Prise_Commande") ALORS Ferme() ; RETOUR FIN
    SAI_QuantiteDefaut = 1

    gclCmd = allouer un cCommande
    SI nIDCommandeOuverte = 0 ALORS
        SI PAS gclCmd:Ouvrir(nIDTableCible, gclUserCourant:m_IDUtilisateur) ALORS
            Ferme()
            RETOUR
        FIN
    SINON
        SI PAS gclCmd:Charger(nIDCommandeOuverte) ALORS
            Erreur("Commande introuvable.")
            Ferme()
            RETOUR
        FIN
    FIN

    ChargerCategories()
    ChargerLignes()
    RafraichirEtat()


// @Evt: Clic d'un bouton d'onglet catégorie (code générique)
    ChargerPlats(MoiMême..ValeurInitiale)


// @Evt: Sélection d'une ligne dans ZR_Plats (double-clic)
    nIDPlat est un entier = ZR_Plats.COL_IDPlat
    nQte    est un entier = Max(1, SAI_QuantiteDefaut)
    SI gclCmd:AjouterLigne(nIDPlat, nQte) ALORS
        ChargerLignes()
        RafraichirEtat()
    FIN

// @Evt: Clic de BTN_SupprLigne
    SI TBL_Lignes..Occurrence = 0 OU TBL_Lignes = 0 ALORS RETOUR
    SI gclCmd:RetirerLigne(TBL_Lignes.COL_IDLigne) ALORS
        ChargerLignes()
        RafraichirEtat()
    FIN

// @Evt: Clic de BTN_NoteLigne
    SI TBL_Lignes..Occurrence = 0 ALORS RETOUR
    sNote est une chaîne = Saisie("Note pour la ligne", TBL_Lignes.COL_Notes)
    SI sNote <> "" ALORS
        HLitRecherchePremier(LignesCommande, IDLigne, TBL_Lignes.COL_IDLigne)
        LignesCommande.Notes = sNote
        HModifie(LignesCommande)
        ChargerLignes()
    FIN

// @Evt: Clic de BTN_EnvoyerCuisine
    SI TBL_Lignes..Occurrence = 0 ALORS
        Erreur("La commande est vide.")
        RETOUR
    FIN
    SI gclCmd:ChangerStatut(cCommande.STATUT_ENVOYEE, gclUserCourant:m_IDUtilisateur) ALORS
        Info("Commande envoyée en cuisine.")
        RafraichirEtat()
    FIN

// @Evt: Clic de BTN_MarquerServie
    SI gclCmd:ChangerStatut(cCommande.STATUT_SERVIE, gclUserCourant:m_IDUtilisateur) ALORS
        Info("Commande marquée comme servie.")
        RafraichirEtat()
    FIN

// @Evt: Clic de BTN_Annuler
    sMotif est une chaîne = Saisie("Motif d'annulation", "")
    SI SansEspace(sMotif) = "" ALORS RETOUR
    SI gclCmd:ChangerStatut(cCommande.STATUT_ANNULEE, gclUserCourant:m_IDUtilisateur, sMotif) ALORS
        Info("Commande annulée.")
        Ferme()
    FIN

// @Evt: Clic de BTN_Fermer
    Ferme()


// --- Procédures locales ---

PROCEDURE ChargerCategories()
    // À implémenter selon le contrôle choisi (onglet ou boutons dynamiques).
    // Remplit TAB_Categories à partir des enregistrements Categories.
    TABLESupprimeTout(TAB_Categories)
    POUR TOUT Categories TRIE PAR OrdreAffichage
        TABLEAjouteLigne(TAB_Categories, Categories.IDCategorie, Categories.Nom)
    FIN
    SI TAB_Categories..Occurrence > 0 ALORS
        TAB_Categories = 1
        ChargerPlats(TAB_Categories[1].COL_ID)
    FIN

PROCEDURE ChargerPlats(nIDCategorie est un entier)
    TableRAZ(ZR_Plats)
    POUR TOUT Plats AVEC IDCategorie = nIDCategorie ET Actif = Vrai TRIE PAR Nom
        TableAjouteLigne(ZR_Plats, Plats.IDPlat, Plats.Nom, Plats.Prix, ...
                         PROC_Utilitaires.FormaterMontant(Plats.Prix))
    FIN

PROCEDURE ChargerLignes()
    TableRAZ(TBL_Lignes)
    POUR TOUT LignesCommande AVEC IDCommande = gclCmd:m_IDCommande
        HLitRecherchePremier(Plats, IDPlat, LignesCommande.IDPlat)
        TableAjouteLigne(TBL_Lignes, ...
            LignesCommande.IDLigne, ...
            Plats.Nom, ...
            LignesCommande.Quantite, ...
            PROC_Utilitaires.FormaterMontant(LignesCommande.PrixUnitaire), ...
            PROC_Utilitaires.FormaterMontant(LignesCommande.PrixUnitaire * LignesCommande.Quantite), ...
            LignesCommande.Notes, ...
            LignesCommande.Statut)
    FIN
    LIB_Total = "Total : " + PROC_Utilitaires.FormaterMontant(gclCmd:m_TotalTTC)

PROCEDURE RafraichirEtat()
    LIB_Etat = "Statut : " + gclCmd:m_Statut
    bModifiable est un booléen = gclCmd:m_Statut = cCommande.STATUT_EN_COURS
    BTN_AjouterPlat..Etat    = SiTernaire(bModifiable, Actif, Inactif)
    BTN_SupprLigne..Etat     = SiTernaire(bModifiable, Actif, Inactif)
    BTN_NoteLigne..Etat      = SiTernaire(bModifiable, Actif, Inactif)
    BTN_EnvoyerCuisine..Etat = SiTernaire(bModifiable, Actif, Inactif)
    BTN_MarquerServie..Etat  = SiTernaire(gclCmd:m_Statut = cCommande.STATUT_ENVOYEE, Actif, Inactif)
    BTN_Annuler..Etat        = SiTernaire(gclCmd:m_Statut DANS ( ...
                                              cCommande.STATUT_EN_COURS, ...
                                              cCommande.STATUT_ENVOYEE), Actif, Inactif)
