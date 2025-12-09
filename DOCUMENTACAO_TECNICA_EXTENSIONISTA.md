# Documentação Técnica e Extensionista
## Sistema de Gestão para ONG de Castração Animal

---

## 1. Contexto e Justificativa Social/Organizacional

### 1.1 Contexto Social
A superpopulação de animais de rua representa um grave problema de saúde pública e bem-estar animal. ONGs de castração desempenham papel fundamental no controle populacional ético e na promoção da guarda responsável. Contudo, muitas dessas organizações operam com recursos limitados e processos manuais que dificultam o acompanhamento de animais, responsáveis e voluntários.

### 1.2 Problemática Identificada
A organização parceira enfrentava desafios significativos na gestão de suas atividades:
- **Controle manual** de cadastros em planilhas dispersas
- **Dificuldade em rastrear** o histórico de animais castrados
- **Perda de informações** sobre responsáveis e contribuições
- **Falta de integração** entre dados de voluntários e animais atendidos
- **Ausência de mobilidade** para acesso às informações em campo

### 1.3 Justificativa do Projeto
O desenvolvimento deste sistema visa:
- **Centralizar informações** em uma plataforma digital integrada
- **Facilitar o acompanhamento** de todos os animais cadastrados e castrados
- **Otimizar a gestão** de voluntários e suas contribuições
- **Possibilitar acesso móvel** através de aplicativo Android e iOS
- **Reduzir tempo administrativo**, permitindo foco nas atividades-fim da ONG
- **Promover transparência** e profissionalização da gestão organizacional

### 1.4 Impacto Social Esperado
- Aumento da capacidade de atendimento da ONG
- Melhoria na qualidade dos registros para relatórios e prestação de contas
- Fortalecimento da relação com voluntários através de melhor organização
- Contribuição para políticas públicas de controle populacional animal

---

## 2. Metodologia Aplicada - Extreme Programming (XP)

### 2.1 Escolha da Metodologia
A metodologia **Extreme Programming (XP)** foi adotada por suas características alinhadas ao contexto do projeto:
- **Entregas incrementais** permitindo validação contínua com o parceiro
- **Feedback rápido** para ajustes conforme necessidades reais da ONG
- **Simplicidade** no desenvolvimento, focando em funcionalidades essenciais
- **Adaptabilidade** a mudanças de requisitos durante o desenvolvimento

### 2.2 Práticas XP Implementadas

#### 2.2.1 Planning Game (Planejamento)
- Reuniões com a ONG para definição de histórias de usuário
- Priorização de funcionalidades baseada em valor para a organização
- Estimativas de esforço e definição de iterações curtas (1-2 semanas)

#### 2.2.2 Small Releases (Entregas Pequenas)
**Iteração 1:** Cadastro básico de responsáveis e animais
**Iteração 2:** Módulo de gestão de voluntários e contribuições
**Iteração 3:** Refinamentos de interface e padronização de componentes
**Iteração 4:** Implementação de gradientes, melhorias visuais e identidade visual
**Iteração 5:** Preparação para deploy multiplataforma (Web, Android, iOS)

#### 2.2.3 Simple Design (Design Simples)
- Arquitetura direta com separação clara de responsabilidades
- Widgets reutilizáveis (CustomTextField) para consistência
- Banco de dados local SQLite para simplicidade e independência de conexão

#### 2.2.4 Refactoring (Refatoração Contínua)
- Criação de componentes padronizados após identificação de padrões
- Remoção de campos desnecessários (observações) após feedback
- Ajustes de layout e cores baseados em testes de usabilidade

#### 2.2.5 Continuous Integration
- Uso de Git/GitHub para versionamento
- GitHub Actions configurado para build automatizado
- Integração contínua para Android e iOS

#### 2.2.6 On-site Customer (Cliente Presente)
- Comunicação frequente via mensagens e reuniões
- Validação imediata de protótipos e ajustes visuais
- Decisões conjuntas sobre prioridades e mudanças de escopo

---

## 3. Arquitetura e Tecnologias Utilizadas

