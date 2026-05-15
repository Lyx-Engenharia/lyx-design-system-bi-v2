# Lyx Design System BI v2

Bundle de instalação única para front BI existente. Variante do `lyx-design-system-v2` com Supabase + queries BI + dashboard charts.

## Quando usar

- **Sistema BI já em produção** que precisa atualizar visual + lib (queries, auth check membership, charts)
- **Sistema BI novo** ainda sem layout (alternativa ao template Git)

Diferença vs `lyx-design-system-v2`:

| | DS v2 (CRUD) | DS BI v2 |
|---|---|---|
| Auth | Better Auth + setActive | Better Auth + isMembroBI() |
| Data layer | fetch monolith | Supabase SDK |
| Dependências | base + tanstack + rhf | base + tanstack + rhf + supabase + ssr + date-fns |
| Dashboard demo | KPI + 2 charts | KPI destaque + 4 charts + tabela analítica |
| Páginas templating | CRUD-friendly | Read-only charts |

## Uso

```bash
bash ~/Projetos/lyx-design-system-bi-v2/apply-lyx-bi.sh <pasta-projeto-bi>
```

## O que copia / atualiza

**Sobrescreve (sempre):**
- `app/globals.css` (tokens)
- `app/layout.tsx` (root + Providers)
- `app/dashboard/layout.tsx` (sidebar BI)
- `app/login/page.tsx` (com isMembroBI())
- `components/ui/*` (15 componentes DS)
- `components/{providers,theme-toggle,lyx-modal}.tsx`
- `lib/utils.ts`
- `lib/supabase.ts` (clients browser + server)
- `lib/auth-client.ts` (com `isMembroBI()`)
- `public/lyx-logo.svg|png`

**Cria só se NÃO existe (preserva customizações):**
- `lib/queries.ts` → se existe, salva exemplo em `lib/queries.example.ts`
- `app/dashboard/page.tsx` → se existe, salva exemplo em `app/dashboard/page.example.tsx`

**Instala deps:**
```
class-variance-authority clsx tailwind-merge tw-animate-css
lucide-react radix-ui zod
@tanstack/react-query sonner recharts
react-hook-form @hookform/resolvers
better-auth @supabase/supabase-js @supabase/ssr date-fns
```

## Env esperadas

```
NEXT_PUBLIC_AUTH_URL=http://localhost:3000
NEXT_PUBLIC_SUPABASE_URL=https://bi.seu-servidor.com.br
NEXT_PUBLIC_SUPABASE_ANON_KEY=...
```

## Conteúdo do bundle

```
lyx-design-system-bi-v2/
├── apply-lyx-bi.sh
├── README.md
├── tokens/globals.css
├── app/
│   ├── root-layout.tsx
│   ├── login/page.tsx           ← valida membership 'bi'
│   └── dashboard/
│       ├── layout.tsx           ← sidebar (Vendas/Operação/Relatórios)
│       └── page.tsx             ← demo charts (mock)
├── components/
│   ├── providers.tsx
│   ├── theme-toggle.tsx
│   ├── lyx-modal.tsx
│   └── ui/ (15 componentes)
├── lib/
│   ├── utils.ts
│   ├── supabase.ts              ← createSupabaseBrowser/Server
│   ├── auth-client.ts           ← Better Auth + isMembroBI()
│   └── queries.ts               ← exemplos: useKpiVendas/useSerieTemporal/useRanking
└── assets/
    └── lyx-logo.svg/.png
```

## Workflow recomendado pra atualizar BI em produção

```bash
# 1. Branch nova
cd ~/Projetos/meu-bi-prod
git checkout -b ds-bi-update
git add -A && git commit -m "pre-DS-update"

# 2. Aplica DS BI
bash ~/Projetos/lyx-design-system-bi-v2/apply-lyx-bi.sh .

# 3. Revisa diff
git diff
# - se queries.ts custom foi preservado e exemplo em queries.example.ts
# - se dashboard/page.tsx custom foi preservado e exemplo em page.example.tsx
# - reintegre o que faltar

# 4. Build + test
npm install   # caso script tenha falhado
npm run build
npm run dev
# Login com user BI + verifica todas as páginas

# 5. Merge
git add -A && git commit -m "feat: aplica Lyx DS BI v2"
git push
```
