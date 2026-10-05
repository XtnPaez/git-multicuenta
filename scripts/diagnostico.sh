#!/usr/bin/env bash
# Diagnóstico de claves SSH: prueba cada clave contra cada servidor,
# ignorando ~/.ssh/config, y lista los repos locales con su remoto.
# Uso (Git Bash):  bash scripts/diagnostico.sh [carpeta_de_repos ...]
# No muestra ni copia claves privadas.

t() {
  ssh -T -F /dev/null -i "$HOME/.ssh/$1" \
    -o IdentitiesOnly=yes -o BatchMode=yes -o ConnectTimeout=8 \
    -o StrictHostKeyChecking=accept-new \
    -o HostKeyAlgorithms=+ssh-rsa -o PubkeyAcceptedAlgorithms=+ssh-rsa \
    "${@:2}" 2>&1 | head -2
}

echo "===== Máquina: $(hostname)  —  $(date '+%Y-%m-%d %H:%M')"
echo

for pub in "$HOME"/.ssh/*.pub; do
  k=$(basename "$pub" .pub)
  [ -f "$HOME/.ssh/$k" ] || continue
  echo "######## $k  ($(ssh-keygen -lf "$pub" | awk '{print $2}'))"
  echo "github:";       t "$k" -p 443 git@ssh.github.com
  echo "asimov:22:";    t "$k" git@asimov.cncps.gob.ar
  echo "asimov:2222:";  t "$k" -p 2222 git@asimov.cncps.gob.ar
  echo "gitlab:";       t "$k" git@repositorio.cncps.gob.ar
  echo
done

echo "===== Repos locales"
dirs=("$@"); [ ${#dirs[@]} -eq 0 ] && dirs=("$HOME/devstack" "$HOME/repos")
for base in "${dirs[@]}"; do
  [ -d "$base" ] || continue
  find "$base" -maxdepth 6 -type d -name .git 2>/dev/null | while read -r d; do
    r=${d%/.git}
    printf '%s  ->  %s\n' "$r" "$(git -C "$r" remote get-url origin 2>/dev/null)"
  done
done
