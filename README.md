# Lyx Design System BI v2

Bundle de instalação única para front BI. Variante do `lyx-design-system-v2` com Supabase + sidebar/cards padrão `lyx-bi-principal` + auth standalone (Approach A).

## Quando usar

- **Sistema BI já em produção** que precisa atualizar visual + lib (queries, auth, charts, sidebar)
- **Sistema BI novo** ainda sem layout (alternativa ao template Git `lyx-front-bi-template`)

**NÃO usar em `lyx-bi-principal`** — ele é o hub central de referência, tem sidebar/permissões próprias que serviram de base pro bundle.

## Padrão visual

- **Sidebar + app-shell + header**: clonados do `lyx-bi-principal`. Nav dinâmica por categoria + filtro por permissão.
- **Cards / charts / lista**: shadcn semantic tokens (`bg-card`, `text-foreground`, `bg-primary/10`). Sem gradientes hard-coded.
- **Auth**: Approach A standalone — stub em `lib/auth/` que dev substitui pelo Better Auth real do projeto. Compatível com a API do `lyx-bi-principal` (`requireUser`, `BI_ROLE_PERMISSIONS`) — quando virar B (hub central), troca só a implementação.

Diferença vs `lyx-design-system-v2`:

| | DS v2 (CRUD) | DS BI v2 |
|---|---|---|
| Padrão visual | 52W (`.lyx-card`, `.stat-card`) | shadcn (`<Card>`, tokens semânticos) |
| Sidebar | 52W estática | `lyx-bi-principal` (categorias + permissões) |
| Auth | Better Auth + setActive | Stub `requireUser` (Approach A) |
| Data layer | fetch monolith | Supabase SDK |
| Dependências | base + tanstack + rhf | base + tanstack + rhf + supabase + ssr + date-fns |

## Uso

```bash
bash ~/Projetos/lyx-design-system-bi-v2/apply-lyx-bi.sh <pasta-projeto-bi>
```

## O que copia / atualiza

**Sobrescreve (sempre):**
- `app/globals.css` (tokens shadcn)
- `app/layout.tsx` (root + Providers)
- `app/dashboard/layout.tsx` (`AuthProvider` → `SidebarProvider` → `AppShell`)
- `app/login/page.tsx` + `app/login/actions.ts`
- `components/ui/*` (15 componentes DS)
- `components/dashboard/*` (sidebar, sidebar-provider, app-shell, dashboard-header, greeting)
- `components/auth/auth-provider.tsx`
- `components/{providers,theme-toggle,lyx-modal}.tsx`
- `hooks/use-sidebar.ts`
- `lib/utils.ts`, `lib/supabase.ts`, `lib/auth-client.ts`
- `lib/auth/` (index, current-user stub, role-permissions)
- `types/dashboard.ts`
- `public/lyx-logo.svg|png`

**Cria só se NÃO existe (preserva customizações):**
- `lib/queries.ts` → se existe, salva exemplo em `lib/queries.example.ts`
- `lib/dashboards.ts` → se existe, salva exemplo em `lib/dashboards.example.ts`
- `app/dashboard/page.tsx` → se existe, salva exemplo em `app/dashboard/page.example.tsx`

**Instala deps:**
```
class-variance-authority clsx tailwind-merge tw-animate-css
lucide-react radix-ui zod
@tanstack/react-query sonner recharts
react-hook-form @hookform/resolvers
better-auth @supabase/supabase-js @supabase/ssr date-fns
```

## Customizar depois da instalação

1. **Nav lateral** → `lib/dashboards.ts` — adiciona/remove `DashboardConfig` (id, name, icon, category, requiredPermission)
2. **Auth real** → `lib/auth/current-user.ts` — troca o mock por chamada ao Better Auth do projeto (ver `lyx-bi-principal/src/lib/auth/current-user.ts` como referência)
3. **Permissões** → `lib/auth/role-permissions.ts` — ajusta papéis e permissões do projeto
4. **Queries Supabase** → `lib/queries.ts` — substitui views/tabelas
5. **Tokens** → `app/globals.css` (`--primary`, `--sidebar`, etc.)
6. **Logo** → `public/lyx-logo.svg`

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
│   ├── login/
│   │   ├── page.tsx
│   │   └── actions.ts
│   └── dashboard/
│       ├── layout.tsx           ← AuthProvider + SidebarProvider + AppShell
│       └── page.tsx             ← demo shadcn cards/charts (mock)
├── components/
│   ├── providers.tsx
│   ├── theme-toggle.tsx
│   ├── lyx-modal.tsx
│   ├── ui/ (15 componentes shadcn)
│   ├── auth/auth-provider.tsx
│   └── dashboard/
│       ├── sidebar.tsx
│       ├── sidebar-provider.tsx
│       ├── app-shell.tsx
│       ├── dashboard-header.tsx
│       └── greeting.tsx
├── hooks/
│   └── use-sidebar.ts
├── lib/
│   ├── utils.ts
│   ├── supabase.ts              ← createSupabaseBrowser/Server
│   ├── auth-client.ts           ← Better Auth + isMembroBI()
│   ├── auth/
│   │   ├── index.ts
│   │   ├── current-user.ts      ← stub: dev conecta Better Auth real
│   │   └── role-permissions.ts
│   ├── dashboards.ts            ← exemplo: 3 entries fictícias
│   └── queries.ts               ← exemplos useKpiVendas/useSerieTemporal/useRanking
├── types/
│   └── dashboard.ts
└── assets/
    └── lyx-logo.svg/.png
```

## Workflow recomendado pra atualizar BI em produção

```bash
# 1. Branch nova
cd ~/Projetos/meu-bi-prod
git checkout -b ds-bi-update
git add -A && git commit -m "pre-DS-update" --allow-empty

# 2. Aplica DS BI
bash ~/Projetos/lyx-design-system-bi-v2/apply-lyx-bi.sh .

# 3. Revisa diff
git diff
# Confere:
# - queries.ts custom preservado (exemplo em queries.example.ts)
# - dashboard/page.tsx custom preservado (exemplo em page.example.tsx)
# - lib/dashboards.ts: ajusta nav lateral do projeto
# - lib/auth/current-user.ts: substitui stub pelo Better Auth real

# 4. Build + test
npm install
npm run build
npm run dev
# Login com user BI + verifica sidebar/permissões

# 5. Merge
git add -A && git commit -m "feat: aplica Lyx DS BI v2"
git push
```

## Evolução pra Approach B (hub centralizado)

Quando quiser que todos BIs compartilhem sessão e nav com `lyx-bi-principal`:

1. Configura Better Auth cross-subdomain (cookie `.lyx.com.br`)
2. Centraliza `dashboards.ts` num pacote npm interno
3. Cada BI consome esse pacote em vez do `lib/dashboards.ts` local
4. `lib/auth/current-user.ts` aponta pra sessão única do hub

Sem reescrever componentes — sidebar/app-shell já são compatíveis.
