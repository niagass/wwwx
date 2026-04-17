# Changelog

## [0.1.0] — Initial skeleton

### Added
- Analyse HFSQL complète (13 tables + index recommandés).
- Schéma SQL équivalent pour import rapide.
- Classes WLangage : `cUtilisateur`, `cCommande`, `cLigneCommande`, `cFacture`, `cStock`.
- Procédures globales : `PROC_Auth`, `PROC_Utilitaires`, `PROC_Stock`, `PROC_Commandes`, `PROC_Init`.
- Fenêtres : Connexion, Menu_Principal, Plan_Salle, Prise_Commande, Caisse, Cuisine, Gestion_Plats, Gestion_Stock, Reservations, Clients, Statistiques, Utilisateurs.
- Requêtes SQL : ventes du jour, stock bas, plats populaires, CA mensuel, facture ticket + lignes.
- État `ETAT_Facture` (spec).
- Documentation : README, ARCHITECTURE, INSTALLATION, MODELE_DONNEES, GUIDE_UTILISATEUR.
- Script d'initialisation avec jeu de données de démo (admin/admin, 3 catégories, 12 plats, 20 tables, 7 ingrédients).
