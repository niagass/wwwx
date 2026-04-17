// ============================================================================
//  Classe : cFacture
//  Crée et imprime une facture pour une commande.
// ============================================================================

// --- MEMBRES ---
m_IDFacture     est un entier
m_IDCommande    est un entier
m_NumeroFacture est une chaîne
m_DateHeure     est un DateHeure
m_TotalHT       est un monétaire
m_TotalTVA      est un monétaire
m_TotalTTC      est un monétaire
m_ModePaiement  est une chaîne
m_MontantRecu   est un monétaire
m_Rendu         est un monétaire

// --- METHODES ---

// Génère un numéro de facture au format FYYYYMM0000001
PROCEDURE GenererNumero() : chaîne
    sPrefix    est une chaîne = "F" + DateSys(maskAAAAMM)
    sReq       est une chaîne = [
        SELECT MAX(NumeroFacture) AS Dernier FROM Factures
        WHERE NumeroFacture LIKE {pPrefix} + '%'
    ]
    HExécuteRequêteSQL(REQ_LastNum, sReq, hRequêteDéfaut, sPrefix)
    HLitPremier(REQ_LastNum)
    sDernier est une chaîne = REQ_LastNum.Dernier
    HAnnuleDéclaration(REQ_LastNum)

    nSuffix est un entier = 0
    SI sDernier <> "" ALORS nSuffix = Val(Droite(sDernier, 7))
    nSuffix++
    RENVOYER sPrefix + NumériqueVersChaîne(nSuffix, "07d")

// Encaisse une commande et crée la facture associée.
// Retourne Vrai + remplit les membres en cas de succès.
PROCEDURE Encaisser(oCmd est un cCommande, sModePaiement est une chaîne, ...
                    nMontantRecu est un monétaire, nIDCaissier est un entier) : booléen
    SI oCmd:m_Statut <> cCommande.STATUT_SERVIE ALORS
        Erreur("Commande pas prête à être encaissée.")
        RENVOYER Faux
    FIN
    SI PAS (sModePaiement DANS ("Especes", "Carte", "Cheque")) ALORS
        Erreur("Mode de paiement invalide.")
        RENVOYER Faux
    FIN
    SI sModePaiement <> "Especes" ET nMontantRecu <> oCmd:m_TotalTTC ALORS
        Erreur("Le montant doit être égal au total pour ce mode de paiement.")
        RENVOYER Faux
    FIN
    SI nMontantRecu < oCmd:m_TotalTTC ALORS
        Erreur("Montant insuffisant.")
        RENVOYER Faux
    FIN

    HTransactionDébut()
    QUAND EXCEPTION
        HTransactionAnnule()
        Erreur("Encaissement échoué : " + ExceptionInfo(errMessage))
        RENVOYER Faux
    FIN

    HRAZ(Factures)
    Factures.IDCommande    = oCmd:m_IDCommande
    Factures.NumeroFacture = :GenererNumero()
    Factures.DateHeure     = DateHeureSys()
    Factures.IDCaissier    = nIDCaissier
    Factures.TotalHT       = oCmd:m_TotalHT
    Factures.TotalTVA      = oCmd:m_TotalTVA
    Factures.TotalTTC      = oCmd:m_TotalTTC
    Factures.ModePaiement  = sModePaiement
    Factures.MontantRecu   = nMontantRecu
    Factures.Rendu         = Max(0, nMontantRecu - oCmd:m_TotalTTC)
    SI PAS HAjoute(Factures) ALORS
        HTransactionAnnule()
        Erreur("Impossible d'ajouter la facture : " + HErreurInfo())
        RENVOYER Faux
    FIN

    :m_IDFacture     = Factures.IDFacture
    :m_NumeroFacture = Factures.NumeroFacture
    :m_DateHeure     = Factures.DateHeure
    :m_TotalHT       = Factures.TotalHT
    :m_TotalTVA      = Factures.TotalTVA
    :m_TotalTTC      = Factures.TotalTTC
    :m_ModePaiement  = Factures.ModePaiement
    :m_MontantRecu   = Factures.MontantRecu
    :m_Rendu         = Factures.Rendu
    :m_IDCommande    = oCmd:m_IDCommande

    // Passage commande en Payee (inclut libération table et audit)
    SI PAS oCmd:ChangerStatut(cCommande.STATUT_PAYEE, nIDCaissier, "Paiement " + sModePaiement) ALORS
        HTransactionAnnule()
        RENVOYER Faux
    FIN

    HTransactionFin()
    RENVOYER Vrai

// Imprime la facture via l'état ETAT_Facture.
PROCEDURE Imprimer()
    iAperçu(iMoyen)
    iImprimeEtat(ETAT_Facture, :m_IDFacture)
