# SISTEMA TRANSJAP - DIÁRIO DIGITAL DE OBRAS (DDO)
## Arquitetura de Software e Documentação Técnica

---

## 1. VISÃO GERAL DO PROJETO

### 1.1 Objetivo
Sistema web de gestão para controle diário de obras de terraplanagem, com foco em rastreabilidade, hierarquia de aprovações e análise operacional.

### 1.2 Stakeholders
- **TRANSJAP**: Empresa de terraplanagem (cliente)
- **Usuários finais**: Proprietário, Engenheiros, Supervisores, Administradores, Encarregados, Clientes

### 1.3 Principais Funcionalidades
- Registro diário de atividades (DDO)
- Fluxo de aprovação hierárquico
- Controle de máquinas e equipes
- Dashboards e relatórios gerenciais
- Auditoria e rastreabilidade completa

---

## 2. ARQUITETURA DO SISTEMA

### 2.1 Arquitetura Geral (Clean Architecture + DDD)

```
┌─────────────────────────────────────────────────────────────┐
│                     CAMADA DE APRESENTAÇÃO                   │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │   Web App    │  │  Mobile App  │  │   Admin UI   │      │
│  │  (React.js)  │  │ (React Native│  │  (Dashboard) │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└─────────────────────────────────────────────────────────────┘
                            ↓ HTTP/REST
┌─────────────────────────────────────────────────────────────┐
│                    CAMADA DE API (Gateway)                   │
│                    Node.js + Express/Fastify                 │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  Auth Middleware │ RBAC │ Rate Limiting │ Validation│   │
│  └──────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│                  CAMADA DE APLICAÇÃO (Services)              │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │ DDO Service  │  │ Auth Service │  │ Report Svc   │      │
│  │ Obra Service │  │ User Service │  │ Analytics    │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│                    CAMADA DE DOMÍNIO (Core)                  │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │   Entities   │  │  Value Objs  │  │  Domain Svc  │      │
│  │   - DDO      │  │  - CPF/CNPJ  │  │  - Approval  │      │
│  │   - Obra     │  │  - Money     │  │  Flow Logic  │      │
│  │   - Usuario  │  │  - Hours     │  │              │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│               CAMADA DE INFRAESTRUTURA                       │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │  PostgreSQL  │  │    Redis     │  │   AWS S3     │      │
│  │  (Dados)     │  │   (Cache)    │  │  (Arquivos)  │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└─────────────────────────────────────────────────────────────┘
```

### 2.2 Stack Tecnológico

#### Backend
- **Runtime**: Node.js 20+ (LTS)
- **Framework**: Express.js ou Fastify
- **Linguagem**: TypeScript
- **ORM**: Prisma ou TypeORM
- **Validação**: Zod ou Joi
- **Autenticação**: JWT + bcrypt
- **Documentação**: Swagger/OpenAPI

#### Frontend
- **Framework**: React 18+ com TypeScript
- **Estado**: Zustand ou Redux Toolkit
- **Roteamento**: React Router v6
- **UI Library**: Tailwind CSS + shadcn/ui
- **Forms**: React Hook Form + Zod
- **Requisições**: TanStack Query (React Query)
- **Gráficos**: Recharts ou Chart.js

#### Banco de Dados
- **Principal**: PostgreSQL 15+
- **Cache**: Redis
- **Storage**: AWS S3 (fotos/PDFs) ou MinIO (self-hosted)

#### DevOps
- **Containerização**: Docker + Docker Compose
- **CI/CD**: GitHub Actions
- **Monitoramento**: PM2 + Winston (logs)
- **Deploy**: VPS (DigitalOcean/AWS) ou Vercel (frontend)

---

## 3. MODELAGEM DO BANCO DE DADOS

### 3.1 Diagrama Entidade-Relacionamento (Principais Entidades)

