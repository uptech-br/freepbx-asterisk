# FreePBX/Asterisk

Este repositório empacota uma imagem Docker para executar **FreePBX 17** sobre **Asterisk 22**, com foco em operação contínua: a instalação real é movida para um volume persistente em `/data`, o bootstrap é automatizado via entrypoint e o runtime já sobe com regras de rede, ODBC, `fail2ban`, `nftables` e ajustes básicos do Apache.

## O que a imagem entrega

- **PBX**: Asterisk compilado
- **Dashboard**: FreePBX 17
- **Banco externo**: MariaDB
- **Persistência**: estado da instalação em `/data`
- **Integração**:
  - ODBC para `asteriskcdrdb`
  - sSMTP com relay externo
- **Serviços internos**:
  - `dbus`
  - `cron`
  - `asterisk`
  - `fail2ban`
  - `apache2`
- **Segurança embarcada**:
  - regras base de `nftables`
  - jails de `fail2ban` para Asterisk
  - hardening simples do Apache

## Persistência

O projeto depende de um volume montado em `/data`.

```text
/data
├── asterisk/                  # binários, configs, spool, logs e runtime do Asterisk
├── web/                       # arquivos servidos pelo Apache
├── fail2ban/                  # configs, db e logs do Fail2Ban
└── entrypoint-hooks.d/
    ├── nftables.d/            # arquivos .nft aplicados no boot
    └── scripts.d/             # scripts .sh executados no boot
```

Esse layout permite recriar o container sem reinstalar manualmente a PBX, desde que o volume seja mantido.

## Variáveis de ambiente

### Banco de dados

| Variável | Padrão | Uso |
| --- | --- | --- |
| `DBHOST` | `db` | Host do banco |
| `DBROOT_PASSWORD` | `root` | Senha de root do banco |
| `DBNAME` | `asterisk` | Banco principal do FreePBX |
| `DBCDR` | `asteriskcdrdb` | Banco de CDR |
| `DBUSER` | `dev` | Usuário da aplicação |
| `DBPASSWORD` | `1234567890` | Senha da aplicação |

### Rede

| Variável | Uso |
| --- | --- |
| `EXTRA_IPV4` | Adiciona IPv4 extra à interface `ipvlan` detectada |
| `IPV4_GATEWAY` | Substitui a rota padrão IPv4 |
| `EXTRA_IPV6` | Adiciona IPv6 extra à interface `ipvlan` detectada |
| `IPV6_GATEWAY` | Substitui a rota padrão IPv6 |

### SMTP

| Variável | Padrão |
| --- | --- |
| `MAIL_FROM_ADDRESS` | `pbx@uptech.com.br` |
| `MAIL_DOMAIN` | `uptech.com.br` |
| `SMTP_HOST` | sem padrão |
| `SMTP_PORT` | `587` |
| `SMTP_NAME` | sem padrão |
| `SMTP_PASSWORD` | sem padrão |

Se `SMTP_HOST`, `SMTP_NAME` ou `SMTP_PASSWORD` não forem informados, autenticação SMTP ficará incompleta.

### Build args

| Argumento | Padrão | Uso |
| --- | --- | --- |
| `ASTVERSION` | `22` | Versão principal do Asterisk |
| `IONCUBE_ARCH` | `x86-64` | Arquitetura do ionCube loader |
| `TZ` | `America/Recife` | Fuso horário da imagem |

## Requisitos operacionais

- Docker para build e execução da imagem;
- Acesso à internet durante o build para baixar Asterisk e FreePBX;
- Banco MariaDB/MySQL acessível no boot;
- Volume persistente montado em `/data`;
- Capacidade `CAP_NET_ADMIN`, porque o entrypoint aplica `nftables` e pode manipular IPs/rotas.

## Build

Build usando o script do repositório:

```bash
./build.sh
```

Build com argumentos customizados:

```bash
docker build \
  --build-arg ASTVERSION=22 \
  --build-arg IONCUBE_ARCH=x86-64 \
  --build-arg TZ=America/Recife \
  -t freepbx:latest .
```

## Hooks e extensões

O bootstrap procura por customizações em:

- `/data/entrypoint-hooks.d/nftables.d/*.nft`
- `/data/entrypoint-hooks.d/scripts.d/*.sh`

Exemplo de regra extra:

```nft
table inet custom {
  chain input {
    type filter hook input priority 10; policy accept;
    tcp dport 443 accept
  }
}
```

Exemplo de script extra:

```bash
#!/usr/bin/env bash
set -euo pipefail

fwconsole reload
```

## Observações importantes

- O build usa `freepbx-17.0-latest-EDGE`, então o artefato final pode variar ao longo do tempo;
- O pós-boot sempre executa `fwconsole ma upgradeall`, o que pode impactar tempo de inicialização;
- O container pressupõe um ambiente onde `CAP_NET_ADMIN` é aceitável;
- A configuração SMTP é montada por variáveis de ambiente no boot; se o relay exigir outro formato além do previsto em `ssmtp.sh`, ajuste o script;
- As regras base do `nftables` já embutem premissas de rede local, como `10.5.0.0/16` para HTTP.
