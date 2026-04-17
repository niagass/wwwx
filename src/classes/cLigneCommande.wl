// ============================================================================
//  Classe : cLigneCommande
//  Wrapper léger pour manipuler une ligne hors contexte cCommande.
// ============================================================================

// --- MEMBRES ---
m_IDLigne      est un entier
m_IDCommande   est un entier
m_IDPlat       est un entier
m_Quantite     est un entier
m_PrixUnitaire est un monétaire
m_Notes        est une chaîne
m_Statut       est une chaîne

// --- METHODES ---
PROCEDURE Charger(nIDLigne est un entier) : booléen
    HLitRecherchePremier(LignesCommande, IDLigne, nIDLigne)
    SI PAS HTrouve(LignesCommande) ALORS RENVOYER Faux
    :m_IDLigne      = LignesCommande.IDLigne
    :m_IDCommande   = LignesCommande.IDCommande
    :m_IDPlat       = LignesCommande.IDPlat
    :m_Quantite     = LignesCommande.Quantite
    :m_PrixUnitaire = LignesCommande.PrixUnitaire
    :m_Notes        = LignesCommande.Notes
    :m_Statut       = LignesCommande.Statut
    RENVOYER Vrai

PROCEDURE SousTotal() : monétaire
    RENVOYER :m_Quantite * :m_PrixUnitaire

// Transition de statut au niveau ligne (utile pour l'écran cuisine).
PROCEDURE ChangerStatut(sNouveau est une chaîne) : booléen
    SI PAS (sNouveau DANS ("Attente", "EnPreparation", "Pret", "Servi")) ALORS
        RENVOYER Faux
    FIN
    HLitRecherchePremier(LignesCommande, IDLigne, :m_IDLigne)
    LignesCommande.Statut = sNouveau
    RENVOYER HModifie(LignesCommande)