```sql
-- Tabela: empresas
CREATE TABLE empresas (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    razao_social VARCHAR(255) NOT NULL,
    nome_fantasia VARCHAR(255),
    cnpj VARCHAR(18) UNIQUE NOT NULL,
    logo_url TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Tabela: usuarios
CREATE TABLE usuarios (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    empresa_id UUID REFERENCES empresas(id),
    nome VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    senha_hash VARCHAR(255) NOT NULL,
    cpf VARCHAR(14) UNIQUE,
    telefone VARCHAR(20),
    perfil VARCHAR(50) NOT NULL CHECK (perfil IN ('PROPRIETARIO', 'ENGENHEIRO', 'SUPERVISOR', 'ADMINISTRADOR', 'ENCARREGADO', 'VISUALIZADOR')),
    ativo BOOLEAN DEFAULT TRUE,
    foto_url TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Tabela: obras
CREATE TABLE obras (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    empresa_id UUID REFERENCES empresas(id),
    codigo VARCHAR(50) UNIQUE NOT NULL,
    nome VARCHAR(255) NOT NULL,
    descricao TEXT,
    localizacao TEXT,
    tipo_servico VARCHAR(100),
    engenheiro_id UUID REFERENCES usuarios(id),
    supervisor_id UUID REFERENCES usuarios(id),
    data_inicio DATE NOT NULL,
    data_previsao_termino DATE,
    data_termino_real DATE,
    status VARCHAR(20) DEFAULT 'ATIVA' CHECK (status IN ('ATIVA', 'PAUSADA', 'FINALIZADA', 'CANCELADA')),
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Tabela: maquinas
CREATE TABLE maquinas (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    empresa_id UUID REFERENCES empresas(id),
    codigo VARCHAR(50) UNIQUE NOT NULL,
    tipo VARCHAR(100) NOT NULL,
    modelo VARCHAR(100),
    placa VARCHAR(20),
    ano INTEGER,
    status VARCHAR(20) DEFAULT 'DISPONIVEL' CHECK (status IN ('DISPONIVEL', 'EM_USO', 'MANUTENCAO', 'INATIVA')),
    valor_hora_operacao DECIMAL(10,2),
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Tabela: funcionarios
CREATE TABLE funcionarios (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    empresa_id UUID REFERENCES empresas(id),
    nome VARCHAR(255) NOT NULL,
    cpf VARCHAR(14) UNIQUE NOT NULL,
    funcao VARCHAR(100) NOT NULL,
    telefone VARCHAR(20),
    data_admissao DATE,
    valor_hora DECIMAL(10,2),
    ativo BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Tabela: ddos (Diário Digital de Obras)
CREATE TABLE ddos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    obra_id UUID REFERENCES obras(id) NOT NULL,
    data DATE NOT NULL,
    turno VARCHAR(20) CHECK (turno IN ('DIURNO', 'NOTURNO', 'INTEGRAL')),
    condicao_climatica VARCHAR(50),
    situacao_dia TEXT,
    
    -- Controle de fluxo
    status VARCHAR(30) DEFAULT 'RASCUNHO' CHECK (status IN ('RASCUNHO', 'ENVIADO_SUPERVISOR', 'APROVADO_SUPERVISOR', 'APROVADO_ENGENHEIRO', 'APROVADO_FINAL', 'REPROVADO')),
    
    -- Criação e responsáveis
    criado_por_id UUID REFERENCES usuarios(id),
    revisado_supervisor_id UUID REFERENCES usuarios(id),
    validado_engenheiro_id UUID REFERENCES usuarios(id),
    aprovado_proprietario_id UUID REFERENCES usuarios(id),
    
    -- Observações por perfil
    observacao_encarregado TEXT,
    observacao_supervisor TEXT,
    observacao_engenheiro TEXT,
    observacao_proprietario TEXT,
    
    -- Motivo de reprovação
    motivo_reprovacao TEXT,
    
    -- Controle de timestamps
    created_at TIMESTAMP DEFAULT NOW(),
    enviado_em TIMESTAMP,
    aprovado_supervisor_em TIMESTAMP,
    aprovado_engenheiro_em TIMESTAMP,
    aprovado_final_em TIMESTAMP,
    reprovado_em TIMESTAMP,
    
    -- Bloqueio de edição após aprovação
    bloqueado BOOLEAN DEFAULT FALSE,
    
    -- Constraint: apenas 1 DDO por obra por dia
    UNIQUE(obra_id, data)
);

-- Tabela: ddo_atividades
CREATE TABLE ddo_atividades (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ddo_id UUID REFERENCES ddos(id) ON DELETE CASCADE,
    descricao TEXT NOT NULL,
    frente_servico VARCHAR(100),
    volume_movimentado DECIMAL(12,2),
    unidade_medida VARCHAR(20) CHECK (unidade_medida IN ('M3', 'TONELADAS', 'M2', 'ML', 'UNIDADE')),
    created_at TIMESTAMP DEFAULT NOW()
);

-- Tabela: ddo_maquinas
CREATE TABLE ddo_maquinas (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ddo_id UUID REFERENCES ddos(id) ON DELETE CASCADE,
    maquina_id UUID REFERENCES maquinas(id),
    hora_inicio TIME NOT NULL,
    hora_fim TIME NOT NULL,
    total_horas DECIMAL(5,2) GENERATED ALWAYS AS (
        EXTRACT(EPOCH FROM (hora_fim - hora_inicio)) / 3600
    ) STORED,
    atividade_executada TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Tabela: ddo_funcionarios
CREATE TABLE ddo_funcionarios (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ddo_id UUID REFERENCES ddos(id) ON DELETE CASCADE,
    funcionario_id UUID REFERENCES funcionarios(id),
    presente BOOLEAN DEFAULT TRUE,
    horas_trabalhadas DECIMAL(5,2),
    observacao TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Tabela: ddo_ocorrencias
CREATE TABLE ddo_ocorrencias (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ddo_id UUID REFERENCES ddos(id) ON DELETE CASCADE,
    tipo VARCHAR(50) CHECK (tipo IN ('QUEBRA', 'ATRASO', 'PARADA', 'ACIDENTE', 'CLIMA', 'OUTRO')),
    descricao TEXT NOT NULL,
    gravidade VARCHAR(20) CHECK (gravidade IN ('BAIXA', 'MEDIA', 'ALTA', 'CRITICA')),
    created_at TIMESTAMP DEFAULT NOW()
);

-- Tabela: ddo_fotos
CREATE TABLE ddo_fotos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ddo_id UUID REFERENCES ddos(id) ON DELETE CASCADE,
    url TEXT NOT NULL,
    descricao TEXT,
    uploaded_at TIMESTAMP DEFAULT NOW()
);

-- Tabela: logs_auditoria
CREATE TABLE logs_auditoria (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tabela VARCHAR(100) NOT NULL,
    registro_id UUID NOT NULL,
    usuario_id UUID REFERENCES usuarios(id),
    acao VARCHAR(50) CHECK (acao IN ('CREATE', 'UPDATE', 'DELETE', 'APPROVE', 'REJECT')),
    dados_anteriores JSONB,
    dados_novos JSONB,
    ip_address VARCHAR(45),
    created_at TIMESTAMP DEFAULT NOW()
);

-- Índices para performance
CREATE INDEX idx_ddos_obra_data ON ddos(obra_id, data);
CREATE INDEX idx_ddos_status ON ddos(status);
CREATE INDEX idx_usuarios_perfil ON usuarios(perfil);
CREATE INDEX idx_obras_status ON obras(status);
CREATE INDEX idx_logs_tabela_registro ON logs_auditoria(tabela, registro_id);
```

