# Darou Rahmane Chicken — site web public

Boutique en ligne officielle : **https://darourahmane-chicken.onrender.com**

Le site reprend à l'identique l'interface de l'application Android v7.7
(WebView), adaptée au navigateur : même catalogue, même panier, mêmes
commandes, mêmes paiements (Wave, Orange Money, espèces à la livraison),
même espace gérant. Les commandes passées sur le site et dans l'application
arrivent dans la **même base**, sur le même serveur.

## Contenu

| Fichier | Rôle |
|---|---|
| `index.html` | Toute l'application (HTML + CSS + JS, sans dépendance) |
| `p1…p8.jpg/.webp`, `banner.*`, `logo*` | Visuels produits et marque |
| `manifest.json`, `icon-*.png`, `favicon.ico`, `apple-touch-icon.png` | Installation sur téléphone (PWA) et favicon |
| `og-image.jpg` | Aperçu lors d'un partage WhatsApp / Facebook / X |
| `robots.txt`, `sitemap.xml` | Indexation Google |
| `404.html` | Page d'erreur |

## Serveur (API)

Le site appelle l'API Node déjà déployée :
`https://drc-api-dj8t.onrender.com` (dépôt `ot4o4/drc-api`).
L'adresse par défaut est dans `index.html` :

```js
const API_BASE = (localStorage.getItem('drc_api') || 'https://drc-api-dj8t.onrender.com')
```

CORS est ouvert (`Access-Control-Allow-Origin: *`), le site peut donc être
hébergé n'importe où. En cas de changement de serveur, l'URL se modifie aussi
depuis le site : **Compte → Espace gérant → Serveur de l'app**.

## Mettre à jour le site

```bash
cd ~/drc-web
# modifier index.html ou les images
git add -A && git commit -m "…"
git push origin main
./deploy.sh          # déclenche le déploiement Render et vérifie la mise en ligne
```

`deploy.sh` lit la clé dans `~/.secrets/render_key`.

Un déploiement automatique vérifie toutes les 5 minutes la tête de
`ot4o4/drc-web` et redéploie dès qu'un commit apparaît (script
`~/.hermes/scripts/drc_autodeploy.py`, qui gère aussi l'API avec
sauvegarde/restauration de la base). GitHub Actions n'est pas utilisé car le
jeton GitHub disponible n'a pas le scope `workflow`.

## Hébergement

- Render, service **static_site** `darourahmane-chicken`
  (`srv-dbluinhsrm7s73efrr4g`), gratuit, HTTPS et CDN inclus.
- Dépôt : https://github.com/ot4o4/drc-web (public)
- Tableau de bord : https://dashboard.render.com/static/srv-dbluinhsrm7s73efrr4g

## Notes

- Le site est mobile-first ; sur ordinateur, l'interface est centrée dans une
  colonne de 780 px pour rester lisible.
- Aucune donnée n'est stockée sur le site : panier et historique local sont
  dans le `localStorage` du navigateur, les commandes sur l'API.
- Le numéro de téléphone du service client et les numéros Wave/Orange Money
  proviennent de l'API (`/api/health`, `/api/orders`).
