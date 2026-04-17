-- REQ_Facture_Ticket : toutes les données nécessaires à l'édition d'un ticket.
-- Paramètre : {pIDFacture} (ENTIER)
SELECT F.IDFacture,
       F.NumeroFacture,
       F.DateHeure,
       F.TotalHT,
       F.TotalTVA,
       F.TotalTTC,
       F.ModePaiement,
       F.MontantRecu,
       F.Rendu,
       C.IDCommande,
       T.Numero           AS NumTable,
       U.Login            AS Caissier,
       U.Nom              AS CaissierNom,
       U.Prenom           AS CaissierPrenom
FROM   Factures    F
INNER JOIN Commandes    C ON C.IDCommande   = F.IDCommande
INNER JOIN Tables       T ON T.IDTable      = C.IDTable
INNER JOIN Utilisateurs U ON U.IDUtilisateur = F.IDCaissier
WHERE  F.IDFacture = {pIDFacture}
