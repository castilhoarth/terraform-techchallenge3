Aqui está a documentação completa do projeto **ToggleMaster**, elaborada do zero em formato `README.md`, refletindo a arquitetura de infraestrutura nativa e automatizada com Terraform em Conta Pessoal da AWS.

---

# 🚀 ToggleMaster — Infrastructure as Code (IaC)

Este repositório contém a infraestrutura como código (IaC) completa e automatizada para o **ToggleMaster**, uma plataforma de gerenciamento e avaliação de Feature Flags composta por **5 microsserviços**:

1. **Auth Service** — Autenticação e gestão de permissões.
2. **Flag Service** — Gerenciamento e cadastro de feature flags.
3. **Targeting Service** — Regras de direcionamento e segmentação de usuários.
4. **Evaluation Service** — Avaliação em tempo real de flags com baixíssima latência.
5. **Analytics Service** — Processamento e armazenamento de eventos de telemetria e auditoria.

---

## 🏗️ Arquitetura da Infraestrutura

A infraestrutura é provisionada de forma 100% automatizada e imutável via **Terraform** na **AWS**, organizada de maneira modularizada:

```text
                                +---------------------------------------------------+
                                |                    VPC (AWS)                      |
                                |                                                   |
                                |   +-------------------------------------------+   |
                                |   |             Cluster EKS (k8s)             |   |
|--------|                      |   |                                           |   |
| GitHub |  --->  [ AWS ECR ] ----> |   [ Auth ]  [ Flag ]  [ Targeting ]       |   |
| Actions|        (5 Repos)     |   |                                           |   |
|--------|                      |   |   [ Evaluation ]      [ Analytics ]       |   |
                                |   +--------|--------------------|-------------+   |
                                |            |                    |                 |
                                |            v                    v                 |
                                |    [ ElastiCache ]         [ AWS SQS ]            |
                                |        (Redis)                  |                 |
                                |                                 v                 |
                                |    [ 3x RDS PostgreSQL ]   [ DynamoDB ]           |
                                |    (Auth/Flag/Targeting)   (Analytics Events)     |
                                +---------------------------------------------------+

```

### Componentes Provisionados:

* **Networking (VPC):** VPC dedicada, Subnets Públicas e Privadas distribuídas em Múltiplas Zonas de Disponibilidade (Multi-AZ), Internet Gateway, Route Tables e NAT Gateways para tráfego seguro de saída dos Worker Nodes.
* **Orquestração (Amazon EKS):** Cluster Kubernetes gerenciado com Node Groups (instâncias EC2), papéis IAM dedicados e Add-ons essenciais (`vpc-cni`, `coredns`, `kube-proxy`).
* **Bancos de Dados Relacionais (Amazon RDS PostgreSQL):** 3 instâncias isoladas de banco de dados para os serviços de `Auth`, `Flag` e `Targeting`, com credenciais dinâmicas e seguras armazenadas no **AWS Secrets Manager**.
* **Cache em Memória (Amazon ElastiCache Redis):** Cluster Redis em subnets privadas para suportar chamadas de alta performance no `Evaluation Service`.
* **Banco NoSQL (Amazon DynamoDB):** Tabela `ToggleMasterAnalytics` provisionada para ingestão e armazenamento de eventos do `Analytics Service`.
* **Mensageria (Amazon SQS):** Fila de mensageria para desacoplamento e processamento assíncrono de telemetria entre o `Evaluation Service` e o `Analytics Service`.
* **Container Registry (Amazon ECR):** 5 repositórios privados para versionamento das imagens Docker dos microsserviços.
* **Segurança & IAM:** Uso de **IRSA (IAM Roles for Service Accounts)** para concede permissões nativas a nível de Pod no Kubernetes para acessar recursos como SQS e DynamoDB com princípio de menor privilégio.

---

## 📁 Estrutura de Arquivos

