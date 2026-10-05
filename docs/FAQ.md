# FAQ — problemas frecuentes

Buscá con Ctrl+F el mensaje de error o el síntoma. Cada respuesta tiene: **por qué pasa** y **qué hacer**.

> Los comandos son para **Git Bash**. Recordatorio del esquema: **GitHub por HTTPS** con el usuario en la URL; **asimov y GitLab por SSH** con los alias `asimov` y `gitlab-cncps` (ver README).

---

## 🩺 Triage rápido: "no me deja clonar / pushear"

```bash
git remote -v                 # 1. ¿Qué URL tiene el repo?
git config user.email         # 2. ¿Con qué identidad va a commitear?
bash ~/devstack/www/XtnPaez/git-multicuenta/scripts/verificar.sh   # 3. Chequeo de todos los repos
```

Según la URL del paso 1:

| La URL es… | Está… | Ver |
|---|---|---|
| `https://<cuenta>@github.com/...` | ✅ bien | [Repository not found](#repository-not-found-pero-el-repo-existe) si falla |
| `https://github.com/...` (sin usuario) | ⚠️ puede elegir cualquier cuenta | [Repository not found](#repository-not-found-pero-el-repo-existe) |
| `git@github.com:...` o `git@github-xxx:...` | ❌ SSH a GitHub, bloqueado en Callao | [Connection timed out](#connection-timed-out) |
| `git@asimov:...` / `git@gitlab-cncps:...` | ✅ bien | [Permission denied](#permission-denied-publickey) si falla |
| `https://asimov...` / `http://repositorio...` | ⚠️ HTTPS a institucional | correr `scripts/migrar-remotos.sh` |

---

## Se abre una ventanita de login web

**Por qué:** es el administrador de credenciales de Git pidiendo login para una cuenta de GitHub que todavía no guardó en esta máquina.

**Qué hacer:** es **normal la primera vez** por cuenta y por máquina. Logueate **con la cuenta que dice la URL** (`https://XtnPaez@...` → XtnPaez).

⚠️ Si elegís "Sign in with your browser", se autoriza la cuenta que tenga abierta el navegador. Para una cuenta distinta a la del navegador, elegí **Token** (y pegá un token personal creado desde esa cuenta) o usá una ventana de incógnito.

Si la ventanita aparece **todas las veces**, la URL no tiene el usuario: corré `bash scripts/migrar-remotos.sh`.

---

## Me logueé con la cuenta equivocada en la ventanita

**Qué hacer:** borrar la credencial guardada y volver a intentar.

```bash
git credential-manager github list               # cuentas guardadas
git credential-manager github logout <usuario>   # borrar la equivocada
```

Si eso no alcanza: Windows → *Administrador de credenciales* → *Credenciales de Windows* → borrar las entradas `git:https://github.com` y `git:https://<usuario>@github.com`. (No requiere admin.)

---

## Repository not found (pero el repo existe)

**Por qué:** GitHub te autenticó con **otra** cuenta, que no tiene acceso a ese repo. Pasa cuando la URL no tiene el usuario (`https://github.com/...`) y el administrador de credenciales eligió una cuenta cualquiera.

**Qué hacer:** poner en la URL la cuenta que tiene acceso:

```bash
git remote set-url origin https://<cuenta>@github.com/<dueño>/<repo>.git
```

Si la URL ya tenía el usuario correcto: ver [Me logueé con la cuenta equivocada](#me-logueé-con-la-cuenta-equivocada-en-la-ventanita).

---

## Permission denied (publickey)

Solo aplica a **asimov y GitLab** (GitHub no usa SSH).

**Por qué:** la clave de esta máquina (`~/.ssh/cncps_ed25519`) no está cargada en el servidor, o no existe.

**Qué hacer:**

1. Probar: `ssh -T gitlab-cncps` y `git ls-remote git@asimov:cpaez/efpi.git HEAD`
2. Ver que la clave existe: `ls ~/.ssh/cncps_ed25519*`
3. Mostrar la pública y cargarla en la web (asimov → Configuración → Claves SSH; GitLab → Preferences → SSH Keys), con un título que diga la máquina (ej. `Callao - PCx016`):
   ```bash
   cat ~/.ssh/cncps_ed25519.pub
   ```

---

## Connection timed out

**Por qué:**
- **GitHub por SSH:** la red de Callao bloquea SSH hacia GitHub (puertos 22 y 443). Hay que usar HTTPS.
- **asimov / GitLab:** solo son accesibles desde la red del CNCPS (Callao o VPN).

**Qué hacer:**
- GitHub: `bash scripts/migrar-remotos.sh --aplicar` (pasa todo a HTTPS).
- asimov / GitLab: conectate a la VPN de Callao. Sin VPN (Perette, casa) no se puede: trabajá local y pusheá cuando estés conectado.

---

## El commit salió con el nombre o mail equivocado

**Por qué:** la identidad la decide la URL del remoto. Si la URL no matchea ninguna regla de `~/.gitconfig`, usa la global (XtnPaez). También pasa en un repo nuevo **antes** de agregarle el remoto.

**Qué hacer:**

```bash
git remote -v                          # ¿la URL tiene el formato del README?
git config --show-origin user.email    # ¿de qué archivo sale el mail?
```

Para corregir **el último** commit (solo si todavía no lo pusheaste):
```bash
git commit --amend --reset-author --no-edit
```

---

## no matching host key type found. Their offer: ssh-rsa

**Por qué:** asimov usa un algoritmo viejo que OpenSSH moderno desactiva por defecto.

**Qué hacer:** el bloque `Host asimov` de `~/.ssh/config` tiene que incluir `HostKeyAlgorithms +ssh-rsa`. La plantilla ya lo trae: `cp plantillas/ssh_config ~/.ssh/config`.

---

## WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED / Host key verification failed

**Por qué:** el servidor cambió su clave (reinstalación, migración) o la entrada en `known_hosts` está vieja.

**Qué hacer:** confirmá con quien administra el servidor que el cambio es legítimo. Después:

```bash
ssh-keygen -R "[asimov.cncps.gob.ar]:2222"   # asimov
ssh-keygen -R repositorio.cncps.gob.ar       # GitLab
```

y volvé a probar; acepta la clave nueva.

---

## Me pide la passphrase de la clave cada vez

**Por qué:** la clave tiene passphrase y no hay agente que la recuerde (el `ssh-agent` de Windows necesita admin).

**Qué hacer:** usar el agente de Git Bash, que no necesita admin. Por sesión de terminal:

```bash
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/cncps_ed25519
```

---

## SSL certificate problem

**Por qué:** HTTPS contra un servidor institucional con certificado que Windows no reconoce.

**Qué hacer:** usar SSH (`bash scripts/migrar-remotos.sh --aplicar`). **No** poner `http.sslverify=false` global: desactiva la seguridad también para GitHub. Si sí o sí hace falta HTTPS a un servidor puntual:

```bash
git config --global http.https://asimov.cncps.gob.ar/.sslVerify false
```

---

## ¿Dónde clono un repo nuevo y con qué URL?

| Si el repo es de… | Carpeta sugerida | URL |
|---|---|---|
| GitHub XtnPaez | `~/devstack/www/XtnPaez/` | `https://XtnPaez@github.com/XtnPaez/<repo>.git` |
| GitHub asiaamericalatina | `~/devstack/www/AAL/` | `https://asiaamericalatina@github.com/asiaamericalatina/<repo>.git` |
| GitHub gitmapa | `~/devstack/www/perette/` | `https://gitmapa@github.com/gitmapa/<repo>.git` |
| asimov | `~/devstack/www/callao/asimov/` | `git@asimov:cpaez/<repo>.git` |
| GitLab CNCPS | `~/devstack/www/callao/gitlab/` | `git@gitlab-cncps:<grupo>/<repo>.git` |

Truco: copiá la URL que muestra la web y adaptala:
- GitHub: agregá `<cuenta>@` después de `https://`.
- asimov / GitLab: copiá la URL SSH y reemplazá el host por el alias.

---

## ¿Cómo agrego un puesto nuevo o una cuenta nueva?

*(Pendiente: se documenta en la guía genérica de puesto.)*

---

*Si un problema no está acá, anotalo y se agrega.*
