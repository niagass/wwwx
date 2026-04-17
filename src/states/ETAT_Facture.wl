// ============================================================================
//  État : ETAT_Facture  (ticket de caisse, format 80 mm ou A4)
// ============================================================================
//
// Source de données : requête REQ_Facture_Ticket (avec param {pIDFacture}).
// Sous-état (itération lignes) : requête REQ_Facture_Lignes avec le même param.
//
// STRUCTURE DE L'ÉTAT À CRÉER DANS L'IDE WinDev :
//
//   [Bloc Début de document]
//      LIB_Entete1      = "RestoManager"                         (centré, gras, 14pt)
//      LIB_Entete2      = "Adresse du restaurant"                (centré, 9pt)
//      LIB_Entete3      = "SIRET : ..."                          (centré, 9pt)
//      LIB_Ligne1       = "------------------------------------"
//      LIB_Numero       = "Facture N° {NumeroFacture}"
//      LIB_Date         = "Le {DateHeure} — Table {NumTable}"
//      LIB_Caissier     = "Caissier : {CaissierPrenom} {CaissierNom}"
//      LIB_Ligne2       = "------------------------------------"
//
//   [Bloc Corps / Sous-état (itération REQ_Facture_Lignes)]
//      COL_Nom          : NomPlat (largeur ~60%)
//      COL_Qte          : Quantite (largeur ~10%)
//      COL_PxU          : PrixUnitaire formaté (15%)
//      COL_SousTotal    : SousTotal formaté (15%)
//
//   [Bloc Fin de document]
//      LIB_Ligne3       = "------------------------------------"
//      LIB_TotalHT      = "Total HT : {TotalHT}"
//      LIB_TotalTVA     = "TVA {taux}% : {TotalTVA}"
//      LIB_TotalTTC     = "TOTAL TTC : {TotalTTC}"              (gras, 12pt)
//      LIB_ModePaiement = "Règlement : {ModePaiement}"
//      LIB_MontantRecu  = "Reçu : {MontantRecu}"                (si Especes)
//      LIB_Rendu        = "Rendu : {Rendu}"                     (si Especes)
//      LIB_Footer       = "Merci de votre visite !"             (centré, italique)
//      LIB_QRCode       (Code barre / QR : NumeroFacture)
//
// Événement "Initialisation" de l'état :
//   SI MoiMême.Paramètre[1] = "" ALORS MoiMême.Paramètre[1] = 0
//   nID est un entier = Val(MoiMême.Paramètre[1])
//   HExécuteRequête(REQ_Facture_Ticket, hRequêteDéfaut, nID)
//
// Événement "Initialisation" du sous-état (itération lignes) :
//   nID est un entier = Val(ÉtatEnCours..Paramètre[1])
//   HExécuteRequête(REQ_Facture_Lignes, hRequêteDéfaut, nID)
//
// Formatage monétaire : utiliser PROC_Utilitaires.FormaterMontant dans le code
//   de mise en forme des cellules.
