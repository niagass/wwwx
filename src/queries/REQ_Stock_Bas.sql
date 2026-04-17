-- REQ_Stock_Bas : ingrédients dont le stock est <= au seuil minimum.
SELECT IDIngredient,
       Nom,
       Unite,
       StockActuel,
       StockMin,
       (StockMin - StockActuel)      AS Manquant,
       PrixAchatUnitaire
FROM   Ingredients
WHERE  StockActuel <= StockMin
ORDER BY Manquant DESC, Nom
