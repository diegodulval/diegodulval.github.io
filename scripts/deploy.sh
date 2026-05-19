#!/usr/bin/env bash
set -euo pipefail

HOSTINGER_HOST="${HOSTINGER_HOST:-45.132.157.16}"
HOSTINGER_PORT="${HOSTINGER_PORT:-65002}"
USER="u229535118"
DEST="/home/$USER/domains/dulval.com/public_html"
REMOTE="$USER@$HOSTINGER_HOST"
SSH="ssh -p $HOSTINGER_PORT"
SCP="rsync -avz --delete -e \"$SSH\""

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

# ── 1. Build ──────────────────────────────────────────────────────────────────
echo "▶ Building..."
cd dulval && pnpm install --frozen-lockfile && pnpm build && cd "$ROOT"

DIST="$ROOT/dulval/dist"

# ── 2. dulval.com (raiz) ──────────────────────────────────────────────────────
# Deploya o dist inteiro na raiz — substitui os arquivos antigos
echo "▶ Deploying dulval.com (raiz)..."
rsync -avz --delete -e "$SSH" "$DIST/" "$REMOTE:$DEST/"

# ── 3. Subdomínios ────────────────────────────────────────────────────────────
# Cada subdomínio precisa de:
#   - seus próprios arquivos (dist/<portal>/)
#   - a pasta _astro/ (assets CSS/JS/media — paths absolutos /_astro/...)
#   - os favicons referenciados como /favicon.* na raiz
#
# Hostinger: configure o Document Root de cada subdomínio para public_html/<portal>/
# hPanel → Domains → Subdomínios → editar → Document Root

PORTALS=(me conecta cafe agro labs edu)

for portal in "${PORTALS[@]}"; do
  echo "▶ Deploying ${portal}.dulval.com..."

  # Conteúdo do portal
  rsync -avz --delete -e "$SSH" "$DIST/$portal/" "$REMOTE:$DEST/$portal/"

  # Assets compartilhados (CSS, JS, video — referenciados como /_astro/...)
  rsync -avz --delete -e "$SSH" "$DIST/_astro/" "$REMOTE:$DEST/$portal/_astro/"

  # Favicons (referenciados como /favicon.svg etc.)
  for asset in favicon.svg favicon.ico dd-app-logo.png; do
    [ -f "$DIST/$asset" ] && rsync -avz -e "$SSH" "$DIST/$asset" "$REMOTE:$DEST/$portal/$asset"
  done
done

echo ""
echo "✓ Deploy concluído"
echo ""
echo "Lembrete — Document Root no hPanel (Domains → Subdomínios):"
for portal in "${PORTALS[@]}"; do
  echo "  ${portal}.dulval.com  →  public_html/${portal}"
done
