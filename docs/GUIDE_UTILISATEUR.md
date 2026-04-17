# Guide utilisateur

## Connexion

- Saisir login et mot de passe. Bouton **Se connecter**.
- Compte admin par défaut après initialisation : `admin` / `admin` (à changer immédiatement).

## Menu principal (Admin)

Tuiles :
- **Plan de salle** — commencer le service
- **Caisse** — encaisser les commandes terminées
- **Réservations** — calendrier + liste du jour
- **Plats** — CRUD menu
- **Stock** — ingrédients & mouvements
- **Clients** — fidélité / coordonnées
- **Statistiques** — CA, plats populaires
- **Utilisateurs** (Admin seulement)
- **Quitter**

## Prendre une commande (Serveur)

1. **Plan de salle** → clic sur une table libre.
2. Saisir nb personnes → **Ouvrir commande**.
3. Choisir une catégorie (onglets) puis un plat → il s'ajoute à la commande.
4. Modifier quantité/notes via la grille à droite.
5. **Envoyer en cuisine** → la commande passe en `Envoyee`, le stock est décrémenté, l'imprimante cuisine reçoit un ticket (si configurée).
6. À la fin du service : **Clôturer** → commande en attente d'encaissement.

## Encaisser (Caissier)

1. **Caisse** → liste des commandes `Servie` non payées.
2. Sélectionner une commande → ticket affiché.
3. Choisir **mode de paiement** :
   - Espèces : saisir montant reçu, le rendu est calculé.
   - Carte / Chèque : saisir le montant (doit être égal au total).
4. **Valider paiement** → impression ticket, commande en `Payee`, la table passe en `Libre`.

## Gérer le stock

- **Stock → Liste ingrédients** : stock actuel vs seuil min (ligne rouge si sous seuil).
- **Nouveau mouvement** : type (Entrée/Sortie/Ajustement), quantité, motif.
- Sorties automatiques lors de l'envoi d'une commande en cuisine (selon composition `PlatsIngredients`).

## Réservations

- Saisir client (sélection ou création), date/heure, nb personnes, table souhaitée.
- Bouton **Confirmer** → table passe en `Reservee` sur la plage concernée.
- Bouton **Honorer** au moment de l'arrivée → convertit en ouverture de commande.

## Statistiques

- Période (jour/semaine/mois/plage libre).
- Indicateurs : CA TTC, nombre de couverts, ticket moyen, top 10 plats, CA par serveur.
- Export CSV disponible.

## Administration

- **Utilisateurs** : créer, désactiver, réinitialiser mot de passe.
- **Plats** : activer/désactiver (sans perdre l'historique), modifier prix (traçé dans JournalAudit).
- **Paramètres** (constantes en dur pour l'instant) : taux TVA, devise, en-tête ticket.
