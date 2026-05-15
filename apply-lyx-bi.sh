#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
#  Lyx Design System BI v2 — instalação única (BI variant)
#  Aplica tokens + components + dashboard charts em projeto Next.js BI.
#  Uso: bash apply-lyx-bi.sh <caminho-do-projeto>
# ─────────────────────────────────────────────────────────────
set -e

DS_DIR="$(cd "$(dirname "$0")" && pwd)"
TARGET="$1"

[ -z "$TARGET" ] && { echo "Uso: bash apply-lyx-bi.sh <caminho-do-projeto>"; exit 1; }
[ ! -d "$TARGET" ] && { echo "Erro: pasta '$TARGET' não encontrada"; exit 1; }
[ ! -f "$TARGET/package.json" ] && { echo "Erro: '$TARGET' não é Node project"; exit 1; }
grep -q '"next"' "$TARGET/package.json" || { echo "Erro: '$TARGET' não usa Next.js"; exit 1; }
command -v npm >/dev/null || { echo "Erro: npm não encontrado"; exit 1; }

if [ -d "$TARGET/src/app" ]; then
  APP_DIR="$TARGET/src/app"; COMP="$TARGET/src/components"; LIB="$TARGET/src/lib"
elif [ -d "$TARGET/app" ]; then
  APP_DIR="$TARGET/app"; COMP="$TARGET/components"; LIB="$TARGET/lib"
else
  echo "Erro: App Router não encontrado"; exit 1
fi

echo "▶ Aplicando Lyx DS BI v2 em: $TARGET"
echo ""

# ── 1. Deps ──
echo "[1/5] Instalando dependências (BI)..."
DEPS="class-variance-authority clsx tailwind-merge tw-animate-css lucide-react radix-ui zod \
@tanstack/react-query sonner recharts react-hook-form @hookform/resolvers \
better-auth @supabase/supabase-js @supabase/ssr date-fns"
( cd "$TARGET" && npm install $DEPS 2>&1 | tail -3 )

# ── 2. Tokens ──
echo "[2/5] Copiando tokens (globals.css)..."
cp "$DS_DIR/tokens/globals.css" "$APP_DIR/globals.css"

# ── 3. Components ──
echo "[3/5] Copiando components/ui + helpers..."
mkdir -p "$COMP/ui" "$LIB" "$TARGET/public"
cp -r "$DS_DIR/components/ui/"*.tsx "$COMP/ui/"
cp "$DS_DIR/components/lyx-modal.tsx" "$COMP/"
cp "$DS_DIR/components/providers.tsx" "$COMP/"
cp "$DS_DIR/components/theme-toggle.tsx" "$COMP/"

# ── 4. Lib BI (supabase + auth + queries) ──
echo "[4/5] Copiando lib BI (Supabase + auth + queries)..."
cp "$DS_DIR/lib/utils.ts" "$LIB/"
cp "$DS_DIR/lib/supabase.ts" "$LIB/"
cp "$DS_DIR/lib/auth-client.ts" "$LIB/"
# queries.ts: só copia se NÃO existir (não sobrescreve queries customizadas)
if [ ! -f "$LIB/queries.ts" ]; then
  cp "$DS_DIR/lib/queries.ts" "$LIB/"
  echo "      ✓ queries.ts criado (exemplo BI)"
else
  cp "$DS_DIR/lib/queries.ts" "$LIB/queries.example.ts"
  echo "      ✓ queries.ts EXISTE — exemplo salvo em queries.example.ts"
fi
[ -f "$DS_DIR/assets/lyx-logo.svg" ] && cp "$DS_DIR/assets/lyx-logo.svg" "$TARGET/public/"
[ -f "$DS_DIR/assets/lyx-logo.png" ] && cp "$DS_DIR/assets/lyx-logo.png" "$TARGET/public/"

# ── 5. App layout + páginas BI ──
echo "[5/5] Copiando root-layout + dashboard BI..."
cp "$DS_DIR/app/root-layout.tsx" "$APP_DIR/layout.tsx"

mkdir -p "$APP_DIR/dashboard" "$APP_DIR/login"
cp "$DS_DIR/app/dashboard/layout.tsx" "$APP_DIR/dashboard/layout.tsx"
# dashboard/page.tsx só cria se vazio (não destrói dashboard existente)
if [ ! -f "$APP_DIR/dashboard/page.tsx" ]; then
  cp "$DS_DIR/app/dashboard/page.tsx" "$APP_DIR/dashboard/page.tsx"
  echo "      ✓ dashboard/page.tsx criado (demo BI)"
else
  cp "$DS_DIR/app/dashboard/page.tsx" "$APP_DIR/dashboard/page.example.tsx"
  echo "      ✓ dashboard/page.tsx EXISTE — exemplo em page.example.tsx"
fi
cp "$DS_DIR/app/login/page.tsx" "$APP_DIR/login/page.tsx"

echo ""
echo "✓ Lyx DS BI v2 aplicado!"
echo ""
echo "Próximos passos:"
echo "  cd $TARGET"
echo "  cp .env.example .env.local 2>/dev/null || cat > .env.local <<EOF"
echo "NEXT_PUBLIC_AUTH_URL=http://localhost:3000"
echo "NEXT_PUBLIC_SUPABASE_URL=https://bi.seu-servidor.com.br"
echo "NEXT_PUBLIC_SUPABASE_ANON_KEY=<sua-anon-key>"
echo "EOF"
echo "  npm run dev"
echo ""
echo "Customizar:"
echo "  - tokens: $APP_DIR/globals.css"
echo "  - nav: $APP_DIR/dashboard/layout.tsx (navOperacional)"
echo "  - queries Supabase: $LIB/queries.ts (substituir views/tabelas)"
echo "  - logo: $TARGET/public/lyx-logo.svg"
