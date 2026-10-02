# Relatório do Processo — Prova do Primeiro Bimestre (DevOps)

**Aluno:** Matheus Maciel de Paula
**RA:** 6325065
**Ferramenta de IA utilizada:** Claude (Anthropic), e só ele, do começo ao fim.

Antes de começar, dei uma olhada no Kiro do jeito que foi mostrado nas aulas, mas acabei preferindo fazer tudo no Claude. O motivo foi simples: eu queria manter o projeto inteiro numa conversa só, com todo o histórico das configurações e decisões, em vez de ficar pulando entre ferramentas e perdendo o contexto.

---

## Questão 1 — A Jornada Completa (Aulas 01 a 07)

Segui a ordem que a própria prova sugere: primeiro Git e a aplicação, depois o container, depois o ambiente local e só no final a AWS. Fiz assim porque cada camada depende da anterior. Se a API não funcionasse nem no Docker da minha máquina, não fazia o menor sentido tentar descobrir o problema dentro de uma EC2.

O caminho ficou assim:

1. **Começando pela especificação (Aula 07):** antes de escrever qualquer código, montei o `specs/requisitos.md` com tudo o que a API precisava fazer (rotas, códigos HTTP, validações) e tudo o que o ambiente precisava ter (local, nuvem, regras do Learner Lab e do Git). Esse arquivo virou meu checklist até o final.
2. **Git (Aula 01):** criei o repositório já com `.gitignore` e README e usei Conventional Commits desde o primeiro commit. A API nasceu na branch `feature/api-reservas` e a infra na `feature/infra`, as duas com merge na `main`.
3. **API e Docker (Aula 01):** escrevi a API em Node.js/Express com o CRUD completo gravando no PostgreSQL, usando consultas parametrizadas e validação dos campos. Depois coloquei num Dockerfile multi-stage, rodando com usuário não-root (`USER node`), e criei o `.dockerignore`.
4. **Docker Compose (Aula 02):** aproveitei o compose que eu tinha feito na Aula 02 e tirei o Redis, que não fazia parte desse projeto. Ficaram a API e o PostgreSQL subindo com um comando só, com volume nomeado, rede bridge, healthcheck e `depends_on` esperando o banco ficar saudável. Testei o CRUD e testei derrubar e subir os containers para ver se os dados continuavam lá.
5. **Terraform e IAM (Aula 03):** o ciclo `init → validate → plan → apply → destroy` eu usei o tempo todo. A Aula 03 também serviu de contraste: lá eu criei users, groups e roles, e aqui isso é proibido pelo Learner Lab.
6. **VPC e EC2 (Aula 04):** a rede com subnets públicas e privadas em 2 AZs e a EC2 com `LabInstanceProfile` partiram do que eu já tinha feito na Aula 04.
7. **RDS e Remote State (Aula 05):** o RDS privado e criptografado, com o Security Group liberando a 5432 só para a EC2, já existia no meu código da Aula 05. O backend com S3 e DynamoDB eu criei antes de tudo, por causa daquele problema do "ovo e da galinha": o bucket precisa existir antes de o Terraform conseguir guardar o state nele.
8. **Módulos (Aula 06):** peguei os arquivos soltos das Aulas 04 e 05 e transformei em quatro módulos (`vpc`, `security-group`, `ec2` e `rds`). A parte de módulos eu estudei pelo material da Aula 06 durante a própria prova. A ligação entre eles ficou no `infra/main.tf`, onde a saída de um módulo vira entrada do outro.

No final, ficou bem claro para mim que cada aula era uma peça e que elas só fazem sentido juntas. O Git guarda a história, o Docker garante que a aplicação roda igual em qualquer lugar, o Terraform deixa a infraestrutura reproduzível e os módulos organizam tudo isso para dar para reaproveitar.

---

## Questão 2 — O Processo com IA como Copiloto

Usei o Claude de dois jeitos diferentes durante a prova.

**Na parte da aplicação** (requisitos, API, Dockerfile e Compose), pedi para ele funcionar como um tutor: me explicar o que tinha que ser feito, passo a passo, mas **sem me dar a resposta pronta**. Eu escrevia e ele revisava. Foi assim que saíram os requisitos, o `db.js`, o `index.js`, o Dockerfile e o compose.

**Na parte da infraestrutura,** o tempo começou a apertar e eu mudei de estratégia. Passei as regras do Learner Lab logo no começo e fui mandando as tarefas uma por uma. O Claude gerava o código e eu revisava e testava antes de aplicar.