---

## 4. CONTROLE DE ACESSO E PERMISSÕES (RBAC)

### 4.1 Matriz de Permissões

| Funcionalidade | Proprietário | Engenheiro | Supervisor | Admin | Encarregado | Visualizador |
|---|---|---|---|---|---|---|
| Ver todas as obras | ✅ | ❌ (só suas) | ❌ (só suas) | ❌ (só vinculadas) | ❌ (só suas) | ❌ (só permitidas) |
| Criar DDO | ✅ | ❌ | ❌ | ❌ | ✅ | ❌ |
| Editar DDO (rascunho) | ✅ | ❌ | ❌ | ❌ | ✅ (criador) | ❌ |
| Revisar DDO (supervisor) | ✅ | ❌ | ✅ | ❌ | ❌ | ❌ |
| Validar DDO (engenheiro) | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ |
| Aprovar DDO (final) | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ |
| Reprovar DDO | ✅ | ✅ | ✅ | ❌ | ❌ | ❌ |
| Cadastrar obras | ✅ | ❌ | ❌ | ✅ | ❌ | ❌ |
| Cadastrar máquinas | ✅ | ❌ | ❌ | ✅ | ❌ | ❌ |
| Cadastrar funcionários | ✅ | ❌ | ❌ | ✅ | ❌ | ❌ |
| Gerenciar usuários | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ |
| Dashboards completos | ✅ | ✅ (suas obras) | ✅ (suas obras) | ✅ (limitado) | ❌ | ❌ |
| Relatórios financeiros | ✅ | ⚠️ (opcional) | ❌ | ❌ | ❌ | ❌ |
| Exportar PDFs | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Ver logs de auditoria | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ |

