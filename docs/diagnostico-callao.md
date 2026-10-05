# Diagnóstico inicial — Callao (PCx016)

Relevado el 2026-10-05.

## Entorno

- Git 2.49.0.windows.1 (`C:\Program Files\Git`)
- Dos `ssh.exe` en el PATH: el de Git (`usr\bin`, OpenSSH 9.9p2) y el de Windows (`System32\OpenSSH`). Git usa el suyo; ambos leen `~/.ssh/config`.
- Servicio `ssh-agent` de Windows: **detenido** (no se puede iniciar sin admin). No lo necesitamos.

## Claves en `~/.ssh`

| Archivo | Comentario de la clave | Huella (SHA256) | ¿Dónde está registrada? |
|---|---|---|---|
| `asimov_ed25519` | cpaez@siempro.gob.ar asimov | `DXANT702…` | ❌ en ningún servidor (huérfana) |
| `gitlab_ed25519` | cpaez | `TQNsOFJT…` | ✅ GitLab (@cpaez) · ✅ asimov:2222 (a confirmar con ls-remote) |
| `id_ed25519` | XtnPaez GitHub | `cCbj2Qv8…` | ❓ GitHub no testeable desde Callao (timeout) |
| `id_ed25519_aal` | aal.github@gmail.com | `AcKiQwMA…` | ❓ GitHub no testeable desde Callao (timeout) |
| `id_ed25519_xtnpaez` | cpaez@siempro.gob.ar | `JlBaCD1U…` | ❓ GitHub no testeable desde Callao (timeout) |

⚠️ Los nombres de archivo no coinciden con los comentarios (`id_ed25519` dice "XtnPaez GitHub"; `id_ed25519_xtnpaez` dice "siempro"). Se verifica con `scripts/diagnostico.sh`.

## Problemas en `~/.ssh/config`

1. **`github-gitmapa` apunta a `~/.ssh/bowie`, que no existe en esta máquina.** gitmapa no funciona en Callao.
2. **Alias `asimov`** usa `gitlab_ed25519` y puerto 2222 con algoritmos `ssh-rsa` legacy; los bloques `asimov.cncps.gob.ar` usan `asimov_ed25519` y puerto 22. Configuraciones contradictorias.
3. **Dos bloques `Host asimov.cncps.gob.ar` duplicados.** SSH toma el primero, que tiene `User cpaez` (para git debería ser `git`).
4. **`github-aal`**: tercera cuenta de GitHub no documentada. ¿Se sigue usando?

## Problemas en `~/.gitconfig`

| Entrada | Problema | Acción |
|---|---|---|
| `http.sslverify=false` | Desactiva verificación TLS para **todo**, GitHub incluido | Quitar |
| `http.extraheader=Authorization:` | Header vacío, puede romper auth HTTPS | Quitar |
| `user.mail` | Typo, no hace nada (ya existe `user.email`) | Quitar |
| `i18n.commitenconding`, `i18n.logoutputenconding` | Typos, no hacen nada | Corregir o quitar |
| `credential.*.provider=generic` | Restos de acceso HTTPS a asimov/gitlab | Revisar al migrar a SSH |
| Una sola identidad global | Commits institucionales salen con gmail personal | `includeIf` por carpeta |

## Resultado del diagnóstico (2026-10-05)

- **GitHub por SSH no anda desde la red de Callao:** `ssh.github.com:443` da *Connection timed out* con todas las claves. HTTPS sí anda (`git clone https://...` funcionó sin pedir nada).
- **asimov:** el SSH de git es el **puerto 2222**. El puerto 22 es el SSH del sistema (pide password): no sirve para git. La clave que entra es `gitlab_ed25519`, no `asimov_ed25519`.
- **GitLab:** `gitlab_ed25519` entra como `@cpaez` por el puerto 22.
- **`github-gitmapa` → `~/.ssh/bowie`:** casi seguro un error, `bowie` es el nombre de un repo de XtnPaez, no de una clave.

## Repos locales y remotos

| Repo | Remoto actual | Observación |
|---|---|---|
| AAL/asiaamericalatina.org | `git@github-aal:asiaamericalatina/…` | SSH GitHub, no anda en Callao |
| callao/asimov/cod_pos_AR, efpi, pygis_aplicado, SIGfrido, starker | `git@asimov:cpaez/…` | ✅ OK |
| callao/asimov/geall | `https://asimov.cncps.gob.ar/…` | HTTPS, pasar a SSH |
| callao/externos/visualizador_geo | `https://github.com/edeleitha/…` | repo de terceros |
| callao/gitlab/bmw, vizlab | `git@gitlab-callao:ssctyai/siempro/…` | ✅ OK |
| perette/geovista | `https://asimov.cncps.gob.ar/…` | asimov por HTTPS, pasar a SSH |
| perette/pc2web, zonificacion | `https://github.com/XtnPaez/…` | GitHub XtnPaez |
| XtnPaez/afa-dashboard-arg, fiscalizar, git-multicuenta | `https://github.com/XtnPaez/…` | HTTPS |
| XtnPaez/bowie | `https://XtnPaez@github.com/…` | HTTPS con usuario en la URL |
| XtnPaez/UKTester | `git@github.com:XtnPaez/…` | SSH **sin alias**: no anda en Callao |

⚠️ `perette/` mezcla cuentas (asimov y GitHub XtnPaez): la identidad no puede depender solo de la carpeta.

## Pendiente

- [x] Correr `scripts/diagnostico.sh`
- [x] Inventario de repos locales y sus remotos
- [x] Probar GitHub por puerto 22 (también bloqueado) y confirmar asimov con `git ls-remote` (OK)
- [x] ~~Identificar claves de GitHub~~ → no hace falta: GitHub pasa a HTTPS
- [x] `aal` sigue en uso (asiaamericalatina)
- [ ] Definir qué es gitmapa y su identidad
- [ ] Decidir qué hacer con `perette/geovista`, `pc2web` y `zonificacion` (sus remotos ya no existen)

## Resultado de la aplicación (2026-10-05)

Guía aplicada. `scripts/verificar.sh`: **15 OK**, 3 ❌ que son repos cuyo remoto ya no existe (`perette/geovista`, `perette/pc2web`, `perette/zonificacion`). Las copias locales pueden ser el único ejemplar: no borrar sin decidir antes.
