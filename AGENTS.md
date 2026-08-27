# Guia para Agents de IA no Projeto TrinityCore (4.3.4)

## Introdução

Este documento serve como um guia definitivo para agentes de IA (como GitHub Copilot, ChatGPT, Claude, etc.) que irão auxiliar no desenvolvimento e correção de código para o fork do TrinityCore para a versão **4.3.4.15595**, mantido por [Ramys](https://github.com/Ramys/TrinityCore).

O objetivo principal é garantir que todas as correções em **banco de dados (DB)**, **SQL**, **scripts em C++**, **SmartAI** e outros componentes sejam feitas de forma **precisa, alinhada com o projeto e sem "invenções" ou soluções criativas que fujam dos padrões estabelecidos.**

---

## 1. Fonte da Verdade: `CRULES.md`

O arquivo **[`CRULES.md`](https://github.com/Ramys/TrinityCore/blob/master/CRULES.md)** é o documento mais importante para um agente de IA. Ele contém as regras de codificação específicas para este projeto.

**Ações Obrigatórias:**
- **Leia e internalize** todo o conteúdo do `CRULES.md` antes de qualquer ação.
- Use suas diretrizes como a **base para todas as decisões de código**, desde a nomenclatura de variáveis até a estrutura de correções SQL.

---

## 2. Fluxo de Trabalho para Correções

Todo agente deve seguir este fluxo de trabalho rigoroso para evitar erros e inconsistências:

### 2.1. Antes de Qualquer Correção
1.  **Verifique a Base de Dados Oficial:**
    - A base de dados para este fork é fornecida pelo **The-Cataclysm-Preservation-Project**.
    - Link oficial: `https://github.com/The-Cataclysm-Preservation-Project/TrinityCore/releases`
    - **Sempre** consulte esta base primeiro para verificar se o problema já foi resolvido ou se os dados corretos já existem.

2.  **Consulte as Issues do GitHub:**
    - Verifique se o problema que você está prestes a corrigir já foi reportado.
    - Evite duplicar esforços. Se a issue existir, leia os comentários para entender o contexto.
    - Se for criar uma nova issue, siga o template fornecido no repositório (`issue_template.md`).

### 2.2. Durante a Correção
1.  **Para Correções SQL:**
    - Localize o arquivo correto dentro da estrutura `sql/`.
    - Siga os padrões de nomenclatura e estrutura vistos em outros arquivos do projeto.
    - **Nunca crie novas tabelas ou colunas** sem uma justificativa clara e alinhada com uma issue ou com a documentação do jogo (patch 4.3.4).
    - Teste suas queries em um ambiente de desenvolvimento antes de propor.

2.  **Para Correções em Scripts C++:**
    - Siga os padrões de código definidos no `.clang-format`.
    - Observe a estrutura e lógica nos diretórios `src/` para entender como as funcionalidades são implementadas.
    - **Não mude APIs ou funções principais** sem discutir em uma issue primeiro. Prefira estender ou corrigir comportamentos existentes.
    - Garanta que a correção não quebre a compilação. O projeto usa **CI (GitHub Actions)** ; uma correção válida não deve gerar erros de build.

3.  **Para Correções em SmartAI:**
    - Baseie a lógica do evento em comportamentos conhecidos do jogo ou em dados existentes.
    - Não invente sequências de eventos. Use o sistema SmartAI de acordo com a documentação oficial da TrinityCore.
    - Verifique se já existe um script similar para outro NPC ou quest que possa servir de exemplo.

### 2.3. Após a Correção (Submissão)
1.  **Commit com Mensagem Clara:**
    - Siga o padrão de mensagens de commit visto no repositório (ex: "Core/Misc: buildfix", "Core/Creature: Add support for multiple gossip menu IDs").
    - Seja descritivo e objetivo.

2.  **Abra um Pull Request (PR):**
    - Siga o template para PRs (`pull_request_template.md`).
    - Descreva detalhadamente o problema e a solução.
    - Mencione a issue relacionada, se houver.
    - Esteja preparado para receber feedback e fazer ajustes.

---

## 3. O Que os Agents NÃO Devem Fazer (Regras de Ouro)

Para evitar "invenções" e manter a integridade do projeto, os agentes devem **evitar rigidamente**:

- **Criar soluções do zero** quando uma base de dados ou script similar já existe.
- **Alterar estruturas de dados (DB/MySQL)** sem base em uma issue ou na documentação do jogo.
- **Implementar lógicas de jogo** baseadas em suposições. Toda ação deve ser fundamentada em fatos ou dados concretos.
- **Ignorar os padrões de código** estabelecidos (C++, SQL, formatação).
- **Propor correções que não passem no sistema de CI** (build e testes).
- **Submeter PRs sem antes verificar issues duplicadas** ou sem seguir o template.

---

## 4. Dicas para Configurar e Usar os Agents

1.  **Forneça Contexto Claro:**
    - Ao solicitar uma correção, instrua o agente: *"Baseie-se estritamente nas regras do `CRULES.md` e nos padrões de código do repositório `Ramys/TrinityCore` para a versão 4.3.4."*

2.  **Peça Verificação Prévia:**
    - Solicite que o agente verifique a base de dados oficial e as issues abertas antes de propor qualquer solução.

3.  **Valide o Código Gerado:**
    - Revise todo o código proposto pelo agente. Use a ferramenta de CI para testar.
    - Questione o agente sobre suas decisões: *"Por que você escolheu essa estrutura?"*, *"Já existe algo similar no código?"*

4.  **Use os Arquivos de Referência:**
    - Instrua o agente a ler e usar como referência os arquivos `.clang-format`, `CMakeLists.txt` e a estrutura de pastas do projeto.

---

## 5. Links Úteis para Referência Rápida

| Recurso | Descrição |
| :--- | :--- |
| [CRULES.md](https://github.com/Ramys/TrinityCore/blob/master/CRULES.md) | **Regras de codificação para IA (OBRIGATÓRIO)** |
| [The-Cataclysm-Preservation-Project/TrinityCore/releases](https://github.com/The-Cataclysm-Preservation-Project/TrinityCore/releases) | Base de dados oficial para o projeto |
| [Issue Tracker](https://github.com/Ramys/TrinityCore/issues) | Reportar e verificar problemas |
| [Pull Requests](https://github.com/Ramys/TrinityCore/pulls) | Submeter e revisar correções |
| [Wiki do TrinityCore](https://www.trinitycore.org/) | Documentação geral do projeto |
| [MEMORY_ROOT_CATACLYSM_434.md](MEMORY_ROOT_CATACLYSM_434.md) | Memória de port MoP 5.4.8 -> Cata 4.3.4 (APIs/gotchas: `.Register` sem `PrepareSpellScript`; `AddSC_*` em escopo global, não dentro de `namespace`; `SELECT_TARGET_NEAREST` -> `MINDISTANCE`; `DoEffectCalcDamageAndHealing`) |

---

## 6. Conclusão

Este guia foi criado para garantir que os agentes de IA atuem como ferramentas **precisas, confiáveis e alinhadas** com os objetivos do projeto TrinityCore. Seguir estas diretrizes é essencial para manter a qualidade, estabilidade e consistência do código.

**Lembre-se:** A criatividade é bem-vinda em novos projetos, mas aqui, a precisão e a aderência aos padrões são as maiores virtudes.
