# Guía — Callao (PCx016)

Aplicar en orden, en **Git Bash**. Ninguno de estos pasos necesita admin.
Tiempo estimado: 15 minutos. Si algo falla, parar y ver [FAQ](FAQ.md) o volver atrás con el respaldo del paso 0.

---

## 0. Respaldo

```bash
cp -r ~/.ssh ~/.ssh.bak-2026-10-05
cp ~/.gitconfig ~/.gitconfig.bak-2026-10-05
```

Para volver atrás en cualquier momento:
```bash
rm -rf ~/.ssh && cp -r ~/.ssh.bak-2026-10-05 ~/.ssh
cp ~/.gitconfig.bak-2026-10-05 ~/.gitconfig
```

## 1. Traer la última versión de este repo

```bash
cd ~/devstack/www/XtnPaez/git-multicuenta
git pull
```

## 2. Renombrar la clave institucional

La clave que hoy entra a asimov y GitLab se llama `gitlab_ed25519`. Le damos un nombre que diga lo que es:

```bash
mv ~/.ssh/gitlab_ed25519     ~/.ssh/cncps_ed25519
mv ~/.ssh/gitlab_ed25519.pub ~/.ssh/cncps_ed25519.pub
```

## 3. Nuevo `~/.ssh/config`

```bash
cp plantillas/ssh_config ~/.ssh/config
```

Probar:

```bash
ssh -T gitlab-cncps                          # → Welcome to GitLab, @cpaez!
git ls-remote git@asimov:cpaez/efpi.git HEAD # → un hash y HEAD
```

✋ Si alguno falla, no seguir. Si el error es `no such identity: …cncps_ed25519`, falta el paso 2 (ver [FAQ](FAQ.md)). Otro error: volver al respaldo y avisar.

## 4. Migrar los remotos de los repos

Primero simular (no cambia nada, muestra qué haría):

```bash
bash scripts/migrar-remotos.sh
```

Revisar la lista. Si está bien:

```bash
bash scripts/migrar-remotos.sh --aplicar
```

Qué cambia:
- GitHub → `https://<cuenta>@github.com/...` (el usuario en la URL elige la cuenta)
- asimov por HTTPS → `git@asimov:...`
- `gitlab-callao` → `gitlab-cncps`
- Repos de terceros (`externos/`) no se tocan.

## 5. Nuevo `~/.gitconfig`

```bash
cp plantillas/gitconfig ~/.gitconfig
mkdir -p ~/.gitconfig.d
cp plantillas/gitconfig.d/cncps plantillas/gitconfig.d/aal ~/.gitconfig.d/
```

*(`gitmapa` se copia cuando confirmemos su mail.)*

Esto elimina de paso `http.sslverify=false`, el header vacío y los typos.

Comprobar que el administrador de credenciales sigue configurado (viene del config del sistema):

```bash
git config --show-origin --get-all credential.helper   # → ...etc/gitconfig  manager
```

## 6. Verificar todo

```bash
bash scripts/verificar.sh
```

La **primera vez** para cada cuenta de GitHub (XtnPaez y asiaamericalatina) se abre la ventanita de login. Es esperado, una sola vez por cuenta:

- Para **XtnPaez**: "Sign in with your browser" está bien si el navegador tiene abierta esa cuenta.
- Para **asiaamericalatina**: si el navegador tiene abierta la sesión de XtnPaez, **no** uses el navegador (autorizaría la cuenta equivocada). Elegí **Token** y pegá un token personal creado desde la cuenta asiaamericalatina (GitHub → Settings → Developer settings → Personal access tokens), o abrí una ventana de incógnito con esa cuenta.

Resultado esperado: todos ✅, y en "commitea como" el mail correcto para cada repo:

| Remoto | Commitea como |
|---|---|
| asimov / GitLab | cpaez@siempro.gob.ar |
| asiaamericalatina | aal.github@gmail.com |
| XtnPaez y el resto | paez.cristian@gmail.com |

## 7. Limpieza de `~/.ssh`

Las claves que ya no se usan van a una carpeta aparte (no se borran todavía):

```bash
mkdir -p ~/.ssh/_to_delete
mv ~/.ssh/asimov_ed25519* ~/.ssh/id_ed25519* ~/.ssh/config.bak ~/.ssh/known_hosts.old ~/.ssh/_to_delete/
ls ~/.ssh    # debería quedar: _to_delete  cncps_ed25519  cncps_ed25519.pub  config  known_hosts
```

Después de una semana sin problemas: `rm -rf ~/.ssh/_to_delete ~/.ssh.bak-2026-10-05 ~/.gitconfig.bak-2026-10-05`

## 8. Listo

Marcar Callao como ✅ en el README.