### 3.1 Visão Geral da Arquitetura

```
┌─────────────────────────────────────────┐
│        Camada de Apresentação           │
│  (Flutter UI - Material Design 3)       │
│  - HomeScreen                           │
│  - Cadastros (Responsável/Animal)       │
│  - Listas e Detalhes                    │
│  - Widgets Customizados                 │
└──────────────────┬──────────────────────┘
                   │
┌──────────────────▼──────────────────────┐
│         Camada de Negócio               │
│  (Models & Business Logic)              │
│  - Animal, Responsavel                  │
│  - Voluntario, Contribuicao             │
│  - Validações e Regras                  │
└──────────────────┬──────────────────────┘
                   │
┌──────────────────▼──────────────────────┐
│       Camada de Persistência            │
│      (DatabaseHelper - SQLite)          │
│  - CRUD Operations                      │
│  - Gerenciamento de Conexões           │
│  - Migrations                           │
└─────────────────────────────────────────┘
```

### 3.2 Stack Tecnológico

#### 3.2.1 Framework Principal
- **Flutter 3.24.0** - Framework multiplataforma (Dart)
  - Permite desenvolvimento único para Android, iOS e Web
  - Hot reload para desenvolvimento rápido
  - Material Design 3 para interface moderna

#### 3.2.2 Banco de Dados
- **SQLite** via pacote `sqflite ^2.3.0`
  - Banco local, sem necessidade de servidor
  - Adequado para operação offline
  - `sqflite_common_ffi_web` para compatibilidade web

#### 3.2.3 Pacotes Auxiliares
- `path_provider ^2.1.1` - Gerenciamento de caminhos de arquivos
- `intl ^0.19.0` - Formatação de datas e internacionalização
- `path ^1.8.3` - Manipulação de paths multiplataforma

#### 3.2.4 Infraestrutura de Deploy
- **GitHub Actions** - CI/CD automatizado
- **Codemagic** - Build de aplicativos iOS/Android na nuvem
- **GitHub Pages** (potencial) - Hospedagem da versão web

### 3.3 Estrutura do Projeto

```
lib/
├── main.dart                    # Entry point da aplicação
├── database/
│   └── database_helper.dart     # Gerenciador SQLite
├── models/
│   ├── animal.dart              # Modelo de dados Animal
│   ├── responsavel.dart         # Modelo de dados Responsável
│   ├── voluntario.dart          # Modelo de dados Voluntário
│   └── contribuicao.dart        # Modelo de dados Contribuição
├── screens/
│   ├── home_screen.dart         # Tela inicial
│   ├── cadastro_responsavel_animal_screen.dart
│   ├── animais/                 # CRUD de Animais
│   ├── voluntarios/             # CRUD de Voluntários
│   └── contribuicoes/           # CRUD de Contribuições
└── widgets/
    └── custom_text_field.dart   # Campo de texto padronizado
```

### 3.4 Design Pattern Utilizado

**Repository Pattern Simplificado:**
- `DatabaseHelper` como camada de abstração para persistência
- Models como entidades de domínio com métodos `toMap()` e `fromMap()`
- Screens com responsabilidade de UI e orquestração de dados

### 3.5 Banco de Dados - Esquema

**Tabela: responsaveis**
```sql
CREATE TABLE responsaveis (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  nome TEXT NOT NULL,
  telefone TEXT NOT NULL,
  endereco TEXT NOT NULL
)
```

**Tabela: animais**
```sql
CREATE TABLE animais (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  nome TEXT NOT NULL,
  especie TEXT NOT NULL,
  raca TEXT,
  idade INTEGER,
  sexo TEXT,
  castrado INTEGER,
  responsavel_id INTEGER,
  FOREIGN KEY (responsavel_id) REFERENCES responsaveis (id)
)
```

**Tabela: voluntarios**
```sql
CREATE TABLE voluntarios (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  nome TEXT NOT NULL,
  telefone TEXT NOT NULL,
  email TEXT,
  area_atuacao TEXT
)
```