### 4.2 Implementação de RBAC (Exemplo em TypeScript)

```typescript
// src/domain/enums/Perfil.ts
export enum Perfil {
  PROPRIETARIO = 'PROPRIETARIO',
  ENGENHEIRO = 'ENGENHEIRO',
  SUPERVISOR = 'SUPERVISOR',
  ADMINISTRADOR = 'ADMINISTRADOR',
  ENCARREGADO = 'ENCARREGADO',
  VISUALIZADOR = 'VISUALIZADOR'
}

// src/domain/enums/Permissao.ts
export enum Permissao {
  DDO_CREATE = 'DDO_CREATE',
  DDO_UPDATE = 'DDO_UPDATE',
  DDO_DELETE = 'DDO_DELETE',
  DDO_APPROVE_SUPERVISOR = 'DDO_APPROVE_SUPERVISOR',
  DDO_APPROVE_ENGENHEIRO = 'DDO_APPROVE_ENGENHEIRO',
  DDO_APPROVE_FINAL = 'DDO_APPROVE_FINAL',
  OBRA_CREATE = 'OBRA_CREATE',
  OBRA_UPDATE = 'OBRA_UPDATE',
  USUARIO_MANAGE = 'USUARIO_MANAGE',
  RELATORIO_FINANCEIRO = 'RELATORIO_FINANCEIRO',
  AUDIT_LOG_VIEW = 'AUDIT_LOG_VIEW'
}

// src/domain/services/PermissaoService.ts
export class PermissaoService {
  private static permissoesPorPerfil: Record<Perfil, Permissao[]> = {
    [Perfil.PROPRIETARIO]: Object.values(Permissao),
    
    [Perfil.ENGENHEIRO]: [
      Permissao.DDO_APPROVE_ENGENHEIRO,
      Permissao.DDO_UPDATE // apenas observações
    ],
    
    [Perfil.SUPERVISOR]: [
      Permissao.DDO_APPROVE_SUPERVISOR,
      Permissao.DDO_UPDATE // apenas observações
    ],
    
    [Perfil.ADMINISTRADOR]: [
      Permissao.OBRA_CREATE,
      Permissao.OBRA_UPDATE
    ],
    
    [Perfil.ENCARREGADO]: [
      Permissao.DDO_CREATE,
      Permissao.DDO_UPDATE // apenas próprios rascunhos
    ],
    
    [Perfil.VISUALIZADOR]: []
  };

  static temPermissao(perfil: Perfil, permissao: Permissao): boolean {
    return this.permissoesPorPerfil[perfil].includes(permissao);
  }
}

// Middleware de autorização
export const autorizar = (...permissoesRequeridas: Permissao[]) => {
  return (req: Request, res: Response, next: NextFunction) => {
    const usuario = req.user; // vem do middleware de autenticação
    
    const temPermissao = permissoesRequeridas.every(perm =>
      PermissaoService.temPermissao(usuario.perfil, perm)
    );
    
    if (!temPermissao) {
      return res.status(403).json({ 
        erro: 'Acesso negado. Permissões insuficientes.' 
      });
    }
    
    next();
  };
};
```

---

## 5. FLUXO DE APROVAÇÃO DE DDO

### 5.1 Diagrama de Estados

