# Gestor de Projetos — Specs, Tasks & Próximos Passos

> Documento de produto para o Gestor de Projetos em `/labs/gestor`.
> Parte do ecossistema **Dulval OS** — segundo cérebro pessoal integrado com IA.

---

## Estado Atual (o que já existe)

A página em `/labs/gestor` é uma app client-side completa com 4 tabs:

| Tab | O que faz | Status |
|---|---|---|
| **Projetos** | Lista projetos com prioridade + barra de progresso | ✅ Funcional |
| **Rotina** | Gera grade semanal automática por prioridade (Seg–Sex, 3 blocos/dia) | ✅ Funcional |
| **Hoje** | Lista de tarefas do dia, vinculadas a projetos | ✅ Funcional |
| **Estratégia** | Guia estático: time-boxing, revisão semanal, repriorização | ✅ Funcional |

**Persistência:** localStorage (`dulval-gestor-v1`)  
**Tech:** Astro + vanilla JS inline  
**Dark mode:** suportado via `@media prefers-color-scheme`

---

## Gaps — O que está faltando

### 1. Edição de projeto
Hoje só é possível adicionar e deletar. Não dá para:
- Atualizar o % de progresso após criação
- Mudar a prioridade sem deletar e recriar
- Adicionar o "próximo passo" (mencionado na estratégia mas sem campo)

### 2. Log de sessão
A estratégia descreve: "ao final de cada bloco, escreva o que foi feito e qual é o próximo passo."  
Não existe interface para isso. O log deveria ficar vinculado ao projeto e datado.

### 3. Fila de espera
A estratégia diz: "máximo 4 projetos ativos". Hoje o sistema não avisa nem bloqueia.  
Não há conceito de "fila" — projetos que aguardam um slot ficam invisíveis.

### 4. Timer de sessão
O time-boxing exige blocos de 1h30. Não existe timer na interface.  
Sem timer, o usuário sai da página para controlar o tempo, quebrando o fluxo.

### 5. Backup / portabilidade
localStorage é volátil — apaga com limpeza de cache. Sem export, os dados somem sem aviso.

### 6. Integração com Dulval OS
O Gestor é listado no labs como projeto separado, mas a visão do Dulval OS é ser o "sistema operacional pessoal" que integra tudo. A ligação entre os dois não existe ainda.

---

## Visão — O que o Gestor quer ser

```
Gestor de Projetos
└── Módulo central do Dulval OS
    ├── Controle de projetos (prioridade, progresso, próximo passo)
    ├── Planejamento semanal (rotina automática por peso)
    ├── Log de sessão (journal de trabalho datado)
    ├── Timer de foco (time-boxing 1h30)
    └── [futuro] Integração AI — sugestão de repriorização, resumo de semana
```

**Princípios:**
- Dados do usuário nunca saem sem permissão explícita
- Interface deve funcionar offline (localStorage-first)
- Zero dependências externas (sem frameworks UI, sem serviços)
- Máxima informação com mínima fricção

---

## Tasks — Backlog Priorizado

### 🔴 Alta prioridade — completam o MVP

**T1 — Edição inline de projeto**
- Clicar no nome do projeto entra em modo edição
- Slider ou input numérico para atualizar o %
- Dropdown para trocar prioridade
- Campo "próximo passo" (texto curto, persiste no state)
- Exibe o "próximo passo" em destaque no card

**T2 — Log de sessão**
- Botão "registrar sessão" em cada projeto
- Modal simples: textarea "o que foi feito" + campo "próximo passo"
- Log salvo com timestamp no state do projeto
- Tab "Projetos" exibe a última entrada do log em cada card
- Tab dedicada "Histórico" lista todos os logs em ordem decrescente

**T3 — Limite de projetos ativos + fila**
- Aviso visual quando projetos ativos > 4 (badge de alerta no header)
- Projetos com status `pausada` ficam colapsados em seção "Em espera"
- Botão "retomar" move projeto da fila para ativo (se slots disponíveis)
- Contagem de slots disponíveis visível nas métricas

**T4 — Export / Import de dados**
- Botão "exportar JSON" no rodapé do app
- Botão "importar JSON" (input file)
- Confirma antes de sobrescrever state existente

---

### 🟡 Média prioridade — aumentam o valor

