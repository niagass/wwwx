# Création de l'analyse HFSQL dans l'IDE WinDev 23 (pas-à-pas)

Ce guide décrit comment **recréer manuellement** l'analyse RestoManager
directement dans l'éditeur d'analyse de WinDev 23, sans passer par l'import
SQL (dont la compatibilité varie selon le patch de WinDev 23).

**Durée estimée** : 45 min à 1 h pour les 13 fichiers.

## 1. Créer l'analyse

1. Dans WinDev 23, projet ouvert → volet **Explorateur** → clic droit sur
   *Analyse* → **Nouveau** → **Analyse**.
2. Assistant :
   - Nom : `RestoManager`
   - Type : **HFSQL Classic** (ou Client/Serveur si vous avez un serveur)
   - Emplacement : accepter le dossier par défaut.
3. L'éditeur d'analyse s'ouvre sur un canevas vide.

## 2. Créer chaque fichier (table)

Pour **chaque** fichier de la liste ci-dessous :

1. Menu **Analyse** → **Nouveau fichier** (raccourci *F2*).
2. Assistant :
   - Nom du fichier : *cf. colonne Nom*
   - Type : **HFSQL Classic**
   - Description : *cf. colonne Description* (libre, pour la doc)
   - Cliquer *Suivant* jusqu'à l'onglet **Rubriques**.
3. Ajouter chaque rubrique avec le type, la taille et les options indiqués.
4. Valider.

### Conventions

- Toutes les clés primaires sont des **entiers 4 octets** avec les options
  **Clé unique** + **Identifiant automatique** cochées.
- Toutes les chaînes sont déclarées **Chaîne Unicode** (support des accents).
- Les dates/heures sont des **Date et heure** (type DateHeure WinDev).
- Les booléens sont déclarés **Booléen** (champ case à cocher).
- Les montants sont déclarés **Monétaire** (4 décimales, calculs exacts).

### Liste des 13 fichiers

| Nom | Description | Rubriques principales |
|---|---|---|
| **Utilisateurs** | Comptes utilisateurs | IDUtilisateur (clé auto), Login (chaîne 32, **clé unique**), MotDePasseHash (chaîne 64), SelMDP (chaîne 32), Nom (chaîne 64), Prenom (chaîne 64), Role (chaîne 16), Actif (booléen), DateCreation (date+heure) |
| **Categories** | Catégories de plats | IDCategorie (clé auto), Nom (chaîne 32, **clé unique**), OrdreAffichage (entier 4), CouleurRGB (entier 4) |
| **Plats** | Plats de la carte | IDPlat (clé auto), IDCategorie (entier 4, **liaison** vers Categories), Nom (chaîne 64), Description (texte), Prix (monétaire), Actif (booléen), TempsPreparation (entier 4), Image (mémo binaire) |
| **Ingredients** | Ingrédients en stock | IDIngredient (clé auto), Nom (chaîne 64, **clé unique**), Unite (chaîne 8), StockActuel (réel 8), StockMin (réel 8), PrixAchatUnitaire (monétaire) |
| **PlatsIngredients** | Composition des plats | IDPlat (entier 4, **clé composite** avec IDIngredient, liaison vers Plats), IDIngredient (entier 4, liaison vers Ingredients), Quantite (réel 8) |
| **Tables** | Tables du restaurant | IDTable (clé auto), Numero (entier 4, **clé unique**), Capacite (entier 4), Statut (chaîne 16), Zone (chaîne 32) |
| **Clients** | Clients du restaurant | IDClient (clé auto), Nom (chaîne 64), Prenom (chaîne 64), Telephone (chaîne 20), Email (chaîne 128), Notes (texte) |
| **Reservations** | Réservations | IDReservation (clé auto), IDClient (entier 4, liaison Clients), IDTable (entier 4, liaison Tables), DateHeure (date+heure), NbPersonnes (entier 4), Statut (chaîne 16), Notes (texte) |
| **Commandes** | Commandes à table | IDCommande (clé auto), IDTable (entier 4, liaison Tables), IDServeur (entier 4, liaison Utilisateurs), DateHeureOuverture (date+heure), DateHeureCloture (date+heure, *valeur par défaut NULL*), Statut (chaîne 16), Notes (texte), TotalHT/TotalTVA/TotalTTC (monétaires) |
| **LignesCommande** | Lignes de commande | IDLigne (clé auto), IDCommande (entier 4, liaison Commandes **avec intégrité**), IDPlat (entier 4, liaison Plats), Quantite (entier 4), PrixUnitaire (monétaire), Notes (chaîne 255), Statut (chaîne 16) |
| **Factures** | Factures émises | IDFacture (clé auto), IDCommande (entier 4, **clé unique**, liaison Commandes), NumeroFacture (chaîne 20, **clé unique**), DateHeure (date+heure), IDCaissier (entier 4, liaison Utilisateurs), TotalHT/TotalTVA/TotalTTC (monétaires), ModePaiement (chaîne 16), MontantRecu (monétaire), Rendu (monétaire) |
| **MouvementsStock** | Journal des mouvements de stock | IDMouvement (clé auto), IDIngredient (entier 4, liaison Ingredients), TypeMouvement (chaîne 16), Quantite (réel 8), DateHeure (date+heure), IDUtilisateur (entier 4, liaison Utilisateurs), Motif (chaîne 255), Reference (chaîne 32) |
| **JournalAudit** | Journal d'audit | IDAudit (clé auto), DateHeure (date+heure), IDUtilisateur (entier 4, nullable, liaison Utilisateurs), Action (chaîne 64), Detail (texte), IPPoste (chaîne 45) |

