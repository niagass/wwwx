-- REQ_Plats_Populaires : top plats par quantité vendue sur une période.
-- Paramètres : {pDateDebut} (DATETIME), {pDateFin} (DATETIME)
SELECT P.IDPlat,
       P.Nom                              AS Plat,
       C2.Nom                             AS Categorie,
       SUM(L.Quantite)                    AS QteVendue,
       SUM(L.Quantite * L.PrixUnitaire)   AS CA_TTC
FROM   LignesCommande L
INNER JOIN Commandes  C  ON C.IDCommande = L.IDCommande
INNER JOIN Plats      P  ON P.IDPlat     = L.IDPlat
INNER JOIN Categories C2 ON C2.IDCategorie = P.IDCategorie
WHERE  C.Statut = 'Payee'
  AND  C.DateHeureCloture >= {pDateDebut}
  AND  C.DateHeureCloture <  {pDateFin}
GROUP BY P.IDPlat, P.Nom, C2.Nom
ORDER BY QteVendue DESC
