# Requisitos da API de Reservas

## Aplicação

**Regras Gerais da Entidade "Reserva"**
- Todos os dados devem ser obrigatoriamente persistidos e lidos em um banco de dados PostgreSQL (não em memória).
- O campo `id` é gerado automaticamente pelo banco de dados (não deve ser enviado pelo usuário na criação).
- O campo `status` é restrito e aceita apenas os valores: "pendente", "confirmada" ou "cancelada".

**R1 — Cadastrar reserva (POST /reservas)**
Como usuário, quero cadastrar uma nova reserva, para que o agendamento fique registrado no sistema.
- QUANDO eu enviar os dados obrigatórios corretos (cliente, data e status), O SISTEMA DEVE salvar a reserva no banco de dados e devolver os dados criados com o código HTTP 201 (Created).
- QUANDO faltar algum campo obrigatório ou o status for inválido, O SISTEMA DEVE recusar a requisição e retornar o erro HTTP 400 (Bad Request).

**R2 — Listar todas as reservas (GET /reservas)**
Como usuário, quero listar todas as reservas, para visualizar a agenda completa.
- QUANDO eu solicitar a listagem e existirem reservas, O SISTEMA DEVE devolver a lista com os dados lidos do banco de dados e o código HTTP 200 (OK).
- QUANDO eu solicitar a listagem e não houver nenhuma reserva cadastrada no banco, O SISTEMA DEVE devolver uma lista vazia `[]` com o código HTTP 200 (OK).

**R3 — Buscar reserva pelo ID (GET /reservas/:id)**
Como usuário, quero buscar uma reserva específica pelo seu ID, para conferir seus detalhes.
- QUANDO eu enviar um ID existente, O SISTEMA DEVE devolver os dados dessa reserva com o código HTTP 200 (OK).
- QUANDO eu enviar um ID que não existe, O SISTEMA DEVE retornar o erro HTTP 404 (Not Found).

**R4 — Atualizar reserva (PUT /reservas/:id)**
Como usuário, quero atualizar os dados de uma reserva, para corrigir informações ou alterar seu status.
- QUANDO eu enviar um ID válido e os novos dados completos, O SISTEMA DEVE atualizar a reserva no banco de dados e retornar os dados atualizados com o código HTTP 200 (OK).
- QUANDO eu enviar o ID de uma reserva que não existe, O SISTEMA DEVE retornar o erro HTTP 404 (Not Found).
- QUANDO eu enviar um ID válido, mas faltarem campos obrigatórios no envio ou o status for inválido, O SISTEMA DEVE retornar o erro HTTP 400 (Bad Request).

**R5 — Remover reserva (DELETE /reservas/:id)**
Como usuário, quero remover uma reserva, para limpar registros cancelados ou errados.
- QUANDO eu enviar o ID de uma reserva existente, O SISTEMA DEVE deletar o registro do banco de dados e retornar o código HTTP 204 (No Content).
- QUANDO eu enviar o ID de uma reserva que não existe, O SISTEMA DEVE retornar o erro HTTP 404 (Not Found).

**R6 — Verificar saúde da API (GET /health)**
Como sistema de infraestrutura (Docker/AWS), quero checar a saúde da API, para saber se ela está pronta para receber tráfego.
- QUANDO eu acessar a rota, O SISTEMA DEVE retornar uma mensagem de sucesso (ex: "UP") com o código HTTP 200 (OK).

## Ambiente Local

- O ambiente de desenvolvimento completo (API + Banco de Dados) deve subir com um único comando.
- Os dados salvos no banco de dados não podem ser perdidos caso os containers sejam desligados ou reiniciados (uso de volumes).
- A API só deve tentar se conectar ao banco de dados após ele estar totalmente pronto para receber conexões (healthcheck na inicialização).
- Senhas, chaves e credenciais reais devem ficar em um arquivo `.env` local, que nunca será versionado. Um arquivo `.env.example` deve existir no repositório apenas como modelo estrutural.
- Por questões de segurança, a aplicação dentro do container Docker deve ser executada por um usuário não-root.

## Infraestrutura na Nuvem

- A infraestrutura provisionada deve conter: configuração de rede (VPC com subnets públicas e privadas em 2 zonas de disponibilidade), regras de firewall (Security Groups), um servidor para a aplicação (EC2) e um banco de dados relacional (RDS).
- Acesso e Segurança: A aplicação (EC2) deve ser acessível via internet, mas o Banco de Dados (RDS) deve ser estritamente privado, aceitando conexões apenas vindas do Security Group da EC2.
- O controle de estado da infraestrutura (Remote State) não deve ficar na máquina local do desenvolvedor; ele deve ser salvo na nuvem (S3) de forma segura.
- O armazenamento do estado remoto (S3) deve ter versionamento e encriptação habilitados.
- O banco de dados (RDS) deve ter o armazenamento criptografado.
- O sistema de state deve possuir mecanismo de trava (Lock via DynamoDB) para impedir que duas ou mais pessoas apliquem mudanças simultaneamente e corrompam o estado da infraestrutura.
- A infraestrutura deve ser completamente modularizada no Terraform, garantindo que qualquer pessoa consiga reproduzir o mesmo ambiente de forma automática apenas rodando o código.
- Todos os recursos provisionados na AWS devem possuir tags de identificação.
- O Terraform deve retornar como saídas (outputs) as seguintes informações: IP da EC2, endpoint do RDS e a URL da API.

## Learner Lab

- É estritamente proibido criar recursos próprios de IAM (Users, Groups ou Roles). Sempre que necessário, deve-se utilizar a `LabRole` e o `LabInstanceProfile`.
- Todos os recursos de nuvem devem ser criados na região `us-east-1`.
- Para evitar consumo desnecessário de créditos, toda a infraestrutura deve ser destruída imediatamente após a captura das evidências de funcionamento.

## Git e Versionamento

- O repositório deve conter um arquivo `README.md` na raiz informando o nome do aluno, RA e a descrição do projeto.
- O desenvolvimento de novas funcionalidades não deve ser feito diretamente na branch `main`; deve-se utilizar branches secundárias (feature branches) integradas via Merge.
- O projeto deve conter um histórico mínimo de 6 commits, seguindo obrigatoriamente a padronização do Conventional Commits (ex: `feat:`, `docs:`, `fix:`, `chore:`).
- Arquivos de configuração pessoal, de estado de infraestrutura ou pacotes pesados (`node_modules`, `.env`, `.terraform`, `*.tfstate`, `*.pem`) são estritamente proibidos de subir para o repositório.