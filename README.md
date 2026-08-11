```markdown
# 🚀 Tech Challenge - Fase 3: Infraestrutura AWS com Terraform

Este repositório contém o código de **Infrastructure as Code (IaC)** desenvolvido em Terraform para o provisionamento da infraestrutura cloud no **AWS Academy** referente ao Tech Challenge (Fase 3).

A arquitetura foi desenhada de forma modular, garantindo segregação de redes, persistência de dados gerenciada e ambiente de orquestração de microsserviços via Kubernetes (EKS).

---

## 🏗️ Arquitetura da Solução

O projeto provisiona uma infraestrutura completa na AWS composta por:

* **VPC & Redes (`modules/vpc`):**
  * Subnets públicas e privadas distribuídas em múltiplas zonas de disponibilidade (Multi-AZ).
  * Route tables e Internet Gateway.
  * Tagging padrão para integração dinâmica com o AWS EKS.

* **EKS - Elastic Kubernetes Service (`modules/eks`):**
  * Control Plane gerenciado e Node Group em instâncias EC2 (`t3.medium`).
  * Add-ons EKS ativos: `vpc-cni`, `coredns` e `kube-proxy`.
  * Suporte nativo para autenticação via `LabRole` (AWS Academy).

* **RDS PostgreSQL (`modules/rds`):**
  * Instâncias de banco de dados relacionais gerenciadas (PostgreSQL 15).
  * Security Groups configurados com acesso restrito apenas aos nós do EKS.

* **ElastiCache Redis (`modules/elasticache`):**
  * Cluster de cache em memória em Subnet Group privado.
  * Regras de firewall isolando a porta `6379` para uso exclusivo do cluster EKS.

* **Serviços Complementares:**
  * **ECR (`modules/ecr`):** Repositórios para armazenar as imagens Docker dos microsserviços.
  * **SQS (`modules/sqs`):** Filas de mensageria assíncrona para desmembramento de processos.
  * **DynamoDB (`modules/dynamodb`):** Tabelas NoSQL para dados de leitura rápida/estado.

---

## 📁 Estrutura do Repositório

```text
.
├── modules/
│   ├── dynamodb/      # Configuração das tabelas NoSQL
│   ├── ecr/           # Repositórios de imagens Docker
│   ├── eks/           # Cluster Kubernetes e Node Groups
│   ├── elasticache/   # Cluster Redis em Subnets privadas
│   ├── rds/           # Instâncias de banco de dados PostgreSQL
│   ├── sqs/           # Filas de mensageria
│   └── vpc/           # Infraestrutura de rede e subnets
├── backend.tf         # Configuração do Remote State no S3
├── main.tf            # Chamada dos módulos de infraestrutura
├── outputs.tf         # Saídas de dados importantes (Endpoints, IDs)
├── provider.tf        # Configuração do AWS Provider e Tags globais
├── variables.tf       # Declaração das variáveis do projeto
└── README.md          # Documentação do projeto

```

---

## 🛠️ Pré-requisitos

* [Terraform](https://www.terraform.io/) `>= 1.10.0`
* [AWS CLI](https://aws.amazon.com/cli/) instalado e configurado
* Credenciais de acesso temporário do **AWS Academy** (`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_SESSION_TOKEN`)

---

## 🚀 Como Executar o Projeto

### 1. Clonar o repositório

```bash
git clone [https://github.com/castilhoarth/terraform-techchallenge3.git](https://github.com/castilhoarth/terraform-techchallenge3.git)
cd terraform-techchallenge3

```

### 2. Exportar as credenciais do AWS Academy

Cole as credenciais temporárias do seu painel no terminal:

```bash
export AWS_ACCESS_KEY_ID="ASIA..."
export AWS_SECRET_ACCESS_KEY="..."
export AWS_SESSION_TOKEN="..."

```

### 3. Inicializar o Terraform

```bash
terraform init

```

### 4. Validar o plano de execução

```bash
terraform plan

```

### 5. Aplicar a infraestrutura

```bash
terraform apply -auto-approve

```

---

## 🔒 Segurança e Boas Práticas

* **Remote State:** O arquivo de estado do Terraform (`terraform.tfstate`) é armazenado com segurança em um bucket S3 remoto, utilizando trava de estado (`use_lockfile = true`).
* **Isolamento de Credenciais:** Arquivos com variáveis sensíveis (`.tfvars`), binários e estados locais estão devidamente ignorados via `.gitignore`.
* **Segurança de Rede:** Serviços de banco de dados (RDS) e cache (ElastiCache) não possuem IP público e aceitam conexões puramente originadas pelo Security Group do cluster EKS.

```
