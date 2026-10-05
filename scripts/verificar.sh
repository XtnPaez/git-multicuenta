#!/usr/bin/env bash
# Verifica cada repo: remoto, identidad con la que va a commitear y si el
# servidor responde (git ls-remote). No modifica nada.
#
# Uso (Git Bash):  bash scripts/verificar.sh [carpeta ...]
# Por defecto recorre ~/devstack/www
# La primera vez que toque cada cuenta de GitHub puede abrirse la ventanita
# de login del administrador de credenciales: es esperado, una sola vez.

dirs=("$@"); [ ${#dirs[@]} -eq 0 ] && dirs=("$HOME/devstack/www")
ok=0; avi=0; mal=0

for base in "${dirs[@]}"; do
  [ -d "$base" ] || continue
  while read -r d; do
    r=${d%/.git}
    url=$(git -C "$r" config --get remote.origin.url) || continue
    email=$(git -C "$r" config user.email)
    nota=""
    if heads=$(timeout 30 git -C "$r" ls-remote --heads origin 2>/dev/null); then
      rama=$(git -C "$r" symbolic-ref --short -q HEAD)
      up=$(git -C "$r" config --get "branch.$rama.merge")   # ej. refs/heads/master
      if [ -z "$heads" ]; then
        estado="⚠️ "; nota="el repo del servidor está vacío (falta el primer push)"; avi=$((avi+1))
      elif [ -n "$up" ] && ! grep -q "[[:space:]]$up\$" <<<"$heads"; then
        estado="⚠️ "; nota="la rama '${up#refs/heads/}' no existe en el servidor"; avi=$((avi+1))
      else
        estado="✅"; ok=$((ok+1))
      fi
    else
      estado="❌"; nota="el servidor no responde o el repo no existe"; mal=$((mal+1))
    fi
    printf '%s %s\n     remoto: %s\n     commitea como: %s\n' "$estado" "${r#$HOME/}" "$url" "$email"
    [ -n "$nota" ] && printf '     ⮑ %s\n' "$nota"
  done < <(find "$base" -maxdepth 6 -type d -name .git 2>/dev/null)
done

echo
echo "Resultado: $ok OK, $avi con avisos, $mal con problemas."
[ $((avi+mal)) -gt 0 ] && echo "Para los ⚠️ y ❌: ver docs/FAQ.md."
