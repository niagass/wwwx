-- REQ_Ventes_Jour : CA, nb factures, ticket moyen pour une journée donnée.
-- Paramètres : {pDate} (DATE)
SELECT COUNT(*)                       AS NbFactures,
       SUM(TotalTTC)                  AS CA_TTC,
       SUM(TotalHT)                   AS CA_HT,
       SUM(TotalTVA)                  AS TotalTVA,
       CASE WHEN COUNT(*) = 0 THEN 0
            ELSE SUM(TotalTTC) / COUNT(*)
       END                            AS TicketMoyen
FROM   Factures
WHERE  CAST(DateHeure AS DATE) = {pDate}
