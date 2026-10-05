#!/usr/bin/env bash
# Migra los remotos de todos los repos al esquema git-multicuenta.
#   GitHub          -> https://<cuenta>@github.com/<dueño>/<repo>
#   asimov          -> git@asimov:<usuario>/<repo>
#   GitLab CNCPS    -> git@gitlab-cncps:<grupo>/<repo>
# Repos de terceros (otros dueños de GitHub) no se tocan.
#
# Uso (Git Bash):
#   bash scripts/migrar-remotos.sh                 # simulación: muestra qué cambiaría
#   bash scripts/migrar-remotos.sh --aplicar       # aplica los cambios
#   bash scripts/migrar-remotos.sh [--aplicar] carpeta1 carpeta2 ...
# Por defecto recorre ~/devstack/www

aplicar=0
[ "$1" = "--aplicar" ] && { aplicar=1; shift; }
dirs=("$@"); [ ${#dirs[@]} -eq 0 ] && dirs=("$HOME/devstack/www")

# Dueños de GitHub conocidos -> cuenta con la que se autentica.
cuenta_github() {
  case "$1" in
    XtnPaez|xtnpaez)                     echo "XtnPaez" ;;
    asiaamericalatina)                   echo "asiaamericalatina" ;;
    gitmapa)                             echo "gitmapa" ;;
    *)                                   echo "" ;;
  esac
}

nueva_url() {
  local u="$1" path owner cuenta
  case "$u" in
    git@github-xtnpaez:*)   path=${u#git@github-xtnpaez:} ;;
    git@github-gitmapa:*)   path=${u#git@github-gitmapa:} ;;
    git@github-aal:*)       path=${u#git@github-aal:} ;;
    git@github.com:*)       path=${u#git@github.com:} ;;
    ssh://git@*github.com*/*) path=${u#*github.com*/} ;;
    https://*github.com/*)  path=${u#*github.com/} ;;
    https://asimov.cncps.gob.ar/*) echo "git@asimov:${u#https://asimov.cncps.gob.ar/}"; return ;;
    http*://repositorio.cncps.gob.ar/*) echo "git@gitlab-cncps:${u#*repositorio.cncps.gob.ar/}"; return ;;
    git@gitlab-callao:*)    echo "git@gitlab-cncps:${u#git@gitlab-callao:}"; return ;;
    *) echo "$u"; return ;;
  esac
  # GitHub: decidir cuenta según el dueño del repo
  owner=${path%%/*}
  cuenta=$(cuenta_github "$owner")
  if [ -z "$cuenta" ]; then echo "$u"; return; fi   # terceros: no tocar
  echo "https://${cuenta}@github.com/${path}"
}

cambios=0
for base in "${dirs[@]}"; do
  [ -d "$base" ] || continue
  while read -r d; do
    r=${d%/.git}
    for remote in $(git -C "$r" remote); do
      vieja=$(git -C "$r" config --get "remote.$remote.url")
      nueva=$(nueva_url "$vieja")
      [ "$vieja" = "$nueva" ] && continue
      cambios=$((cambios+1))
      printf '%s [%s]\n   antes: %s\n   ahora: %s\n' "$r" "$remote" "$vieja" "$nueva"
      [ $aplicar -eq 1 ] && git -C "$r" remote set-url "$remote" "$nueva"
    done
  done < <(find "$base" -maxdepth 6 -type d -name .git 2>/dev/null)
done

echo
if [ $aplicar -eq 1 ]; then echo "✅ $cambios remoto(s) actualizado(s)."
else echo "Simulación: $cambios remoto(s) cambiarían. Para aplicar: bash $0 --aplicar"; fi