```
┌─────────────┐
│  RASCUNHO   │ ◄─── Criação pelo Encarregado
└──────┬──────┘
       │ encarregado.enviar()
       ▼
┌──────────────────────┐
│ ENVIADO_SUPERVISOR   │
└──────┬───────────────┘
       │ supervisor.revisar()
       ├──────────────────────┐
       │ APROVAR              │ REPROVAR
       ▼                      ▼
┌──────────────────────┐  ┌──────────┐
│ APROVADO_SUPERVISOR  │  │REPROVADO │──► Volta para RASCUNHO
└──────┬───────────────┘  └──────────┘
       │ engenheiro.validar()
       ├──────────────────────┐
       │ APROVAR              │ REPROVAR
       ▼                      ▼
┌──────────────────────┐  ┌──────────┐
│ APROVADO_ENGENHEIRO  │  │REPROVADO │──► Volta para RASCUNHO
└──────┬───────────────┘  └──────────┘
       │ proprietario.aprovar()
       ├──────────────────────┐
       │ APROVAR              │ REPROVAR
       ▼                      ▼
┌──────────────────────┐  ┌──────────┐
│  APROVADO_FINAL      │  │REPROVADO │──► Volta para RASCUNHO
│  (DDO BLOQUEADO)     │  └──────────┘
│  ✅ Gera PDF         │
│  ✅ Histórico        │
└──────────────────────┘
```

### 5.2 Regras de Negócio do Fluxo

```typescript
// src/domain/entities/DDO.ts
export class DDO {
  id: string;
  status: StatusDDO;
  bloqueado: boolean;
  
  // ... outros campos
  
  enviarParaSupervisor(encarregadoId: string): void {
    if (this.status !== StatusDDO.RASCUNHO) {
      throw new Error('Apenas DDOs em rascunho podem ser enviados');
    }
    
    if (this.criadoPorId !== encarregadoId) {
      throw new Error('Apenas o criador pode enviar o DDO');
    }
    
    this.status = StatusDDO.ENVIADO_SUPERVISOR;
    this.enviadoEm = new Date();
  }
  
  aprovarComoSupervisor(supervisorId: string, observacao?: string): void {
    if (this.status !== StatusDDO.ENVIADO_SUPERVISOR) {
      throw new Error('Status inválido para aprovação de supervisor');
    }
    
    this.status = StatusDDO.APROVADO_SUPERVISOR;
    this.revisadoSupervisorId = supervisorId;
    this.observacaoSupervisor = observacao;
    this.aprovadoSupervisorEm = new Date();
  }
  
  aprovarComoEngenheiro(engenheiroId: string, observacao?: string): void {
    if (this.status !== StatusDDO.APROVADO_SUPERVISOR) {
      throw new Error('DDO precisa estar aprovado pelo supervisor');
    }
    
    this.status = StatusDDO.APROVADO_ENGENHEIRO;
    this.validadoEngenheiroId = engenheiroId;
    this.observacaoEngenheiro = observacao;
    this.aprovadoEngenheiroEm = new Date();
  }
  
  aprovarFinal(proprietarioId: string, observacao?: string): void {
    if (this.status !== StatusDDO.APROVADO_ENGENHEIRO) {
      throw new Error('DDO precisa estar aprovado pelo engenheiro');
    }
    
    this.status = StatusDDO.APROVADO_FINAL;
    this.aprovadoProprietarioId = proprietarioId;
    this.observacaoProprietario = observacao;
    this.aprovadoFinalEm = new Date();
    this.bloqueado = true; // IMUTÁVEL
  }
  
  reprovar(usuarioId: string, motivo: string): void {
    const statusValidos = [
      StatusDDO.ENVIADO_SUPERVISOR,
      StatusDDO.APROVADO_SUPERVISOR,
      StatusDDO.APROVADO_ENGENHEIRO
    ];
    
    if (!statusValidos.includes(this.status)) {
      throw new Error('Status inválido para reprovação');
    }
    
    this.status = StatusDDO.REPROVADO;
    this.motivoReprovacao = motivo;
    this.reprovadoEm = new Date();
  }
  
  voltarParaRascunho(): void {
    if (this.status !== StatusDDO.REPROVADO) {
      throw new Error('Apenas DDOs reprovados podem voltar para rascunho');
    }
    
    this.status = StatusDDO.RASCUNHO;
    this.motivoReprovacao = undefined;
    this.reprovadoEm = undefined;
  }
}
```