### Como ficou o fluxo Spec-Driven

- **Requisitos:** o `specs/requisitos.md` eu escrevi, e ele foi revisado em algumas rodadas até ficar completo.
- **Design:** aqui vou ser sincero: não fiz um documento de design separado. Com o tempo curto, preferi resolver as decisões de design dentro de cada tarefa (o que cada módulo recebe, o que devolve, como eles se conectam e por que escolhi cada coisa, como AES256 em vez de KMS no bucket e PostgreSQL 15 no RDS). Foi a etapa do fluxo que eu segui com menos rigor.
- **Tarefas:** uma tarefa por prompt (backend, VPC, SG, EC2, RDS e a composição final), e só passava para a próxima depois de validar a anterior.

### Os prompts principais e o que aconteceu em cada um

1. **Revisão dos requisitos.** Pedi para ele avaliar o documento antes do commit. Ele mostrou que faltavam duas rotas da tabela da prova, que meus códigos de erro estavam vagos e que eu não tinha pensado no caso da lista vazia. Corrigi tudo: entrou o DELETE e o `/health`, defini 201, 400, 404 e 204, e limitei os valores aceitos no `status`.
2. **Revisão da API.** Depois de escrever as rotas, pedi uma revisão. Ele encontrou três problemas que eu não tinha testado: buscar um ID que não é número dava erro 500, mandar uma data inválida também dava 500, e na AWS a tabela podia nunca ser criada se a API subisse antes do banco. Corrigi as validações e fiz a conexão tentar 5 vezes antes de subir o servidor.
3. **Regras do Learner Lab.** Antes de qualquer código de infra, deixei claro: região `us-east-1`, proibido criar IAM e uso só da `LabRole`/`LabInstanceProfile`. A própria prova dá essa dica, e fez diferença.
4. **Módulo VPC.** Veio completo, com a route table privada sem saída para a internet. Conferi que não tinha NAT Gateway (que custa dinheiro) e que os CIDRs eram os mesmos da minha Aula 04.
5. **Módulo de Security Groups.** O ponto principal era o SG do RDS liberar a 5432 apontando para o SG da EC2, e não para um bloco de IPs. Foi exatamente o que eu tinha feito "errado" na Aula 04, quando liberei a VPC inteira.
6. **Módulo EC2.** Veio com o `user_data` gravando as variáveis num arquivo protegido e subindo a API com systemd. Desconfiei que as variáveis do banco não estavam chegando na API e pedi para corrigir. Ele me mostrou que já estavam sendo injetadas pelo `EnvironmentFile` do systemd. Entendi a lógica e mantive como estava.
7. **Módulo RDS.** Veio com `skip_final_snapshot` (para o destroy funcionar) e uma validação de senha que acabou me salvando depois.
8. **Composição final.** O `main.tf` ligando os quatro módulos. Conferi que a ordem (VPC → SG → RDS → EC2) saía naturalmente das referências entre eles.
9. **Erro de sintaxe.** O `terraform validate` reclamou de blocos escritos numa linha só no `variables.tf` da EC2. Aprendi que o HCL só aceita bloco de uma linha quando ele tem um único argumento.
10. **AccessDenied no S3.** Na hora de criar o backend, tomei um erro de permissão. Era uma trava da conta da faculdade (SCP) bloqueando a leitura do Object Lock, que o Terraform faz por baixo dos panos sempre que cria um bucket. A saída foi criar o bucket pela AWS CLI e deixar o Terraform cuidar só do versionamento, da criptografia e do bloqueio público.
11. **API não respondia na AWS.** Pedi ajuda para entrar na EC2 por SSH e ler os logs. Foi assim que achei o erro de verdade: o banco recusava a conexão por falta de SSL.
12. **Revisão antes do destroy.** Pedi uma conferência geral antes de apagar tudo. Isso me lembrou de salvar as provas de segurança do RDS e do Security Group, que depois do destroy não daria mais para gerar.

### O que a IA fez bem

A estrutura dos módulos Terraform, o `user_data` com systemd e, principalmente, explicar os erros. No caso do S3, sinceramente, eu não teria chegado sozinho na causa.

### O que precisou ser corrigido

