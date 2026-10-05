# Diagnóstico inicial — Callao (PCx016)

Relevado el 2026-10-05.

## Entorno

- Git 2.49.0.windows.1 (`C:\Program Files\Git`)
- Dos `ssh.exe` en el PATH: el de Git (`usr\bin`, OpenSSH 9.9p2) y el de Windows (`System32\OpenSSH`). Git usa el suyo; ambos leen `~/.ssh/config`.
- Servicio `ssh-agent` de Windows: **detenido** (no se puede iniciar sin admin). No lo necesitamos.

## Claves en `~/.ssh`

| Archivo | Comentario de la clave | Huella (SHA256) | ¿Dónde está registrada? |
|---|---|---|---|
| `asimov_ed25519` | cpaez@siempro.gob.ar asimov | `DXANT702…` | a verificar |
| `gitlab_ed25519` | cpaez | `TQNsOFJT…` | a verificar |
| `id_ed25519` | XtnPaez GitHub | `cCbj2Qv8…` | a verificar |
| `id_ed25519_aal` | aal.github@gmail.com | `AcKiQwMA…` | a verificar |
| `id_ed25519_xtnpaez` | cpaez@siempro.gob.ar | `JlBaCD1U…` | a verificar |

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

## Pendiente

- [ ] Correr `scripts/diagnostico.sh` y completar la columna "¿Dónde está registrada?"
- [ ] Inventario de repos locales y sus remotos
- [ ] Definir dónde está la clave de gitmapa
- [ ] Confirmar si `aal` sigue en uso