## 3. Créer les liaisons (clés étrangères)

1. Dans l'éditeur d'analyse, tracer une flèche **du fichier enfant vers le
   fichier parent** en reliant la clé étrangère (ex. `Plats.IDCategorie`)
   à la clé primaire du parent (`Categories.IDCategorie`).
2. Dans la boîte de dialogue qui s'ouvre :
   - Type : **Relation 0,n — 1,1**
   - **Intégrité référentielle** : cocher « Vérifier l'intégrité » et
     « Cascade » (utile surtout pour `LignesCommande.IDCommande` →
     suppression d'une commande = suppression des lignes).

Liaisons à créer (14 au total) :

- `Plats.IDCategorie`          → `Categories.IDCategorie`
- `PlatsIngredients.IDPlat`    → `Plats.IDPlat`        *(cascade)*
- `PlatsIngredients.IDIngredient` → `Ingredients.IDIngredient`
- `Reservations.IDClient`      → `Clients.IDClient`
- `Reservations.IDTable`       → `Tables.IDTable`
- `Commandes.IDTable`          → `Tables.IDTable`
- `Commandes.IDServeur`        → `Utilisateurs.IDUtilisateur`
- `LignesCommande.IDCommande`  → `Commandes.IDCommande` *(cascade)*
- `LignesCommande.IDPlat`      → `Plats.IDPlat`
- `Factures.IDCommande`        → `Commandes.IDCommande`
- `Factures.IDCaissier`        → `Utilisateurs.IDUtilisateur`
- `MouvementsStock.IDIngredient` → `Ingredients.IDIngredient`
- `MouvementsStock.IDUtilisateur` → `Utilisateurs.IDUtilisateur`
- `JournalAudit.IDUtilisateur` → `Utilisateurs.IDUtilisateur` *(nullable)*

## 4. Créer les index secondaires (optionnels mais recommandés)

Pour chaque index ci-dessous, dans l'éditeur du fichier concerné →
onglet **Rubriques** → sélectionner la rubrique → cocher **Clé** (non unique).

- `Commandes.DateHeureOuverture` → clé simple
- `Commandes.Statut`             → clé simple
- `LignesCommande.IDCommande`    → clé simple *(probablement déjà créée via la liaison)*
- `Factures.DateHeure`           → clé simple
- `MouvementsStock.DateHeure`    → clé simple
- `MouvementsStock.IDIngredient` → clé simple *(probablement déjà créée via la liaison)*
- `Reservations.DateHeure`       → clé simple
- `JournalAudit.DateHeure`       → clé simple

## 5. Générer l'analyse

1. Menu **Analyse** → **Génération** (raccourci **F7**).
2. Cocher *Compatible avec WinDev 23* si demandé.
3. Valider. WinDev génère les fichiers `.FIC` (structure) en mémoire.

## 6. Créer les fichiers physiques au 1er lancement

Les fichiers `.FIC`/`.NDX`/`.MMO` sur disque sont créés automatiquement par
`PROC_Init.InitialiserFichiers()` (appel à `HCréationSiInexistant` pour chaque
table). Ajouter à **PROJET.Initialisation** :

```wlangage
PROC_Init.InitialiserFichiers()
PROC_Init.InitialiserDonneesExemple()
```

Le premier lancement crée les fichiers vides + un jeu de données de démo
(utilisateurs `admin/admin`, `serveur1/demo`, `caisse1/demo`, `cuisine1/demo`,
3 catégories, 12 plats, 20 tables, 7 ingrédients).

## 7. Vérifier

- Dans l'éditeur d'analyse : les 13 fichiers doivent être visibles avec les
  liaisons tracées entre eux (schéma UML-like).
- F9 (exécution) : la fenêtre `WIN_Connexion` doit s'ouvrir, les fichiers
  `.FIC` apparaissent dans le dossier de données, la connexion `admin` /
  `admin` doit fonctionner.

## En cas d'erreur

- **« Fichier non créé »** : vérifier les droits sur le dossier de données
  (par défaut `%AppData%\RestoManager\` en mode Classic).
- **« Clé dupliquée » à l'insertion** : vérifier que les rubriques marquées
  *Clé unique* le sont bien.
- **« Intégrité référentielle violée »** : vérifier la cohérence des
  liaisons et l'ordre d'insertion des jeux de données de démo.

---

En cas de doute sur un détail, la description de référence des 13 tables
reste `analyse/schema_hfsql.txt`.
