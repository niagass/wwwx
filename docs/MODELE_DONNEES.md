# Modèle de données

## Diagramme conceptuel

```
 Utilisateurs ───< Commandes >─── Tables
      │                │
      │                ├──< LignesCommande >─── Plats >─── Categories
      │                │                              │
      │                └──── Factures                 └──< PlatsIngredients >─── Ingredients
      │                                                                              │
      └──< JournalAudit                                                MouvementsStock ┘

 Clients ───< Reservations >─── Tables
```

## Tables

### Utilisateurs
| Rubrique | Type | Taille | Clé | Notes |
|---|---|---|---|---|
| IDUtilisateur | Entier auto | — | PK | |
| Login | Chaîne | 32 | Unique | |
| MotDePasseHash | Chaîne binaire | 64 | — | SHA-256 |
| SelMDP | Chaîne | 32 | — | Sel aléatoire par utilisateur |
| Nom | Chaîne | 64 | — | |
| Prenom | Chaîne | 64 | — | |
| Role | Chaîne | 16 | — | Admin / Caissier / Serveur / Cuisine |
| Actif | Booléen | — | — | |
| DateCreation | DateHeure | — | — | |

### Categories
| Rubrique | Type | Taille | Clé |
|---|---|---|---|
| IDCategorie | Entier auto | — | PK |
| Nom | Chaîne | 32 | Unique |
| OrdreAffichage | Entier | — | — |
| CouleurRGB | Entier | — | — |

### Plats
| Rubrique | Type | Taille | Clé |
|---|---|---|---|
| IDPlat | Entier auto | — | PK |
| IDCategorie | Entier | — | FK → Categories |
| Nom | Chaîne | 64 | — |
| Description | Texte | — | — |
| Prix | Monétaire | — | — |
| Actif | Booléen | — | — |
| TempsPreparation | Entier | — | minutes |
| Image | Mémo binaire | — | — |

### Ingredients
| Rubrique | Type | Taille | Clé |
|---|---|---|---|
| IDIngredient | Entier auto | — | PK |
| Nom | Chaîne | 64 | Unique |
| Unite | Chaîne | 8 | kg, L, pièce, ... |
| StockActuel | Réel | — | — |
| StockMin | Réel | — | seuil d'alerte |
| PrixAchatUnitaire | Monétaire | — | — |

### PlatsIngredients (composition)
| Rubrique | Type | Clé |
|---|---|---|
| IDPlat | Entier | PK composée, FK |
| IDIngredient | Entier | PK composée, FK |
| Quantite | Réel | — |

### Tables
| Rubrique | Type | Taille | Clé |
|---|---|---|---|
| IDTable | Entier auto | — | PK |
| Numero | Entier | — | Unique |
| Capacite | Entier | — | — |
| Statut | Chaîne | 16 | Libre / Occupee / Reservee |
| Zone | Chaîne | 32 | Terrasse, Salle, ... |

### Clients
| Rubrique | Type | Taille | Clé |
|---|---|---|---|
| IDClient | Entier auto | — | PK |
| Nom | Chaîne | 64 | — |
| Prenom | Chaîne | 64 | — |
| Telephone | Chaîne | 20 | — |
| Email | Chaîne | 128 | — |
| Notes | Texte | — | — |

### Reservations
| Rubrique | Type | Clé |
|---|---|---|
| IDReservation | Entier auto | PK |
| IDClient | Entier | FK |
| IDTable | Entier | FK |
| DateHeure | DateHeure | — |
| NbPersonnes | Entier | — |
| Statut | Chaîne(16) | Attente / Confirmee / Honoree / Annulee |
| Notes | Texte | — |

### Commandes
| Rubrique | Type | Clé |
|---|---|---|
| IDCommande | Entier auto | PK |
| IDTable | Entier | FK |
| IDServeur | Entier | FK → Utilisateurs |
| DateHeureOuverture | DateHeure | — |
| DateHeureCloture | DateHeure | nullable |
| Statut | Chaîne(16) | EnCours / Envoyee / Servie / Payee / Annulee |
| Notes | Texte | — |
| TotalHT | Monétaire | calculé |
| TotalTVA | Monétaire | calculé |
| TotalTTC | Monétaire | calculé |

### LignesCommande
| Rubrique | Type | Clé |
|---|---|---|
| IDLigne | Entier auto | PK |
| IDCommande | Entier | FK |
| IDPlat | Entier | FK |
| Quantite | Entier | — |
| PrixUnitaire | Monétaire | — |
| Notes | Chaîne(255) | — |
| Statut | Chaîne(16) | Attente / EnPreparation / Pret / Servi |

### Factures
| Rubrique | Type | Clé |
|---|---|---|
| IDFacture | Entier auto | PK |
| IDCommande | Entier | FK unique |
| NumeroFacture | Chaîne(20) | Unique, format `FAAAAMM0000001` |
| DateHeure | DateHeure | — |
| IDCaissier | Entier | FK |
| TotalHT | Monétaire | — |
| TotalTVA | Monétaire | — |
| TotalTTC | Monétaire | — |
| ModePaiement | Chaîne(16) | Especes / Carte / Cheque |
| MontantRecu | Monétaire | — |
| Rendu | Monétaire | — |

### MouvementsStock
| Rubrique | Type | Clé |
|---|---|---|
| IDMouvement | Entier auto | PK |
| IDIngredient | Entier | FK |
| TypeMouvement | Chaîne(16) | Entree / Sortie / Ajustement |
| Quantite | Réel | positive |
| DateHeure | DateHeure | — |
| IDUtilisateur | Entier | FK |
| Motif | Chaîne(255) | — |
| Reference | Chaîne(32) | ex. IDCommande pour lier |

### JournalAudit
| Rubrique | Type | Clé |
|---|---|---|
| IDAudit | Entier auto | PK |
| DateHeure | DateHeure | — |
| IDUtilisateur | Entier | FK |
| Action | Chaîne(64) | ex. `COMMANDE_ANNULEE`, `PRIX_MODIFIE` |
| Detail | Texte | JSON libre |
| IPPoste | Chaîne(45) | — |

## Index recommandés

- `Commandes.DateHeureOuverture` (recherches stats)
- `Commandes.Statut` (listing caisse)
- `LignesCommande.IDCommande` (jointure fréquente)
- `Factures.DateHeure` + `NumeroFacture`
- `MouvementsStock.DateHeure` + `IDIngredient`