- **A IA errou sobre o SSL.** Ela afirmou que o PostgreSQL 15 no RDS não exigia SSL por padrão. Na prática, a API não conectava de jeito nenhum. Eu tinha quase certeza de que o problema era o Security Group ou alguma senha digitada errada no `.tfvars`. Só quando entramos no `journalctl` e rodamos um teste de conexão apareceu a mensagem `no encryption`. Aí a ficha caiu: código que roda liso no Docker local pode quebrar na AWS se a gente ignorar a camada de segurança da nuvem. Corrigi ativando SSL por uma variável de ambiente (`DB_SSL=true`), sem quebrar o ambiente local.
- **Faltavam o `providers.tf` e o backend** quando rodei o primeiro `plan`. Sem eles o state estava ficando na minha máquina, e não no S3.
- **A senha foi pedida às cegas.** Eu redirecionei a saída do `plan` para um arquivo sem ter criado o `terraform.tfvars`, então a pergunta da senha foi parar dentro do arquivo e eu não vi. A validação do módulo RDS barrou a senha inválida antes de eu perder 10 minutos num `apply`.

### Comparando com fazer tudo na mão

**Onde a IA me poupou tempo:**
- Escrever os quatro módulos com `variables.tf` e `outputs.tf` batendo entre si. É código repetitivo e muito fácil de errar um nome de output que não bate com o input do outro módulo.
- Entender erros específicos do ambiente. O AccessDenied da SCP teria me custado horas de documentação e fórum.
- Na parte da aplicação, as revisões pegaram bugs que eu nem tinha testado.

**Onde ela atrapalhou:**
- A informação errada sobre o SSL me fez descartar justamente a causa verdadeira. Só o teste real resolveu.
- Ela disse que o plan teria 16 recursos, e ele mostrou 17. Foi um erro pequeno, mas me lembrou que eu tenho que conferir o plan, e não o que a IA diz que o plan vai mostrar.
- Quando eu recebia o código pronto, demorava mais para entender o que estava acontecendo do que quando escrevi a API sozinho, só com orientação.

Fazendo tudo na mão, eu teria levado bem mais tempo e lido muito mais documentação, mas confiaria menos em respostas sem conferir. O jeito que funcionou para mim foi: a IA gera e eu valido com comandos de verdade (`plan`, `curl`, AWS CLI e `journalctl`).

---

## Questão 3 — Infraestrutura, Segurança e o Learner Lab

```text
                  Internet
                     |
              Internet Gateway
                     |
     VPC 10.0.0.0/16 (us-east-1)
     ├─ us-east-1a
     │    ├─ Pública 10.0.1.0/24 ── EC2 t2.micro (API :3000, LabInstanceProfile)
     │    └─ Privada 10.0.2.0/24 ── RDS PostgreSQL db.t3.micro
     └─ us-east-1b
          ├─ Pública 10.0.3.0/24
          └─ Privada 10.0.4.0/24 ── (subnet group do RDS)

  SG EC2: 22 e 3000 abertos       SG RDS: 5432 só a partir do SG da EC2
  State remoto: S3 (versionado + AES256 + sem acesso público) + DynamoDB (lock)
```

**Por que o RDS fica na privada e a EC2 na pública?** A EC2 precisa receber as requisições de quem usa a API, então ela fica na subnet que tem rota para a internet e tem IP público. O banco não precisa, e nem deve, ser acessado de fora. Ele fica nas subnets privadas, que não têm rota nenhuma para a internet, com `publicly_accessible = false`. E, mesmo dentro da VPC, o SG do RDS só aceita a 5432 de quem está com o SG da EC2. Antes do destroy, guardei a prova disso (`evidencias/rds-seguranca.txt` e `evidencias/rds-sg-regras.txt`): `Publico: False`, `Criptografado: True` e nenhuma regra aberta para `0.0.0.0/0` na 5432. Uma curiosidade: mesmo sem Multi-AZ, o RDS exige subnets em 2 zonas no subnet group, e por isso existem as duas privadas.

**Como funcionou o LabRole/LabInstanceProfile?** Na Aula 03 eu criei tudo de IAM do zero (users, groups, roles, instance profile). No Learner Lab isso é bloqueado pela política da conta de estudante. A `LabRole` é a role que o Lab já deixa pronta, com as permissões. O `LabInstanceProfile` é o que permite "pendurar" essa role numa EC2, porque a instância não recebe a role direto, e sim através de um instance profile. Então, no módulo `ec2`, em vez de criar `aws_iam_role` e `aws_iam_instance_profile`, eu só passei o nome do perfil que já existe: `iam_instance_profile = "LabInstanceProfile"`. Com isso, a instância ganha credenciais temporárias da `LabRole` pelo serviço de metadados (configurei com IMDSv2), sem nenhuma chave salva no servidor. Na minha API, a EC2 nem precisou chamar outros serviços da AWS (ela só conversa com o RDS, com usuário e senha do banco), mas o perfil fica lá pronto se um dia a aplicação precisar, por exemplo, salvar arquivos no S3. O plan final confirma que a única coisa de IAM na infraestrutura inteira é essa linha.

