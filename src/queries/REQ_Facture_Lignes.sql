-- REQ_Facture_Lignes : lignes détaillées d'une facture (via sa commande).
-- Paramètre : {pIDFacture} (ENTIER)
SELECT P.Nom                              AS NomPlat,
       L.Quantite,
       L.PrixUnitaire,
       (L.Quantite * L.PrixUnitaire)      AS SousTotal,
       L.Notes
FROM   LignesCommande L
INNER JOIN Commandes C ON C.IDCommande = L.IDCommande
INNER JOIN Factures  F ON F.IDCommande = C.IDCommande
INNER JOIN Plats     P ON P.IDPlat     = L.IDPlat
WHERE  F.IDFacture = {pIDFacture}
ORDER BY L.IDLigne
