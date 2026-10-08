# Chasseur de doublons

Outil web 100 % local pour repérer et supprimer les fichiers en double dans un dossier de votre ordinateur.

- Compare le **contenu réel** des fichiers (empreinte SHA-256), pas seulement les noms
- Affiche les groupes de doublons triés par espace récupérable
- Choix manuel par case à cocher, ou action groupée : **garder le plus ancien / le plus récent** pour tous les groupes
- Suppression par lots avec barre de progression
- Aucune donnée n'est envoyée sur internet : tout se passe dans le navigateur

## Prérequis

- **Chrome ou Edge** (l'API d'accès aux dossiers n'existe pas dans Firefox ni Safari)
- **Windows** : PowerShell (déjà installé)

## Lancement

Le fichier ne fonctionne pas en double-clic (le protocole `file://` bloque l'accès aux dossiers). Il faut le servir en `http://localhost` :

```powershell
./serve.ps1
```

Puis ouvrez **http://localhost:8080/doublons-fichiers.html** dans Edge ou Chrome.
Arrêtez le serveur avec `Ctrl+C` une fois terminé.

## Utilisation

1. Cliquez sur **Choisir un dossier** et sélectionnez le dossier à analyser (sous-dossiers inclus)
2. Attendez la fin de l'analyse
3. Choisissez quoi garder, soit à la main, soit avec les boutons d'action groupée
4. Cliquez sur **Supprimer les fichiers décochés** (la permission d'écriture est demandée à ce moment-là)

## Limites connues

- Les fichiers de plus de 300 Mo ne sont pas comparés automatiquement
- Les fichiers OneDrive « en ligne uniquement » sont ignorés : faites clic droit → *Toujours conserver sur cet appareil* avant le scan
- La suppression est **définitive** (pas de corbeille) : vérifiez votre sélection avant de valider

## Choix de sécurité

- **Noms de fichiers non fiables** : les noms et chemins lus sur le disque sont échappés avant affichage (pas d'injection de code via un nom de fichier piégé)
- **Aucune sortie réseau** : une politique CSP (`connect-src 'none'`) empêche la page d'envoyer des données à l'extérieur, même en cas de faille
- **Serveur local minimal** (`serve.ps1`) : écoute uniquement sur `localhost`, ne sert qu'un seul fichier (`doublons-fichiers.html`), refuse tout sauf `GET`/`HEAD`, vérifie l'en-tête `Host` (anti DNS rebinding) et n'expose aucun détail en cas d'erreur
- **Moindre privilège** : le dossier est ouvert en lecture seule pour l'analyse ; l'écriture n'est demandée qu'au moment de supprimer
- **Garde-fou** : impossible de supprimer toutes les copies d'un même groupe

Les règles de sécurité et d'éthique appliquées à ce projet sont décrites dans [`CLAUDE.md`](CLAUDE.md).
