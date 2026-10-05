# git-multicuenta

Configuración y documentación para trabajar con varias cuentas de Git desde los tres puestos de trabajo (Callao, Perette y notebook), **sin permisos de administrador**.

> ⚠️ Este repo **nunca** contiene claves privadas. Solo plantillas, documentación y scripts. Las claves se generan en cada máquina y no salen de ahí.

## Cuentas

| Alias SSH | Servidor | Tipo | Usuario / cuenta | Carpeta local |
|---|---|---|---|---|
| `github-xtnpaez` | github.com (vía `ssh.github.com:443`) | GitHub | XtnPaez | `~/repos/xtnpaez/` |
| `github-gitmapa` | github.com (vía `ssh.github.com:443`) | GitHub | gitmapa | `~/repos/gitmapa/` |
| `asimov` | asimov.cncps.gob.ar | Gogs institucional | cpaez | `~/repos/asimov/` |
| `gitlab-cncps` | repositorio.cncps.gob.ar | GitLab institucional | cpaez | `~/repos/gitlab/` |

*(Pendiente de confirmar: cuenta `aal`, puertos de asimov y gitlab, carpetas finales.)*

## Cómo funciona

1. **Una clave por cuenta y por máquina.** Si se pierde la notebook, se revocan solo sus claves.
2. **`~/.ssh/config` con un alias por cuenta.** Cada alias está atado a su clave con `IdentitiesOnly yes`, así SSH no prueba claves equivocadas. No hace falta `ssh-agent` (que requiere admin en Windows).
3. **Los remotos usan el alias, no el host real.**
   `git@github-gitmapa:gitmapa/repo.git` en lugar de `git@github.com:gitmapa/repo.git`.
4. **Una carpeta por cuenta + `includeIf` en `~/.gitconfig`.** Cada carpeta firma los commits con el nombre y mail correctos automáticamente.

## Estructura del repo

```
README.md              ← esto
docs/
  diagnostico-callao.md  ← estado inicial de Callao y problemas encontrados
scripts/
  diagnostico.sh         ← prueba qué clave abre qué servidor
```

Próximamente: plantillas de `config` y `.gitconfig`, guías por puesto, script `gclone`.

## Estado

| Puesto | Estado |
|---|---|
| Callao | 🔍 diagnóstico en curso |
| Notebook | ⏳ pendiente |
| Perette | ⏳ pendiente (se aplica con la guía) |
