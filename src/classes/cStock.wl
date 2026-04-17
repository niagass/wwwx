// ============================================================================
//  Classe : cStock
//  Wrapper objet pour la gestion du stock d'un ingrédient.
// ============================================================================

// --- MEMBRES ---
m_IDIngredient est un entier
m_Nom          est une chaîne
m_Unite        est une chaîne
m_StockActuel  est un réel
m_StockMin     est un réel
m_PrixAchat    est un monétaire

// --- METHODES ---
PROCEDURE Charger(nID est un entier) : booléen
    HLitRecherchePremier(Ingredients, IDIngredient, nID)
    SI PAS HTrouve(Ingredients) ALORS RENVOYER Faux
    :m_IDIngredient = Ingredients.IDIngredient
    :m_Nom          = Ingredients.Nom
    :m_Unite        = Ingredients.Unite
    :m_StockActuel  = Ingredients.StockActuel
    :m_StockMin     = Ingredients.StockMin
    :m_PrixAchat    = Ingredients.PrixAchatUnitaire
    RENVOYER Vrai

PROCEDURE SousSeuil() : booléen
    RENVOYER :m_StockActuel <= :m_StockMin

// Ajoute un mouvement et met à jour le stock courant (transactionnel).
PROCEDURE AjouterMouvement(sType est une chaîne, nQte est un réel, ...
                           nIDUser est un entier, sMotif est une chaîne = "", ...
                           sRef est une chaîne = "") : booléen
    SI PAS (sType DANS ("Entree", "Sortie", "Ajustement")) ALORS RENVOYER Faux
    SI nQte <= 0 ALORS RENVOYER Faux

    HTransactionDébut()
    QUAND EXCEPTION
        HTransactionAnnule()
        RENVOYER Faux
    FIN

    HLitRecherchePremier(Ingredients, IDIngredient, :m_IDIngredient)
    SI PAS HTrouve(Ingredients) ALORS
        HTransactionAnnule()
        RENVOYER Faux
    FIN

    SELON sType
        CAS "Entree"
            Ingredients.StockActuel += nQte
        CAS "Sortie"
            SI Ingredients.StockActuel < nQte ALORS
                // On autorise le négatif mais on journalise une alerte.
                PROC_Utilitaires.JournaliserAction(nIDUser, "STOCK_NEGATIF", ...
                    "ingredient=" + :m_IDIngredient + ";demande=" + nQte + ...
                    ";dispo=" + Ingredients.StockActuel)
            FIN
            Ingredients.StockActuel -= nQte
        CAS "Ajustement"
            // Motif = quantité cible ; nQte est la valeur absolue à poser.
            Ingredients.StockActuel = nQte
    FIN
    HModifie(Ingredients)
    :m_StockActuel = Ingredients.StockActuel

    HRAZ(MouvementsStock)
    MouvementsStock.IDIngredient  = :m_IDIngredient
    MouvementsStock.TypeMouvement = sType
    MouvementsStock.Quantite      = nQte
    MouvementsStock.DateHeure     = DateHeureSys()
    MouvementsStock.IDUtilisateur = nIDUser
    MouvementsStock.Motif         = sMotif
    MouvementsStock.Reference     = sRef
    SI PAS HAjoute(MouvementsStock) ALORS
        HTransactionAnnule()
        RENVOYER Faux
    FIN

    HTransactionFin()
    RENVOYER Vrai
