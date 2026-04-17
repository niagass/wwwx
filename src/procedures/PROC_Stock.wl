// ============================================================================
//  Ensemble de procédures globales : PROC_Stock
//  Opérations de stock transversales (décrément commande, alertes...).
// ============================================================================

// Décrémente le stock de tous les ingrédients consommés par une commande.
// Appelée au passage en statut "Envoyee" (cuisine attaque la prépa).
PROCEDURE DecrementerPourCommande(nIDCommande est un entier, nIDUser est un entier)
    POUR TOUT LignesCommande AVEC IDCommande = nIDCommande
        POUR TOUT PlatsIngredients AVEC IDPlat = LignesCommande.IDPlat
            nQteTotale est un réel = PlatsIngredients.Quantite * LignesCommande.Quantite
            oStk est un cStock
            SI oStk:Charger(PlatsIngredients.IDIngredient) ALORS
                oStk:AjouterMouvement("Sortie", nQteTotale, nIDUser, ...
                    "Commande #" + nIDCommande, NumériqueVersChaîne(nIDCommande))
                SI oStk:SousSeuil() ALORS
                    PROC_Utilitaires.JournaliserAction(nIDUser, "STOCK_ALERTE", ...
                        "ingredient=" + oStk:m_IDIngredient + ";actuel=" + oStk:m_StockActuel + ...
                        ";min=" + oStk:m_StockMin)
                FIN
            FIN
        FIN
    FIN

// Réincrémente le stock pour une commande annulée.
PROCEDURE IncrementerPourCommande(nIDCommande est un entier, nIDUser est un entier, sMotif est une chaîne)
    POUR TOUT LignesCommande AVEC IDCommande = nIDCommande
        POUR TOUT PlatsIngredients AVEC IDPlat = LignesCommande.IDPlat
            nQteTotale est un réel = PlatsIngredients.Quantite * LignesCommande.Quantite
            oStk est un cStock
            SI oStk:Charger(PlatsIngredients.IDIngredient) ALORS
                oStk:AjouterMouvement("Entree", nQteTotale, nIDUser, ...
                    sMotif + " - Cde #" + nIDCommande, NumériqueVersChaîne(nIDCommande))
            FIN
        FIN
    FIN

// Renvoie le nombre d'ingrédients sous seuil.
PROCEDURE NbIngredientsSousSeuil() : entier
    nCnt est un entier = 0
    POUR TOUT Ingredients
        SI Ingredients.StockActuel <= Ingredients.StockMin ALORS nCnt++
    FIN
    RENVOYER nCnt

// Inventaire : renvoie le coût total du stock.
PROCEDURE ValeurStock() : monétaire
    nTotal est un monétaire = 0
    POUR TOUT Ingredients
        nTotal += Ingredients.StockActuel * Ingredients.PrixAchatUnitaire
    FIN
    RENVOYER nTotal
