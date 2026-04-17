# Architecture

## Vue d'ensemble

Application monolithique WinDev, 3 couches logiques :

```
 ┌─────────────────────────────────────────┐
 │  UI (Fenêtres WinDev)                   │
 │  WIN_Connexion, WIN_Menu, WIN_Caisse... │
 └──────────────┬──────────────────────────┘
                │ appelle
 ┌──────────────▼──────────────────────────┐
 │  Couche métier (Classes + Procédures)   │
 │  cCommande, cFacture, PROC_Stock...     │
 └──────────────┬──────────────────────────┘
                │ lit/écrit
 ┌──────────────▼──────────────────────────┐
 │  Persistance HFSQL                      │
 │  Utilisateurs, Plats, Commandes, ...    │
 └─────────────────────────────────────────┘
```

## Conventions de nommage

| Élément | Préfixe | Exemple |
|---|---|---|
| Fenêtre | `WIN_` | `WIN_Caisse` |
| État (rapport) | `ETAT_` | `ETAT_Facture` |
| Requête | `REQ_` | `REQ_Ventes_Jour` |
| Classe | `c` + PascalCase | `cCommande` |
| Procédure globale | `PROC_` | `PROC_Stock.DecrementerStock` |
| Variable locale | camelCase | `prixUnitaire` |
| Variable membre classe | `m_` | `m_Total` |
| Constante | UPPER_SNAKE_CASE | `TVA_STANDARD` |
| Rubrique HFSQL | PascalCase | `DateHeureCommande` |

## Rôles utilisateurs

- **Admin** : accès total (incluant CRUD utilisateurs, plats, paramètres).
- **Caissier** : caisse, factures, consultation commandes.
- **Serveur** : plan de salle, prise de commande, envoi cuisine.
- **Cuisine** : consultation commandes en préparation (lecture seule + marquer « Prêt »).

Le contrôle d'accès se fait par `PROC_Auth.VerifierAcces(sFenetre)` appelé dans l'événement d'ouverture de chaque fenêtre protégée.

## Cycle de vie d'une commande

```
  [Prise cde]       [Envoi cuisine]      [Préparation]      [Service]          [Encaissement]
 EnCours  ───►  Envoyée  ───►  EnPreparation  ───►  Prete  ───►  Servie  ───►  Payee
                │
                └──► Annulee (motif requis, trace qui/quand)
```

Changement d'état centralisé dans `cCommande.ChangerStatut()` pour garantir :
- trace (qui a modifié, quand),
- vérification des règles (on ne peut pas passer de EnCours à Payee directement),
- décrément du stock au passage « EnCours → Envoyée ».

## Concurrence

- Transactions HFSQL (`HTransactionDébut` / `HTransactionFin`) pour :
  - passage d'une commande en `Payee` + création facture + décrément stock,
  - mouvements de stock sensibles.
- Verrouillage optimiste sur `Tables` (statut) : relecture avec `HLitRecherche` avant modification.
- Numérotation de facture via compteur automatique HFSQL (`AutoIdentifiant`) + format `FYYYYMM0000001` calculé à la validation.

## Sécurité

- Mots de passe hashés avec `HashChaîne(HA_SHA_256, sel + mdp)`, sel par utilisateur stocké dans `Utilisateurs.SelMDP`.
- Aucune requête SQL concaténée : uniquement requêtes paramétrées (`HExécuteRequête` avec paramètres).
- Journal des connexions et des opérations sensibles (annulation commande, modification prix) dans `JournalAudit`.