---

## 6. API REST - PRINCIPAIS ENDPOINTS

### 6.1 Autenticação

```
POST /api/auth/login
POST /api/auth/logout
POST /api/auth/refresh-token
POST /api/auth/forgot-password
POST /api/auth/reset-password
```

### 6.2 Usuários

```
GET    /api/usuarios
GET    /api/usuarios/:id
POST   /api/usuarios
PUT    /api/usuarios/:id
DELETE /api/usuarios/:id
PATCH  /api/usuarios/:id/ativar
PATCH  /api/usuarios/:id/desativar
```

### 6.3 Obras

```
GET    /api/obras
GET    /api/obras/:id
POST   /api/obras
PUT    /api/obras/:id
DELETE /api/obras/:id
GET    /api/obras/:id/ddos
GET    /api/obras/:id/estatisticas
```

### 6.4 DDOs (Diário Digital de Obras)

```
GET    /api/ddos
GET    /api/ddos/:id
POST   /api/ddos
PUT    /api/ddos/:id
DELETE /api/ddos/:id

POST   /api/ddos/:id/enviar
POST   /api/ddos/:id/aprovar-supervisor
POST   /api/ddos/:id/aprovar-engenheiro
POST   /api/ddos/:id/aprovar-final
POST   /api/ddos/:id/reprovar

GET    /api/ddos/:id/pdf
POST   /api/ddos/:id/fotos
DELETE /api/ddos/:id/fotos/:fotoId

GET    /api/ddos/:id/historico
```

### 6.5 Máquinas

```
GET    /api/maquinas
GET    /api/maquinas/:id
POST   /api/maquinas
PUT    /api/maquinas/:id
DELETE /api/maquinas/:id
GET    /api/maquinas/:id/historico-uso
```

### 6.6 Funcionários

```
GET    /api/funcionarios
GET    /api/funcionarios/:id
POST   /api/funcionarios
PUT    /api/funcionarios/:id
DELETE /api/funcionarios/:id
GET    /api/funcionarios/:id/historico-trabalho
```

### 6.7 Relatórios

```
GET    /api/relatorios/ddo-diario
GET    /api/relatorios/ddo-semanal
GET    /api/relatorios/ddo-mensal
GET    /api/relatorios/horas-maquinas
GET    /api/relatorios/horas-funcionarios
GET    /api/relatorios/producao-por-obra
GET    /api/relatorios/eficiencia-geral
```

### 6.8 Dashboards

```
GET    /api/dashboards/visao-geral
GET    /api/dashboards/producao-diaria
GET    /api/dashboards/comparativo-obras
GET    /api/dashboards/eficiencia-maquinas
GET    /api/dashboards/ocorrencias
```

---

## 7. SEGURANÇA

### 7.1 Autenticação JWT

```typescript
// Estrutura do Token
interface JWTPayload {
  usuarioId: string;
  email: string;
  perfil: Perfil;
  empresaId: string;
  iat: number;
  exp: number;
}

// Tempo de expiração
const ACCESS_TOKEN_EXPIRY = '15m';
const REFRESH_TOKEN_EXPIRY = '7d';
```

### 7.2 Medidas de Segurança

- ✅ Senha com bcrypt (salt rounds: 12)
- ✅ Rate limiting (100 req/15min por IP)
- ✅ CORS configurado
- ✅ Helmet.js (headers de segurança)
- ✅ SQL injection (queries parametrizadas)
- ✅ XSS (sanitização de inputs)
- ✅ HTTPS obrigatório em produção
- ✅ Auditoria completa de ações

---

## 8. ESTRUTURA DE PASTAS (Backend)

