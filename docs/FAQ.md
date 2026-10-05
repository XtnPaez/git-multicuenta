# FAQ — problemas frecuentes

Buscá con Ctrl+F el mensaje de error o el síntoma. Cada respuesta tiene: **por qué pasa** y **qué hacer**.

> Los comandos son para **Git Bash**. Donde dice `<alias>` va uno de: `github-xtnpaez`, `github-gitmapa`, `github-aal`, `asimov`, `gitlab-cncps` (ver README).

---

## 🩺 Triage rápido: "no me deja clonar / pushear"

Antes de buscar el error puntual, estos 3 comandos resuelven el 80% de los casos:

```bash
git remote -v                 # 1. ¿La URL es SSH con alias o HTTPS?
ssh -T <alias>                # 2. ¿La clave de ese alias entra al servidor?
ssh -vT <alias> 2>&1 | grep -iE "identity file|offering|accepted|denied"   # 3. ¿Qué clave está probando?
```

- Si la URL empieza con `https://` → ver [Se abre una ventanita de login](#se-abre-una-ventanita-de-login-web).
- Si la URL es `git@github.com:...` (sin alias) → ver [Repository not found](#repository-not-found-pero-el-repo-existe).
- Si `ssh -T` falla → ver [Permission denied (publickey)](#permission-denied-publickey).

---

## Se abre una ventanita de login web

**Por qué:** el repo usa una URL `https://`. Git le pide credenciales al administrador de credenciales de Windows, que abre el login del navegador.

**Qué hacer:** pasar el repo a SSH con el alias de su cuenta.

```bash
git remote set-url origin git@<alias>:<usuario>/<repo>.git
git remote -v    # verificar
```

Ejemplo: `git remote set-url origin git@github-xtnpaez:XtnPaez/git-multicuenta.git`

---

## Permission denied (publickey)

**Por qué:** la clave que usa ese alias no está registrada en esa cuenta del servidor, o el alias apunta a un archivo de clave que no existe en esta máquina.

**Qué hacer:**

1. Ver qué clave usa el alias: `ssh -G <alias> | grep identityfile`
2. Verificar que el archivo existe: `ls -l ~/.ssh/`
3. Ver la clave pública y comprobar que esté cargada en la web del servidor (GitHub → Settings → SSH and GPG keys; Gogs/GitLab → Configuración de usuario → Claves SSH):
   ```bash
   cat ~/.ssh/<clave>.pub
   ```
4. Si no está, pegala ahí con un título que diga la máquina (ej. `Callao - PCx016`).

---

## Repository not found (pero el repo existe)

**Por qué:** típico de varias cuentas en GitHub. Entraste con **otra** cuenta, que no tiene acceso a ese repo. Pasa cuando la URL usa `github.com` directo en vez del alias.

**Qué hacer:**

```bash
ssh -T github-xtnpaez     # debe decir "Hi XtnPaez!"
ssh -T github-gitmapa     # debe decir "Hi gitmapa!"
```

Corregí el remoto para que use el alias de la cuenta dueña del repo (ver [ventanita de login](#se-abre-una-ventanita-de-login-web)).

---

## El commit salió con el nombre o mail equivocado

**Por qué:** el repo está fuera de la carpeta de su cuenta, entonces `includeIf` no aplica y usa la identidad global.

**Qué hacer:**

```bash
git config user.email         # ¿qué mail está usando este repo?
git config --show-origin user.email   # ¿de qué archivo sale?
```

- Si el repo está en la carpeta equivocada, movelo a la correcta.
- Para corregir **el último** commit (solo si todavía no lo pusheaste):
  ```bash
  git commit --amend --reset-author --no-edit
  ```

---

## no matching host key type found. Their offer: ssh-rsa

**Por qué:** el servidor (asimov) usa un algoritmo viejo que OpenSSH moderno desactiva por defecto.

**Qué hacer:** el bloque del alias en `~/.ssh/config` tiene que incluir:

```
HostKeyAlgorithms +ssh-rsa
PubkeyAcceptedAlgorithms +ssh-rsa
```

---

## WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED / Host key verification failed

**Por qué:** el servidor cambió su clave (reinstalación, migración) o la entrada en `known_hosts` está vieja.

**Qué hacer:** confirmá con quien administra el servidor que el cambio es legítimo. Después:

```bash
ssh-keygen -R asimov.cncps.gob.ar            # o el host que corresponda
ssh-keygen -R "[asimov.cncps.gob.ar]:2222"   # si usa puerto no estándar
ssh -T <alias>                               # acepta la clave nueva
```

---

## Connection timed out / Connection refused

**Por qué:**
- **GitHub:** la red bloquea el puerto 22. Nuestros alias ya usan `ssh.github.com` puerto 443, que casi nunca está bloqueado.
- **asimov / GitLab desde la notebook fuera de la oficina:** probablemente solo son accesibles desde la red del CNCPS. *(A confirmar.)*

**Qué hacer:** probá `ssh -T <alias>`. Si es asimov o GitLab y estás fuera de la oficina, conectate a la VPN (si existe) o trabajá desde la oficina.

---

## Me pide la passphrase de la clave cada vez

**Por qué:** la clave tiene passphrase y no hay agente que la recuerde. El `ssh-agent` de Windows necesita admin.

**Qué hacer:** usar el agente de Git Bash, que no necesita admin. Por sesión de terminal:

```bash
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/<clave>
```

---

## SSL certificate problem (al usar HTTPS)

**Por qué:** el servidor institucional usa un certificado que Windows no reconoce.

**Qué hacer:** **no** desactivar la verificación globalmente (`http.sslverify=false` afecta también a GitHub). Lo correcto es usar SSH. Si sí o sí necesitás HTTPS para un servidor puntual, limitalo a ese host:

```bash
git config --global http.https://asimov.cncps.gob.ar/.sslVerify false
```

---

## ¿Dónde clono un repo nuevo y con qué URL?

| Si el repo es de… | Carpeta | URL |
|---|---|---|
| GitHub XtnPaez | `~/devstack/www/XtnPaez/` | `git@github-xtnpaez:XtnPaez/<repo>.git` |
| GitHub gitmapa | *(a definir)* | `git@github-gitmapa:gitmapa/<repo>.git` |
| GitHub AAL | `~/devstack/www/AAL/` | `git@github-aal:<usuario>/<repo>.git` |
| asimov (Gogs) | `~/devstack/www/callao/asimov/` | `git@asimov:<usuario>/<repo>.git` |
| GitLab CNCPS | `~/devstack/www/callao/gitlab/` | `git@gitlab-cncps:<grupo>/<repo>.git` |

Truco: copiá la URL SSH que muestra la web y reemplazá el host (`github.com`, `asimov.cncps.gob.ar`, etc.) por el alias.

---

## ¿Cómo agrego un puesto nuevo o una cuenta nueva?

*(Pendiente: se documenta en `docs/guia-puesto.md` cuando terminemos Callao.)*

---

*Si un problema no está acá, anotalo y se agrega.*
