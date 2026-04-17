# RestoManager — Gestion de restaurant (WinDev / WLangage)

Application complète de gestion de restaurant développée en **WLangage** pour **WinDev 2x** (PC SOFT), avec base de données **HFSQL Classic** (ou Client/Serveur).

## Périmètre fonctionnel

| Module | Fonctionnalités |
|---|---|
| Authentification | Connexion par login/mot de passe, gestion des rôles (Admin, Caissier, Serveur, Cuisine) |
| Plan de salle | Vue graphique des tables, statut Libre/Occupée/Réservée, affectation serveur |
| Prise de commande | Sélection plats par catégorie, quantités, notes, envoi cuisine |
| Caisse / Facturation | Édition ticket, TVA, modes paiement (espèces/carte/chèque), rendu monnaie |
| Gestion du menu | Plats, catégories, prix, disponibilité, composition (ingrédients) |
| Stock | Ingrédients, mouvements (entrées/sorties/ajustements), décrément automatique à la commande, alerte stock bas |
| Réservations | Clients, créneaux, nb personnes, statut |
| Statistiques | CA jour/mois, plats populaires, TVA, ventes par serveur |
| Utilisateurs | CRUD utilisateurs, réinitialisation mdp, activation/désactivation |

## Stack technique

- **IDE** : WinDev 23+ (testé en tant que code cible WinDev 23 ; aucune utilisation de `PROCEDURE INTERNE` ni de tableaux littéraux multidim introduits en versions plus récentes).
- **Langage** : WLangage.
- **BDD** : HFSQL Classic (mono-poste) ou Client/Serveur (multi-poste).
- **Cible** : Windows 10/11.

## Limitation — Pourquoi pas de fichier `.WDP` ?

Les fichiers projet WinDev (`.WDP`, `.WDW`, `.WDR`, `.WDCLS`, etc.) sont des fichiers **binaires propriétaires** qui ne peuvent être créés qu'avec l'IDE WinDev sous Windows. Ce dépôt contient donc :

- L'**analyse** (schéma HFSQL) sous forme de documentation + script SQL équivalent.
- Le **code WLangage** des fenêtres, classes, procédures globales, requêtes, états — au format `.wl` (texte).
- Un **guide d'import pas-à-pas** dans WinDev.

Voir [`docs/INSTALLATION.md`](docs/INSTALLATION.md) pour le processus complet d'import.

## Structure du dépôt

```
wwwx/
├── README.md
├── docs/
│   ├── ARCHITECTURE.md       Architecture & conventions
│   ├── INSTALLATION.md       Import dans WinDev
│   ├── MODELE_DONNEES.md     Schéma des tables HFSQL
│   └── GUIDE_UTILISATEUR.md  Utilisation fonctionnelle
├── analyse/
│   ├── schema_hfsql.txt      Description des rubriques/liens
│   └── schema.sql            Équivalent SQL (référence)
├── src/
│   ├── classes/              Classes métier (cUtilisateur, cCommande...)
│   ├── windows/              Code des fenêtres (UI + événements)
│   ├── procedures/           Procédures globales (Auth, Stock, Factu...)
│   ├── queries/              Requêtes SQL nommées
│   └── states/               États (ticket facture)
└── scripts/
    └── init_donnees_exemple.wl  Jeu de données de démo
```

## Démarrage rapide

1. Lire [`docs/INSTALLATION.md`](docs/INSTALLATION.md).
2. Créer un projet vide dans WinDev → « Projet Windows ».
3. Créer l'**analyse** en suivant [`analyse/schema_hfsql.txt`](analyse/schema_hfsql.txt) (ou importer le SQL).
4. Créer les **classes** dans l'IDE et copier le code depuis `src/classes/`.
5. Idem pour **procédures globales**, **fenêtres**, **requêtes**, **états**.
6. Lancer le script `scripts/init_donnees_exemple.wl` une fois pour peupler la BDD.
7. Exécuter → la fenêtre de connexion s'affiche. Login par défaut : `admin` / `admin`.

## Licence

À définir par le propriétaire du dépôt.