```
transjap-ddo-backend/
├── src/
│   ├── application/
│   │   ├── services/
│   │   │   ├── DDOService.ts
│   │   │   ├── ObraService.ts
│   │   │   ├── UsuarioService.ts
│   │   │   └── RelatorioService.ts
│   │   └── usecases/
│   │       ├── CriarDDOUseCase.ts
│   │       ├── AprovarDDOUseCase.ts
│   │       └── GerarRelatorioPDFUseCase.ts
│   │
│   ├── domain/
│   │   ├── entities/
│   │   │   ├── DDO.ts
│   │   │   ├── Obra.ts
│   │   │   ├── Usuario.ts
│   │   │   ├── Maquina.ts
│   │   │   └── Funcionario.ts
│   │   ├── enums/
│   │   │   ├── Perfil.ts
│   │   │   ├── StatusDDO.ts
│   │   │   └── Permissao.ts
│   │   ├── valueObjects/
│   │   │   ├── CPF.ts
│   │   │   ├── CNPJ.ts
│   │   │   └── Email.ts
│   │   └── services/
│   │       ├── PermissaoService.ts
│   │       └── AprovacaoService.ts
│   │
│   ├── infrastructure/
│   │   ├── database/
│   │   │   ├── prisma/
│   │   │   │   └── schema.prisma
│   │   │   └── repositories/
│   │   │       ├── DDORepository.ts
│   │   │       ├── ObraRepository.ts
│   │   │       └── UsuarioRepository.ts
│   │   ├── external/
│   │   │   ├── S3StorageService.ts
│   │   │   └── PDFGeneratorService.ts
│   │   └── cache/
│   │       └── RedisService.ts
│   │
│   ├── presentation/
│   │   ├── controllers/
│   │   │   ├── DDOController.ts
│   │   │   ├── ObraController.ts
│   │   │   └── UsuarioController.ts
│   │   ├── middlewares/
│   │   │   ├── autenticacao.ts
│   │   │   ├── autorizacao.ts
│   │   │   ├── validacao.ts
│   │   │   └── errorHandler.ts
│   │   ├── routes/
│   │   │   ├── ddo.routes.ts
│   │   │   ├── obra.routes.ts
│   │   │   └── usuario.routes.ts
│   │   └── validators/
│   │       ├── DDOValidator.ts
│   │       └── ObraValidator.ts
│   │
│   ├── shared/
│   │   ├── errors/
│   │   │   ├── AppError.ts
│   │   │   └── ValidationError.ts
│   │   ├── utils/
│   │   │   ├── logger.ts
│   │   │   └── dateUtils.ts
│   │   └── config/
│   │       ├── database.ts
│   │       └── env.ts
│   │
│   └── server.ts
│
├── tests/
│   ├── unit/
│   ├── integration/
│   └── e2e/
│
├── prisma/
│   ├── schema.prisma
│   ├── migrations/
│   └── seed.ts
│
├── .env.example
├── .gitignore
├── package.json
├── tsconfig.json
├── docker-compose.yml
└── README.md
```

---

## 9. PRÓXIMOS PASSOS

### Fase 1: Setup e Estrutura Base (Semana 1-2)
- [ ] Configurar repositório Git
- [ ] Setup Docker + PostgreSQL + Redis
- [ ] Configurar TypeScript + ESLint + Prettier
- [ ] Implementar estrutura de pastas
- [ ] Configurar Prisma ORM
- [ ] Criar migrations iniciais

### Fase 2: Autenticação e Usuários (Semana 3)
- [ ] Implementar autenticação JWT
- [ ] CRUD de usuários
- [ ] Sistema de permissões (RBAC)
- [ ] Testes unitários

### Fase 3: Core do Sistema (Semana 4-6)
- [ ] CRUD de Obras
- [ ] CRUD de Máquinas
- [ ] CRUD de Funcionários
- [ ] Implementar DDO completo
- [ ] Fluxo de aprovação

### Fase 4: Relatórios e Dashboards (Semana 7-8)
- [ ] Geração de PDF
- [ ] Endpoints de relatórios
- [ ] Dashboards de produtividade
- [ ] Exportação Excel

### Fase 5: Frontend (Semana 9-12)
- [ ] Setup React + TypeScript
- [ ] Sistema de autenticação
- [ ] Interface de criação de DDO
- [ ] Dashboards visuais
- [ ] Responsividade mobile

### Fase 6: Testes e Deploy (Semana 13-14)
- [ ] Testes E2E
- [ ] CI/CD pipeline
- [ ] Deploy em produção
- [ ] Documentação final

---

**Documento criado para o projeto TRANSJAP DDO**  
Arquiteto: Claude (Anthropic)  
Data: 07/02/2026
