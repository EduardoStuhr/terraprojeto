# 🏗️ TRANSJAP - Sistema de Diário Digital de Obras (DDO)

<div align="center">

![Status](https://img.shields.io/badge/status-em%20desenvolvimento-yellow)
![Versão](https://img.shields.io/badge/versão-1.0.0-blue)
![Licença](https://img.shields.io/badge/licença-proprietária-red)

**Sistema profissional de gestão e controle diário de obras de terraplanagem**

[Documentação](#documentação) • [Instalação](#instalação-rápida) • [Recursos](#recursos) • [Tecnologias](#tecnologias)

</div>

---

## 📋 Sobre o Projeto

O **TRANSJAP DDO** é um sistema web completo para gestão e controle diário de obras de terraplanagem, desenvolvido especificamente para a empresa TRANSJAP. O sistema oferece:

- ✅ Registro diário completo de atividades (DDO)
- ✅ Fluxo de aprovação hierárquico (Encarregado → Supervisor → Engenheiro → Proprietário)
- ✅ Controle de máquinas e equipes
- ✅ Rastreabilidade total com auditoria
- ✅ Dashboards gerenciais e relatórios
- ✅ Geração automática de PDFs
- ✅ Upload de fotos e documentos
- ✅ Sistema de permissões granulares (RBAC)
- ✅ Interface responsiva (mobile-first)

---

## 🎯 Objetivos do Sistema

1. **Controle Operacional**: Registrar todas as atividades diárias da obra
2. **Rastreabilidade**: Histórico completo e imutável após aprovação
3. **Redução de Erros**: Validações automáticas e fluxo estruturado
4. **Hierarquia Clara**: Separação de responsabilidades entre perfis
5. **Tomada de Decisão**: Dados confiáveis para análises técnicas e financeiras

---

## 👥 Perfis de Usuário

### 🔴 Proprietário / Diretor
- Acesso total ao sistema
- Aprova ou reprova DDOs (decisão final)
- Visualiza todas as obras e dados
- Gerencia usuários e permissões
- Acessa relatórios financeiros

### 🔵 Engenheiro Responsável
- Acesso às obras sob sua responsabilidade
- Valida tecnicamente o DDO (pré-aprovação)
- Insere observações técnicas
- Analisa produtividade e desvios
- Sem acesso financeiro completo

### 🟢 Supervisor de Obras
- Acompanha múltiplas frentes de trabalho
- Revisa DDOs antes do envio ao engenheiro
- Pode devolver DDO para correção
- Não pode aprovar DDO final

### 🟡 Administrador
- Cadastra dados administrativos
- Cadastra funcionários e máquinas
- Visualiza DDOs
- Sem poder de aprovação

### 🟣 Encarregado / Apontador
- Cria o DDO diário
- Registra atividades, máquinas e funcionários
- Insere fotos e ocorrências
- Não edita após envio

### ⚪ Visualizador / Cliente
- Acesso somente leitura
- Visualiza relatórios aprovados
- Acompanha progresso da obra

---

## 🔄 Fluxo de Aprovação de DDO

```
┌─────────────────────┐
│   1. RASCUNHO       │  ◄── Encarregado cria
│   (Editável)        │
└──────────┬──────────┘
           │ Enviar
           ▼
┌─────────────────────┐
│ 2. EM REVISÃO       │  ◄── Supervisor revisa
│    (Supervisor)     │
└──────────┬──────────┘
           │ Aprovar / Reprovar
           ▼
┌─────────────────────┐
│ 3. EM VALIDAÇÃO     │  ◄── Engenheiro valida
│    (Engenheiro)     │
└──────────┬──────────┘
           │ Aprovar / Reprovar
           ▼
┌─────────────────────┐
│ 4. APROVAÇÃO FINAL  │  ◄── Proprietário aprova
│    (Proprietário)   │
└──────────┬──────────┘
           │ Aprovar
           ▼
┌─────────────────────┐
│ 5. APROVADO         │  ✅ BLOQUEADO
│    (Imutável)       │  ✅ Gera PDF
│                     │  ✅ Histórico
└─────────────────────┘

📌 Reprovação em qualquer etapa retorna para RASCUNHO
```

---

## 🚀 Recursos Principais

### 📝 Diário Digital de Obra (DDO)

Cada DDO registra:

- **Informações Gerais**: Data, turno, clima, situação do dia
- **Atividades Executadas**: Descrição, volume movimentado (m³/ton), frente de serviço
- **Máquinas Utilizadas**: Equipamento, horas trabalhadas, atividade
- **Funcionários**: Presença, horas trabalhadas, observações
- **Ocorrências**: Quebras, atrasos, paradas, acidentes
- **Fotos**: Registro visual das atividades
- **Observações**: Por perfil (encarregado, supervisor, engenheiro, proprietário)

### 📊 Dashboards e Relatórios

- Produtividade diária por obra
- Comparativo entre obras
- Eficiência de máquinas
- Horas trabalhadas (máquinas e funcionários)
- Volumes produzidos
- Ocorrências e paradas
- Indicadores por responsável

### 🔒 Segurança e Auditoria

- Autenticação JWT com refresh tokens
- Criptografia de senhas (bcrypt)
- Rate limiting
- Logs completos de auditoria
- DDO bloqueado após aprovação final (imutável)
- Controle de acesso baseado em perfis (RBAC)

---

## 🛠️ Tecnologias

### Backend

| Tecnologia | Versão | Uso |
|------------|--------|-----|
| **Node.js** | 20+ | Runtime JavaScript |
| **TypeScript** | 5+ | Linguagem tipada |
| **Express.js** | 4+ | Framework web |
| **Prisma** | 5+ | ORM |
| **PostgreSQL** | 15+ | Banco de dados |
| **Redis** | 7+ | Cache |
| **JWT** | - | Autenticação |
| **Zod** | - | Validação |
| **Winston** | - | Logs |

### Frontend

| Tecnologia | Versão | Uso |
|------------|--------|-----|
| **React** | 18+ | UI Library |
| **TypeScript** | 5+ | Linguagem tipada |
| **Vite** | 5+ | Build tool |
| **Tailwind CSS** | 3+ | Estilização |
| **shadcn/ui** | - | Componentes |
| **React Query** | 5+ | Gerenciamento de estado |
| **React Hook Form** | 7+ | Formulários |
| **Recharts** | 2+ | Gráficos |

### DevOps

- **Docker** & **Docker Compose**: Containerização
- **NGINX**: Reverse proxy
- **PM2**: Gerenciador de processos
- **GitHub Actions**: CI/CD

---

## 📦 Instalação Rápida

### Pré-requisitos

- Node.js 20+
- Docker & Docker Compose
- Git

### Passos

```bash
# 1. Clonar repositório
git clone https://github.com/transjap/ddo-system.git
cd ddo-system

# 2. Configurar variáveis de ambiente
cp backend/.env.example backend/.env
cp frontend/.env.example frontend/.env

# 3. Iniciar containers
docker-compose up -d

# 4. Executar migrations
cd backend
npx prisma migrate dev

# 5. Seed (dados iniciais)
npm run seed

# 6. Acessar aplicação
# Frontend: http://localhost:5173
# Backend: http://localhost:3000
# Login: admin@transjap.com.br / Admin@123
```

Para instruções detalhadas, veja: [INSTALL_GUIDE.md](./INSTALL_GUIDE.md)

---

## 📚 Documentação

- [📖 Arquitetura do Sistema](./TRANSJAP_DDO_Architecture.md)
- [⚙️ Guia de Instalação](./INSTALL_GUIDE.md)
- [🔌 Documentação da API](http://localhost:3000/api-docs) (após iniciar)
- [🗄️ Schema do Banco de Dados](./schema.prisma)

---

## 📁 Estrutura do Projeto

```
transjap-ddo/
├── backend/                    # API Node.js + TypeScript
│   ├── src/
│   │   ├── application/        # Casos de uso e serviços
│   │   ├── domain/             # Entidades e regras de negócio
│   │   ├── infrastructure/     # Banco, cache, storage
│   │   ├── presentation/       # Controllers, rotas, middlewares
│   │   └── shared/             # Utilitários compartilhados
│   ├── prisma/                 # Schema e migrations
│   └── tests/                  # Testes
│
├── frontend/                   # React + TypeScript
│   ├── src/
│   │   ├── components/         # Componentes reutilizáveis
│   │   ├── pages/              # Páginas da aplicação
│   │   ├── services/           # Chamadas à API
│   │   ├── hooks/              # Custom hooks
│   │   ├── store/              # Estado global
│   │   └── utils/              # Utilitários
│
├── docs/                       # Documentação adicional
├── docker-compose.yml          # Orquestração de containers
└── README.md                   # Este arquivo
```

---

## 🧪 Testes

```bash
# Backend
cd backend
npm run test              # Testes unitários
npm run test:integration  # Testes de integração
npm run test:e2e          # Testes end-to-end
npm run test:coverage     # Cobertura de testes

# Frontend
cd frontend
npm run test              # Testes unitários
npm run test:e2e          # Testes E2E (Playwright)
```

---

## 🔐 Segurança

- ✅ Senhas hasheadas com bcrypt (12 rounds)
- ✅ JWT com expiração curta + refresh tokens
- ✅ Rate limiting (100 req/15min)
- ✅ Sanitização de inputs
- ✅ Proteção contra SQL injection (queries parametrizadas)
- ✅ Headers de segurança (Helmet.js)
- ✅ CORS configurado
- ✅ HTTPS obrigatório em produção
- ✅ Auditoria completa de ações

---

## 📈 Roadmap

### Fase 1 (MVP) - ✅ Completa
- [x] Autenticação e autorização
- [x] CRUD de obras, máquinas e funcionários
- [x] Sistema de DDO completo
- [x] Fluxo de aprovação
- [x] Interface web responsiva

### Fase 2 - 🚧 Em andamento
- [ ] Dashboards avançados
- [ ] Relatórios em PDF/Excel
- [ ] Upload de fotos
- [ ] Notificações por e-mail

### Fase 3 - 📋 Planejada
- [ ] Aplicativo mobile (React Native)
- [ ] Integração com ERP
- [ ] BI e análise preditiva
- [ ] Assinatura digital

---

## 🤝 Suporte

Para dúvidas, sugestões ou problemas:

- 📧 Email: suporte@transjap.com.br
- 📱 WhatsApp: (XX) XXXXX-XXXX
- 🌐 Site: www.transjap.com.br

---

## 📄 Licença

Copyright © 2026 TRANSJAP Terraplanagem  
Todos os direitos reservados.

Este software é proprietário e confidencial. Uso não autorizado é estritamente proibido.

---

<div align="center">

**Desenvolvido com ❤️ para TRANSJAP**

![TRANSJAP Logo](./docs/logo.png)

</div>
