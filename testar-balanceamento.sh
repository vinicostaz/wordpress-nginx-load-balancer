#!/usr/bin/env sh

set -eu

PORTA="${NGINX_PORT:-80}"
URL="http://localhost:${PORTA}/"

echo "Consultando ${URL} 12 vezes..."
echo

i=1
while [ "$i" -le 12 ]; do
    upstream="$(curl -sS -o /dev/null -D - "$URL" | tr -d '\r' | awk -F ': ' 'tolower($1) == "x-upstream" { print $2; exit }')"

    if [ -z "$upstream" ]; then
        echo "Nao foi recebido o cabecalho X-Upstream. Verifique se os conteineres estao ativos." >&2
        exit 1
    fi

    printf 'Requisicao %02d -> %s\n' "$i" "$upstream"
    i=$((i + 1))
done