```text
.
├── main.tf                  # Declaração e encadeamento dos módulos de infraestrutura
├── variables.tf             # Variáveis globais do projeto
├── outputs.tf               # Saídas contendo endpoints, ARNs e dados relevantes
├── provider.tf              # Provedor AWS e tags padrão da infraestrutura
├── backend.tf               # Backend remoto S3 com S3 Native Lock
├── terraform.tfvars         # Atribuição de valores de variáveis
└── modules/
    ├── vpc/                 # Módulo de Rede
    ├── iam/                 # Módulo de Roles e Políticas de Acesso
    ├── eks/                 # Módulo do Cluster Kubernetes EKS e Worker Nodes
    ├── rds/                 # Módulo das 3 instâncias PostgreSQL + Secrets Manager
    ├── elasticache/         # Módulo do Cluster Redis
    ├── dynamodb/            # Módulo da Tabela DynamoDB
    ├── sqs/                 # Módulo da Fila SQS
    └── ecr/                 # Módulo dos 5 Repositórios ECR

```

---

## 🛠️ Pré-requisitos

Antes de iniciar, certifique-se de possuir em seu ambiente de desenvolvimento:

* **[Terraform CLI](https://developer.hashicorp.com/terraform/downloads)** `>= 1.10.0`
* **[AWS CLI](https://aws.amazon.com/cli/)** `>= 2.x` devidamente configurado com um usuário IAM com permissões administrativas (`aws configure`).
* **[kubectl](https://kubernetes.io/docs/tasks/tools/)** para gerenciamento do cluster EKS.
* **[Docker](https://www.docker.com/)** para build e empacotamento dos microsserviços.

---

## ⚙️ Passo a Passo de Implantação

### 1. Criar o Bucket S3 para o Remote State

Crie um bucket único no Amazon S3 para armazenar o arquivo de estado (`terraform.tfstate`):

```bash
aws s3api create-bucket --bucket togglemaster-bucket-s3 --region us-east-1

```

### 2. Configurar o Backend Remoto

Garanta que o arquivo `backend.tf` aponta para o bucket criado:

```hcl
terraform {
  required_version = ">= 1.10.0"

  backend "s3" {
    bucket       = "togglemaster-bucket-s3"
    key          = "prod/togglemaster/terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = true
  }
}

```

### 3. Inicializar o Terraform

Inicialize os provedores e os módulos do projeto:

```bash
terraform init

```

### 4. (Opcional) Provisionar Apenas os Repositórios ECR First

Caso deseje realizar o build e push das imagens Docker antes de criar o cluster e os bancos de dados:

```bash
terraform apply -target=module.ecr -auto-approve

```

### 5. Provisionar Toda a Infraestrutura

Para planejar e provisionar todos os recursos na AWS:

```bash
# Validar as alterações planejadas
terraform plan

# Aplicar o provisionamento
terraform apply -auto-approve

```

---

## 🔌 Conectando-se ao Cluster Kubernetes (EKS)

Após a conclusão da execução do `terraform apply`, atualize seu arquivo de contexto do `kubectl`:

```bash
aws eks update-kubeconfig --region us-east-1 --name togglemaster-eks

```

Verifique o status dos nós do cluster:

```bash
kubectl get nodes

```

---

## 🔒 Segurança e Boas Práticas

* **Infraestrutura Imutável:** Todas as alterações na infraestrutura devem ser feitas estritamente via código Terraform.
* **Gestão de Segredos:** Nenhuma senha ou credencial é exposta no código. As senhas dos bancos de dados RDS são geradas randomicamente e armazenadas no AWS Secrets Manager.
* **Trava de Estado (State Locking):** O backend remoto utiliza `use_lockfile = true` nativo no S3 para impedir alterações concorrentes no arquivo de estado.
* **Isolamento de Rede:** Os bancos de dados (RDS), cache (ElastiCache) e Worker Nodes do EKS rodam exclusivamente em Subnets Privadas sem exposição pública direta.

---

## 🧹 Destruição da Infraestrutura

Para remover todos os recursos provisionados na AWS e evitar custos não intencionais:

```bash
terraform destroy -auto-approve

```