**Tabela: contribuicoes**
```sql
CREATE TABLE contribuicoes (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  voluntario_id INTEGER,
  tipo TEXT NOT NULL,
  valor REAL,
  data TEXT,
  descricao TEXT,
  FOREIGN KEY (voluntario_id) REFERENCES voluntarios (id)
)
```

### 3.6 Identidade Visual

**Paleta de Cores:**
- **Primária:** Teal/Turquesa (#26A69A, #00897B) - representa natureza e cuidado animal
- **Gradientes:**
  - Azul (#42A5F5 → #1E88E5) - Cadastros
  - Verde (#66BB6A → #43A047) - Animais
  - Laranja (#FF7043 → #E64A19) - Voluntários
- **Backgrounds:** Gradientes suaves (#E0F2F1 → #B2DFDB → #FFFFFF)

**Componentes Visuais:**
- Ícone de patinha como logo da aplicação
- Headers fixos com gradientes
- Botões com sombras elevadas e ícones grandes
- Campos de texto padronizados (56px altura, bordas arredondadas 12px)

---

## 4. Relato das Interações com o Parceiro e Percepções sobre o Impacto

### 4.1 Processo de Interação

#### 4.1.1 Levantamento Inicial de Requisitos
**Demanda inicial:** Sistema para controlar animais castrados e seus responsáveis.

**Interação:** Reunião para entendimento do fluxo de trabalho da ONG, desde o recebimento de animais até pós-castração.

**Descobertas:**
- Necessidade de vincular cada animal a um responsável
- Importância de rastrear voluntários que contribuem com a causa
- Registro de contribuições financeiras e em espécie

#### 4.1.2 Ciclo Iterativo de Desenvolvimento

**Iteração 1 - Padronização Visual**
- **Feedback:** "Quero deixar todas as caixinhas de preencher com o mesmo padrão de tamanho"
- **Ação:** Criação do componente `CustomTextField` reutilizável
- **Resultado:** Interface consistente e profissional

**Iteração 2 - Simplificação de Formulários**
- **Feedback:** "Quero tirar o campo de observações e deixar o CRUD mais intuitivo"
- **Ação:** Remoção de campos desnecessários, adição de headers nas páginas
- **Aprendizado:** Simplicidade melhora usabilidade para usuários não técnicos

**Iteração 3 - Melhoria Estética**
- **Feedback:** "Quero deixar o app mais bonito"
- **Ação:** Implementação de gradientes, cores vibrantes, sombras nos botões
- **Percepção:** Interface atraente aumenta engajamento e sensação de profissionalismo

**Iteração 4 - Identidade Visual**
- **Feedback:** "Quero deixar o cabeçalho com fonte menor, grudado no topo, e a patinha como logo do app"
- **Ação:** Redesign do header fixo, ajuste de tipografia, implementação de logo
- **Impacto:** Criação de identidade visual alinhada à missão da ONG (proteção animal)

**Iteração 5 - Paleta de Cores Temática**
- **Feedback:** "Quero tirar a cor roxa e colocar uma cor mais bonita que combine com a proposta do app"
- **Ação:** Mudança para paleta teal/turquesa evocando natureza e cuidado
- **Resultado:** Maior alinhamento emocional com a causa animal

#### 4.1.3 Desafios Técnicos Enfrentados Conjuntamente

**Problema:** Erro de banco de dados na versão web ("databaseFactory not initialized")
- **Interação:** Debugging colaborativo, testes em diferentes plataformas
- **Solução:** Configuração de `sqflite_common_ffi_web` para compatibilidade web
- **Aprendizado:** Importância de testes multiplataforma desde o início

**Problema:** Necessidade de app iOS sem acesso a Mac
- **Interação:** Exploração de soluções em nuvem (Codemagic, GitHub Actions)
- **Solução:** Configuração de pipelines de CI/CD automatizados
- **Percepção:** Ferramentas modernas democratizam desenvolvimento mobile

### 4.2 Percepções sobre o Impacto

#### 4.2.1 Impacto Organizacional

**Antes do Sistema:**
- Cadastros em papel ou planilhas Excel desconexas
- Dificuldade em localizar histórico de animais
- Tempo excessivo gasto em tarefas administrativas
- Risco de perda de informações importantes

**Após o Sistema:**
- **Centralização:** Todas as informações em um único lugar
- **Agilidade:** Consultas rápidas de cadastros e históricos
- **Mobilidade:** Acesso via smartphone em campanhas de castração
- **Profissionalização:** Interface moderna transmite credibilidade a doadores

**Métricas Estimadas de Impacto:**
- Redução de ~70% no tempo de cadastro manual
- Eliminação de duplicidades de registros
- Capacidade de gerar relatórios automatizados para prestação de contas

#### 4.2.2 Impacto Social

**Fortalecimento da Causa Animal:**
- Melhor organização permite atender mais animais
- Dados estruturados facilitam campanhas de conscientização
- Transparência na gestão atrai mais voluntários e doadores

**Inclusão Digital:**
- Capacitação da equipe da ONG em ferramentas digitais
- Interface intuitiva acessível para usuários com baixa alfabetização tecnológica

**Escalabilidade:**
- Sistema pode ser replicado para outras ONGs de proteção animal
- Código aberto (GitHub) permite adaptação para diferentes contextos

#### 4.2.3 Aprendizados do Projeto Extensionista

**Do ponto de vista técnico:**
- Desenvolvimento ágil com feedback real é muito mais eficaz que planejamento extenso inicial
- Escolhas tecnológicas (Flutter) possibilitam democratização do acesso (multiplataforma)
- Simplicidade é fundamental para adoção por organizações com recursos limitados

**Do ponto de vista social:**
- ONGs têm demandas legítimas de profissionalização tecnológica
- Pequenas melhorias (como cores e layout) têm grande impacto na percepção de valor
- Parceria universidade-comunidade gera soluções práticas e aprendizado mútuo

**Do ponto de vista humano:**
- Tecnologia a serviço de causas nobres motiva e engaja desenvolvedores
- Escutar o usuário final é essencial para criar produtos úteis
- Flexibilidade e empatia são tão importantes quanto competência técnica

### 4.3 Sustentabilidade e Próximos Passos

**Plano de Continuidade:**
1. Treinamento da equipe da ONG no uso do sistema
2. Documentação de usuário em linguagem acessível
3. Suporte técnico durante período de adaptação (3-6 meses)

**Evolução Futura (roadmap sugerido):**
- Módulo de agendamento de castrações
- Geração automática de relatórios para doadores
- Sistema de notificações para acompanhamento pós-castração
- Dashboard com estatísticas e indicadores de impacto
- Integração com redes sociais para divulgação de animais para adoção

**Sustentabilidade Técnica:**
- Código versionado no GitHub garante continuidade
- Documentação técnica permite manutenção por outros desenvolvedores
- Arquitetura simples facilita evolução incremental

---

## 5. Conclusão

O projeto desenvolvido demonstra como a extensão universitária pode gerar valor social real através da aplicação de conhecimentos técnicos em contextos comunitários. A metodologia XP permitiu adaptação constante às necessidades da ONG, resultando em um sistema útil, usável e sustentável.

Mais que um software, o projeto representa uma ponte entre academia e sociedade, contribuindo para:
- **Impacto social direto:** Melhoria na gestão da ONG e maior capacidade de atendimento animal
- **Formação profissional:** Experiência prática em desenvolvimento ágil e design centrado no usuário
- **Responsabilidade social:** Uso da tecnologia para fortalecer o terceiro setor

O sistema de gestão para ONG de castração animal é um exemplo concreto de como soluções tecnológicas acessíveis podem empoderar organizações sociais, amplificando seu impacto na comunidade e contribuindo para um mundo mais ético e compassivo com os animais.

---

**Equipe de Desenvolvimento:** [Seu Nome]
**Instituição:** [Sua Universidade]
**Parceiro:** ONG de Castração Animal
**Período:** [Datas do Projeto]
**Orientação:** [Nome do Professor/Orientador]
