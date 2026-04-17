# Installation dans WinDev

Ce guide décrit pas-à-pas la création d'un projet WinDev à partir des sources textuelles de ce dépôt.

## Prérequis

- WinDev 23 (ou supérieur) installé sur Windows 7 SP1 / 10 / 11.
- Droits d'écriture sur le poste.
- Environ 200 Mo d'espace disque pour le projet + données.

## 1. Créer le projet

1. Lancer WinDev → **Accueil → Créer un projet → Projet Windows**.
2. Nom : `RestoManager`. Type : **Application Windows (.EXE)**. Framework : monobloc.
3. Décocher « Créer l'analyse maintenant ».
4. Valider.

## 2. Créer l'analyse (base de données)

1. Volet **Explorateur → Analyse → Nouveau → Analyse**.
2. Nom : `RestoManager_Analyse`. Type : **HFSQL Classic** (ou **HFSQL Client/Serveur** si multi-poste).
3. Ouvrir [`analyse/schema_hfsql.txt`](../analyse/schema_hfsql.txt) : créer **chaque fichier** (table) en respectant rubriques, types, tailles, clés, liens.
4. **Alternative rapide** : utiliser l'assistant **« Importer depuis un script SQL »** et pointer sur [`analyse/schema.sql`](../analyse/schema.sql). Vérifier ensuite que les clés primaires et liens sont corrects dans la vue analyse.
5. Générer l'analyse (**F7**).

## 3. Créer les classes

Pour chaque fichier dans `src/classes/` :

1. Volet **Explorateur → Classes → Nouveau → Classe**.
2. Nommer la classe comme le fichier (sans extension), par ex. `cCommande`.
3. Ouvrir la classe → coller **intégralement** le contenu du fichier `.wl` dans la partie **Membres** puis **Méthodes** selon les marqueurs `// --- MEMBRES ---` / `// --- METHODES ---`.

## 4. Créer les procédures globales

Créer un **ensemble de procédures** par fichier de `src/procedures/` :

1. Volet **Explorateur → Procédures → Nouveau → Ensemble de procédures globales**.
2. Nom : identique au fichier (ex. `PROC_Commandes`).
3. Copier toutes les procédures du `.wl` correspondant dans l'ensemble.

## 5. Créer les fenêtres

Pour chaque fichier dans `src/windows/` :

1. Volet **Explorateur → Fenêtres → Nouveau → Fenêtre**.
2. Dans chaque `.wl` se trouve au début un **bloc commenté `// UI`** listant les champs à créer (nom, type, libellé, position approximative). Placer ces champs dans la fenêtre (la disposition exacte reste libre).
3. Copier les blocs de code dans les événements correspondants (signalés par `// @Evt: NomEvenement de NomChamp`).

## 6. Créer les requêtes

Pour chaque fichier dans `src/queries/` :

1. Volet **Explorateur → Requêtes → Nouveau → Requête en mode SQL**.
2. Nom : identique au fichier.
3. Coller le SQL.

## 7. Créer l'état (rapport facture)

1. Volet **Explorateur → États → Nouveau → État basé sur une requête**.
2. Nom : `ETAT_Facture`.
3. Source : requête `REQ_Facture_Ticket` (fournie).
4. Ajouter les blocs et champs décrits dans `src/states/ETAT_Facture.wl`.

## 8. Initialisation des données d'exemple

1. Volet **Explorateur → Procédures → PROC_Init → InitialiserDonneesExemple**.
2. Depuis le code du projet ou la fenêtre de connexion, exécuter une fois :

```wlangage
PROC_Init.InitialiserDonneesExemple()
```

Cela crée :
- un utilisateur admin (`admin` / `admin`),
- 3 catégories (Entrées, Plats, Desserts),
- 12 plats,
- 20 tables,
- quelques ingrédients et mouvements de stock.

## 9. Tester

- **F9** pour exécuter le projet.
- Se connecter avec `admin` / `admin`.
- Menu principal → Plan de salle → choisir une table → Prendre commande.

## Dépannage

| Symptôme | Cause probable | Solution |
|---|---|---|
| « Fichier XYZ n'existe pas » au 1er lancement | HFSQL n'a pas créé les `.FIC` | Appeler `HCréation` pour chaque fichier dans `PROJET.Initialisation` (déjà présent dans `src/procedures/PROC_Init.wl`) |
| Police illisible | DPI Windows > 100% | Activer « Mise à l'échelle automatique » dans les options projet |
| Login refusé après init | Hash mdp différent | Ré-exécuter `PROC_Init.InitialiserDonneesExemple()` (idempotent) |
