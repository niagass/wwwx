// ============================================================================
//  Ensemble de procédures globales : PROC_Utilitaires
//  Constantes globales, helpers, journalisation.
// ============================================================================

CONSTANT
    TVA_TAUX_STANDARD = 20.0   // %
    DEVISE            = "€"
    ENTETE_TICKET_1   = "RestoManager"
    ENTETE_TICKET_2   = "Adresse du restaurant"
    ENTETE_TICKET_3   = "SIRET : 000 000 000 00000"
FIN

// Taux de TVA appliqué (centralisé).
PROCEDURE TauxTVA() : réel
    RENVOYER TVA_TAUX_STANDARD

// Formate un montant avec devise : 12.40 -> "12,40 €"
PROCEDURE FormaterMontant(nMontant est un monétaire) : chaîne
    RENVOYER NumériqueVersChaîne(nMontant, "2d,2") + " " + DEVISE

// Sel aléatoire pour le hash de mot de passe (32 hex).
PROCEDURE GenererSel() : chaîne
    sRes est une chaîne = ""
    POUR i = 1 À 32
        sRes += Milieu("0123456789abcdef", Hasard(1, 16), 1)
    FIN
    RENVOYER sRes

// Hash SHA-256 de (sel + mdp).
PROCEDURE HasherMDP(sMdp est une chaîne, sSel est une chaîne) : chaîne
    RENVOYER ChaîneVersHexa(HashChaîne(HA_SHA_256, sSel + sMdp))

// Journalise une action dans JournalAudit.
PROCEDURE JournaliserAction(nIDUser est un entier, sAction est une chaîne, sDetail est une chaîne = "")
    HRAZ(JournalAudit)
    JournalAudit.DateHeure     = DateHeureSys()
    JournalAudit.IDUtilisateur = nIDUser
    JournalAudit.Action        = sAction
    JournalAudit.Detail        = sDetail
    JournalAudit.IPPoste       = NetAdresseIP()
    HAjoute(JournalAudit)

// Exporte une table WinDev en CSV sur disque.
PROCEDURE ExporterTableCSV(tabSrc est un Champ, sChemin est une chaîne) : booléen
    sContenu est une chaîne = ""
    // En-têtes
    POUR i = 1 À tabSrc.Colonne..Occurrence
        sContenu += tabSrc.Colonne[i]..Libellé + TAB
    FIN
    sContenu = Gauche(sContenu, Taille(sContenu) - 1) + RC
    // Données
    POUR i = 1 À tabSrc..Occurrence
        POUR j = 1 À tabSrc.Colonne..Occurrence
            sContenu += tabSrc.Colonne[j][i] + TAB
        FIN
        sContenu = Gauche(sContenu, Taille(sContenu) - 1) + RC
    FIN
    RENVOYER fSauveTexte(sChemin, sContenu)

// Validation simple d'email.
PROCEDURE EmailValide(sEmail est une chaîne) : booléen
    SI sEmail = "" ALORS RENVOYER Vrai      // email optionnel
    RENVOYER VérifieEmail(sEmail)
