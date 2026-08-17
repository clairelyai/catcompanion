# Privacy and Publishing

## Private by default

Keep these local and untracked:

- original HEIC, JPEG, PNG, RAW, and video references
- generated sitting, sleeping, walking, and jumping sprites
- app bundles and ZIP files that contain the sprites
- Apple signing identities, certificates, profiles, and notarization credentials
- home-directory paths, usernames, local configuration, logs, and caches

The macOS template is offline. Do not add networking, analytics, accounts, cloud storage, automatic uploads, or telemetry.

## Public-safe contents

Publish only:

- `SKILL.md` and agent metadata
- generic Swift/AppKit template source
- build, validation, and privacy scripts
- prompts and documentation that contain no private examples
- license and repository-level instructions

## Before every push

1. Run `git status -sb` and inspect every new file.
2. Run `bash skills/make-desktop-cat/scripts/privacy_check.sh .`.
3. Inspect staged content with `git diff --cached --stat` and `git diff --cached`.
4. Confirm no photo, sprite, `.app`, ZIP, credential, signing identity, or absolute home path is staged.
5. State whether the repository is Public or Private. Do not describe a Private repository as publicly downloadable.

## Rights

Require the user to own or have permission to use every input image. Do not include third-party pet photography, copyrighted character art, celebrity pets, or another person's private photos without authorization.