**T5 — Timer de foco (time-boxing)**
- Botão "iniciar bloco" em cada projeto (1h30 default)
- Timer regressivo visível como barra de progresso no topo do app
- Alerta sonoro + visual ao fim do bloco
- Prompt automático para registrar log de sessão ao término
- Configurável: 45min / 1h30 / 2h

**T6 — Tab "Semana" (revisão + planejamento)**
- Substitui ou complementa a tab "Rotina" atual
- Mostra a semana atual com status de cada bloco (feito / pendente)
- Permite marcar blocos como concluídos
- Histórico das últimas 4 semanas

**T7 — Métricas de produtividade**
- Velocidade semanal: número de sessões por projeto
- Tendência de progresso (sparkline simples com os últimos % registrados)
- Projetos sem log há mais de 7 dias ficam marcados com alerta

**T8 — Melhorias de UX/UI**
- Drag-and-drop para reordenar projetos
- Keyboard shortcuts (N = nova tarefa, P = novo projeto, T = timer)
- Animação suave na atualização das métricas
- Estado vazio (onboarding) melhor no primeiro acesso

---

### 🟢 Baixa prioridade — evolução futura

**T9 — Integração Dulval OS**
- API interna compartilhada entre Gestor e outros módulos futuros
- State centralizado (considerar migração para IndexedDB)
- Página `/os` como hub central com widgets de cada módulo

**T10 — Integração AI (Dulval OS)**
- Resumo semanal gerado por LLM: "essa semana você avançou X em Y"
- Sugestão de repriorização baseada em progresso e tempo sem log
- Prompt de "próximo passo" assistido: IA sugere com base no histórico

**T11 — Sync / Backup na nuvem**
- Export automático para Gist privado do GitHub
- Import direto via URL do Gist
- Sem banco de dados — Gist como "storage" simples

---

## Próximos Passos Imediatos

**Sprint 1 — Edição + Log (T1 + T2)**

Essas duas tasks são o coração do produto. Sem edição, o usuário para de usar quando precisa atualizar o progresso. Sem log, o produto não cumpre a promessa do "segundo cérebro".

Sequência de implementação:
1. Adicionar campo `proximoPasso` e array `log[]` no schema do state
2. Migrar `STORAGE_KEY` para `dulval-gestor-v2` (sem quebrar v1)
3. Implementar modo de edição inline no card de projeto
4. Implementar modal de log de sessão com timestamp
5. Exibir último log e próximo passo no card

**Sprint 2 — Fila + Export (T3 + T4)**

Garante que o sistema não se corrompe com muitos projetos e que os dados não somem.

**Sprint 3 — Timer (T5)**

Fecha o loop do time-boxing — o maior diferencial da estratégia proposta.

---

## Schema do State (v2 — proposto)

```ts
interface Project {
  id: number;
  nome: string;
  prio: 'alta' | 'media' | 'baixa' | 'pausada';
  prog: number;              // 0–100
  proximoPasso: string;      // novo
  log: SessionLog[];         // novo
  criadoEm: string;          // novo — ISO date
}

interface SessionLog {
  data: string;              // ISO date
  feito: string;             // o que foi feito nessa sessão
  proximo: string;           // próximo passo registrado
}

interface Task {
  id: number;                // novo — usar id ao invés de índice
  nome: string;
  projId: number | null;
  done: boolean;
  criadoEm: string;          // novo
}

interface GestorState {
  version: 2;
  projects: Project[];
  tasks: Task[];
  nextId: number;
}
```

---

## Conexão com Dulval OS

O Gestor é o módulo mais avançado do Dulval OS hoje. A visão é:

```
dulval.com/os (ou os.dulval.com)
├── /os              → hub central com widgets
├── /os/gestor       → Gestor de Projetos (atual /labs/gestor)
├── /os/conhecimento → Base de conhecimento / notas
├── /os/agenda       → Planejamento de semanas / sprints pessoais
└── /os/ia           → Assistente AI integrado
```

O Gestor deveria ser migrado de `/labs/gestor` para `/os/gestor` quando o Dulval OS tiver identidade própria como produto. Por enquanto, faz sentido continuar em `/labs` como experimento.

---

*Gerado em: 2026-05-22*
