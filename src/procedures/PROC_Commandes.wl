// ============================================================================
//  Ensemble de procédures globales : PROC_Commandes
//  Helpers haut niveau autour des commandes.
// ============================================================================

// Renvoie la commande ouverte sur une table (ou 0 s'il n'y en a pas).
PROCEDURE CommandeOuverteSurTable(nIDTable est un entier) : entier
    HLitRecherchePremier(Commandes, IDTable, nIDTable)
    TANTQUE HTrouve(Commandes)
        SI Commandes.Statut DANS (cCommande.STATUT_EN_COURS, cCommande.STATUT_ENVOYEE, cCommande.STATUT_SERVIE) ALORS
            RENVOYER Commandes.IDCommande
        FIN
        HLitSuivant(Commandes, IDTable)
    FIN
    RENVOYER 0

// Compte les commandes du jour (tous statuts).
PROCEDURE NbCommandesJour(dtJour est une date = Date(DateSys())) : entier
    sReq est une chaîne = [
        SELECT COUNT(*) AS Nb FROM Commandes
        WHERE DateHeureOuverture >= {pDeb} AND DateHeureOuverture < {pFin}
    ]
    dtDeb est un DateHeure = DateHeure(DateVersEntier(dtJour), 0)
    dtFin est un DateHeure = DateHeure(DateVersEntier(dtJour + 1), 0)
    HExécuteRequêteSQL(REQ_NbCmd, sReq, hRequêteDéfaut, dtDeb, dtFin)
    HLitPremier(REQ_NbCmd)
    nRes est un entier = REQ_NbCmd.Nb
    HAnnuleDéclaration(REQ_NbCmd)
    RENVOYER nRes

// Commandes en attente d'encaissement (statut = Servie).
PROCEDURE CommandesAEncaisser() : chaîne
    // Retourne un CSV simple "idcmd;num_table;total_ttc" pour listing rapide.
    sRes est une chaîne = ""
    POUR TOUT Commandes AVEC Statut = cCommande.STATUT_SERVIE
        HLitRecherchePremier(Tables, IDTable, Commandes.IDTable)
        sNum est une chaîne = SiVide(Tables.Numero, "?")
        sRes += Commandes.IDCommande + ";" + sNum + ";" + Commandes.TotalTTC + RC
    FIN
    RENVOYER sRes
