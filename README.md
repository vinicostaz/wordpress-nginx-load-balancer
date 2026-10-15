# WordPress com Nginx Load Balancer

Ambiente Docker com três instâncias do WordPress, um balanceador de carga Nginx
e um banco de dados MySQL compartilhado.

## Arquitetura

```text
                         +--> wordpress1 --+
usuario --> nginx :80 ---+--> wordpress2 --+--> mysql
                         +--> wordpress3 --+
```

O Nginx recebe todas as requisições e as distribui em round-robin entre as três
instâncias. Os WordPress compartilham o mesmo banco e o mesmo diretório de
arquivos, fazendo com que todos apresentem o mesmo conteúdo.

## Tecnologias e imagens

- Docker e Docker Compose;
- `nginx:1.19.0`;
- `wordpress:5.4.2-php7.2-apache`;
- `mysql:5.7`.

> As versões foram mantidas para atender aos requisitos da atividade acadêmica.
> Para produção, utilize versões atualmente suportadas e credenciais seguras.

## Serviços

| Serviço | Função | Acesso pelo host |
| --- | --- | --- |
| `nginx` | Balanceador de carga e proxy reverso | Porta 80 |
| `wordpress1` | Primeira instância do WordPress | Somente pelo Nginx |
| `wordpress2` | Segunda instância do WordPress | Somente pelo Nginx |
| `wordpress3` | Terceira instância do WordPress | Somente pelo Nginx |
| `mysql` | Banco compartilhado | Somente pelos WordPress |

## Redes e persistência

- `frontend`: conecta o Nginx aos três WordPress;
- `backend`: rede interna que conecta os WordPress ao MySQL;
- `wordpress_data`: pasta local compartilhada com `/var/www/html`;
- `mysql_data`: volume Docker que mantém os dados do banco.

Somente o Nginx publica uma porta. O MySQL e os WordPress não ficam diretamente
expostos à máquina hospedeira.

## Pré-requisitos

- Docker Engine;
- Docker Compose v2;
- `curl` para executar o teste de balanceamento.

Confira a instalação:

```bash
docker --version
docker compose version
```

## Como executar

Clone o repositório e entre na pasta:

```bash
git clone https://github.com/vinicostaz/wordpress-nginx-load-balancer.git
cd wordpress-nginx-load-balancer
```

Crie o arquivo local de configuração:

```bash
cp .env.example .env
```

Antes de continuar, edite `.env` e substitua as senhas de exemplo. Depois,
inicie os cinco contêineres:

```bash
docker compose up -d
```

Confira o estado dos serviços:

```bash
docker compose ps
```

Acesse <http://localhost> e conclua a instalação inicial do WordPress. Essa
configuração será usada pelas três instâncias.

Se a porta 80 já estiver ocupada, altere `NGINX_PORT` no arquivo `.env`, por
exemplo:

```dotenv
NGINX_PORT=8080
```

Nesse caso, acesse <http://localhost:8080>.

## Testando o balanceamento

Execute:

```bash
./testar-balanceamento.sh
```

O script realiza 12 requisições e mostra o endereço que respondeu a cada uma:

```text
Requisicao 01 -> 172.20.0.3:80
Requisicao 02 -> 172.20.0.4:80
Requisicao 03 -> 172.20.0.5:80
```

Também é possível conferir manualmente:

```bash
curl -I http://localhost/
```

O cabeçalho `X-Upstream` identifica a instância selecionada pelo Nginx.

## Comandos úteis

Exibir os logs:

```bash
docker compose logs -f
```

Parar e remover os contêineres, preservando os dados:

```bash
docker compose down
```

Reiniciar os serviços:

```bash
docker compose restart
```

Apagar também o volume do banco:

```bash
docker compose down -v
```

O último comando remove permanentemente os dados armazenados no MySQL.

## Estrutura do projeto

```text
.
|-- .env.example
|-- .gitignore
|-- README.md
|-- docker-compose.yml
|-- nginx.conf
|-- testar-balanceamento.sh
`-- wordpress_data/
    `-- .gitkeep
```

## Como funciona

1. O navegador envia uma requisição para o Nginx.
2. O Nginx escolhe uma das três instâncias WordPress em round-robin.
3. A instância acessa o banco MySQL pela rede interna.
4. A resposta retorna ao navegador por meio do Nginx.

As verificações de saúde impedem que os serviços dependentes sejam iniciados
antes de o banco e as instâncias necessárias estarem disponíveis.
