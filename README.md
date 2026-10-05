# git-multicuenta

Configuración y documentación para trabajar con varias cuentas de Git desde los tres puestos de trabajo (Callao, Perette y notebook), **sin permisos de administrador**.

> ⚠️ Este repo **nunca** contiene claves privadas. Solo plantillas, documentación y scripts. Las claves se generan en cada máquina y no salen de ahí.

> 🆘 **¿Algo no anda?** Empezá por [docs/FAQ.md](docs/FAQ.md).

## Cuentas

| Cuenta | Servidor | Cómo se conecta | URL de los remotos | Commitea como |
|---|---|---|---|---|
| XtnPaez | GitHub | HTTPS | `https://XtnPaez@github.com/XtnPaez/<repo>.git` | XtnPaez · paez.cristian@gmail.com |
| asiaamericalatina | GitHub | HTTPS | `https://asiaamericalatina@github.com/asiaamericalatina/<repo>.git` | asiaamericalatina · aal.github@gmail.com |
| gitmapa | GitHub | HTTPS | `https://gitmapa@github.com/gitmapa/<repo>.git` | *(pendiente)* |
| cpaez | asimov (Gogs) | SSH, puerto 2222 | `git@asimov:cpaez/<repo>.git` | cpaez · cpaez@siempro.gob.ar |
| @cpaez | GitLab CNCPS | SSH | `git@gitlab-cncps:<grupo>/<repo>.git` | cpaez · cpaez@siempro.gob.ar |

## Cómo funciona

1. **GitHub va por HTTPS, con el usuario en la URL.** La red de Callao bloquea SSH hacia GitHub (puertos 22 y 443). HTTPS anda en cualquier red. El administrador de credenciales de Git guarda un login por cuenta: la ventanita aparece **una vez por cuenta y por máquina**, y nunca más.
2. **asimov y GitLab van por SSH**, con una sola clave por máquina (`~/.ssh/cncps_ed25519`) y alias en `~/.ssh/config`. No hace falta `ssh-agent` (que requiere admin en Windows).
3. **La identidad de cada commit la decide la URL del remoto**, no la carpeta (`includeIf "hasconfig:remote.*.url:..."` en `~/.gitconfig`, Git 2.36+). Las carpetas se organizan como uno quiera; `perette/` puede mezclar cuentas sin problema.

## Carpetas

Todas bajo `~/devstack/www/` (`C:\Users\cpaez\devstack\www\`):

| Carpeta | Contenido |
|---|---|
| `XtnPaez/` | repos personales de GitHub XtnPaez |
| `AAL/` | repos de asiaamericalatina |
| `callao/asimov/` | repos de asimov |
| `callao/gitlab/` | repos del GitLab institucional |
| `callao/externos/` | repos de terceros (solo lectura, no se migran) |
| `perette/` | proyectos de Perette (mezcla asimov y GitHub) |

## Accesibilidad por puesto

| Puesto | GitHub | asimov / GitLab |
|---|---|---|
| Callao | ✅ HTTPS | ✅ red interna |
| Notebook con VPN de Callao | ✅ HTTPS | ✅ (a confirmar) |
| Notebook / Perette sin VPN | ✅ HTTPS | ❌ no alcanzables |

## Estructura del repo

```
README.md                  ← esto
docs/
  FAQ.md                   ← problemas frecuentes: buscar acá primero
  guia-callao.md           ← paso a paso para Callao
  diagnostico-callao.md    ← estado inicial de Callao y problemas encontrados
plantillas/
  ssh_config               ← va a ~/.ssh/config
  gitconfig                ← va a ~/.gitconfig
  gitconfig.d/             ← identidades; van a ~/.gitconfig.d/
scripts/
  diagnostico.sh           ← prueba qué clave abre qué servidor y lista repos
  migrar-remotos.sh        ← pasa los remotos al esquema (simula por defecto)
  verificar.sh             ← chequea remoto, identidad y conexión de cada repo
```

Próximamente: guías de notebook y Perette, script `gclone`.

## Estado

| Puesto | Estado |
|---|---|
| Callao | ✅ aplicado 2026-10-05 · 15/15 repos vivos OK ([guía](docs/guia-callao.md)) |
| Notebook | ⏳ pendiente |
| Perette | ⏳ pendiente |