**O que o Learner Lab me obrigou a ajustar:**
- **Credenciais temporárias:** copiadas de AWS Details para o `~/.aws/credentials`, com o `aws_session_token`. Elas expiraram no meio da prova e precisei renovar. Quando a sessão acabou, o Lab desligou a EC2 e, ao religar, o IP público mudou, então precisei rodar `terraform apply -refresh-only` para descobrir o IP novo.
- **Região fixa:** `us-east-1` em tudo, nos providers e no backend.
- **SCP bloqueando o Object Lock do S3:** na hora bateu um desespero, porque achei que tinha feito algo proibido na conta. Quando entendi que era uma trava da faculdade e que dava para contornar criando o bucket pela CLI, achei bem legal ver o Terraform gerenciando as propriedades de um recurso que foi criado "por fora".
- **SSL obrigatório no RDS,** que no Docker local não existia.
- **Economia de créditos:** `skip_final_snapshot`, `backup_retention_period = 0`, nada de NAT Gateway e `terraform destroy` no final (17 recursos destruídos), além de apagar o backend e o bucket.

---

## Questão 4 — Validação e Responsabilidade

**O checklist que eu passava antes de cada `terraform apply`:**

- [ ] Nenhum `aws_iam_*` no código ou no plan
- [ ] Região `us-east-1` nos providers e no backend
- [ ] RDS com `publicly_accessible = false` e `storage_encrypted = true`
- [ ] SG do RDS liberando a 5432 só para o SG da EC2, e não para um bloco de IPs
- [ ] Senha só no `terraform.tfvars`, e `*.tfvars`, `tfplan`, `*.tfstate` e `.env` no `.gitignore`, sempre conferindo com `git status` antes de commitar
- [ ] `terraform fmt`, `terraform validate` e `terraform plan` lidos antes do `apply`
- [ ] Quantidade de recursos no plan fazendo sentido, e nada sendo destruído sem querer. Na correção do SSL, por exemplo, conferi que só a EC2 ia ser recriada e que o RDS não seria tocado

**Como eu validei que estava tudo certo e seguro:** não me contentei com o "Apply complete". Testei o CRUD inteiro pela URL pública, incluindo os casos de erro 400 e 404 (`evidencias/crud-aws.txt`). Consultei o RDS e o Security Group pela AWS CLI para ver a configuração real, e não só o que estava no código. Conferi que o state estava mesmo no S3 (`evidencias/remote-state-s3.txt`). E, quando a API não respondia, entrei na EC2 por SSH e fui investigando com `cloud-init status`, os logs do `user_data` e o `journalctl` até achar a causa.

**E se eu aceitasse o código da IA sem revisar?** O caso do SSL mostra bem o risco. A IA afirmou uma coisa errada com toda a segurança, e só o teste real mostrou o problema. Sem revisar, eu teria uma infraestrutura que "subiu" bonitinha no Terraform, mas com a API fora do ar. Também poderia ter subido senha para o GitHub, tentado criar IAM que o Lab bloqueia, ou deixado o banco aberto para qualquer IP. A IA não conhece o meu ambiente, e quem responde pelo que vai para a nuvem sou eu.

**Como a evolução Git → Docker → Terraform → Modules me preparou para isso:** cada etapa me deu uma forma de conferir o que a IA entrega. Com o Git eu vejo exatamente o que mudou e consigo voltar atrás. Com o Docker eu tenho um ambiente local para testar antes da nuvem, e foi comparando o local com a AWS que eu entendi que o problema era o SSL. Com o Terraform eu tenho o `plan`, que mostra o que vai acontecer antes de acontecer. E os módulos quebram a infra em pedaços pequenos: pedir e validar um módulo por vez é muito mais seguro do que pedir tudo de uma vez.

Também errei no caminho e aprendi com isso. O meu primeiro merge foi fast-forward e não deixou o merge commit no histórico, e alguns commits dos módulos eu fiz direto na `main`, antes de criar a `feature/infra`. Na segunda integração usei `--no-ff` para o workflow ficar registrado direitinho.

Por último, uma coisa que levo dessa prova: subir a máquina é só metade do caminho. A configuração dentro do Linux (systemd e variáveis de ambiente) é onde o deploy acontece de verdade, e é lá que se escondem os bugs que ninguém vê.
