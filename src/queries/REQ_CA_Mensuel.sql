-- REQ_CA_Mensuel : CA agrégé par mois (12 derniers mois).
-- Utile pour un histogramme tendanciel.
SELECT YEAR(DateHeure)   AS Annee,
       MONTH(DateHeure)  AS Mois,
       COUNT(*)          AS NbFactures,
       SUM(TotalTTC)     AS CA_TTC
FROM   Factures
WHERE  DateHeure >= DATEADD(MONTH, -12, CURRENT_TIMESTAMP)
GROUP BY YEAR(DateHeure), MONTH(DateHeure)
ORDER BY Annee, Mois
