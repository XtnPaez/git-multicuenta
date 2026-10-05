#!/usr/bin/env bash
# Verifica cada repo: remoto, identidad con la que va a commitear y si el
# servidor responde (git ls-remote). No modifica nada.
#
# Uso (Git Bash):  bash scripts/verificar.sh [carpeta ...]
# Por defecto recorre ~/devstack/www
# La primera vez que toque cada cuenta de GitHub puede abrirse la ventanita
# de login del administrador de credenciales: es esperado, una sola vez.

dirs=("$@"); [ ${#dirs[@]} -eq 0 ] && dirs=("$HOME/devstack/www")
ok=0; mal=0

for base in "${dirs[@]}"; do
  [ -d "$base" ] || continue
  while read -r d; do
    r=${d%/.git}
    url=$(git -C "$r" config --get remote.origin.url) || continue
    email=$(git -C "$r" config user.email)
    if timeout 30 git -C "$r" ls-remote --heads origin >/dev/null 2>&1; then
      estado="✅"; ok=$((ok+1))
    else
      estado="❌"; mal=$((mal+1))
    fi
    printf '%s %s\n     remoto: %s\n     commitea como: %s\n' "$estado" "${r#$HOME/}" "$url" "$email"
  done < <(find "$base" -maxdepth 6 -type d -name .git 2>/dev/null)
done

echo
echo "Resultado: $ok OK, $mal con problemas."
[ $mal -gt 0 ] && echo "Para los ❌: ver docs/FAQ.md → Triage rápido."
