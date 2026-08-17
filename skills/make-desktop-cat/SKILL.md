---
name: make-desktop-cat
description: Create a private, offline macOS desktop-pet app from a user's own cat photos, including transparent sitting, sleeping, four-phase walking, and jumping sprites; bilingual English/Traditional Chinese controls; build, signing, packaging, and privacy checks. Use when a user asks to put their cat on their Mac desktop, make a clickable or animated desktop companion, improve a cat walk cycle, add petting/sleeping/jumping/work/bath behaviors, or package the result as a macOS app without publishing personal photos.
---

# Make Desktop Cat

Create an offline macOS AppKit desktop companion from one pet's reference photos. Keep all photos and generated sprites private unless the user explicitly authorizes publication and confirms ownership.

## Workflow

1. Confirm the target is macOS 13 or later.
2. Ask for 6–10 clear photos of the same cat:
   - front face and both side profiles
   - full standing body with all paws and tail visible
   - sitting and sleeping poses
   - coat markings, eye color, ears, paws, and tail detail
   - optionally, a short side-view walking video
3. Ask for the pet's name, private output folder, desired behaviors, and language. Confirm that the user owns or has permission to use the photos.
4. Create a private project with:

   ```bash
   bash scripts/new_project.sh --output <project-directory>
   ```

5. Read [references/sprite-production.md](references/sprite-production.md), then use the available image-generation capability with the supplied reference photos to create exactly these transparent PNG files in `<project-directory>/Assets/`:

   ```text
   sit.png
   sleep.png
   jump.png
   walk-1.png
   walk-2.png
   walk-3.png
   walk-4.png
   ```

   Never substitute a stock, generic, differently colored, or differently marked animal. If image generation is unavailable, stop and explain that the user must enable it or provide the seven transparent PNG files manually.

6. Show the sitting, sleeping, jumping, and walking sprites to the user for identity and anatomy review. Regenerate any frame with the wrong coat, face, tail, body shape, background, or limb count.

7. Validate every sprite before building:

   ```bash
   bash scripts/validate_assets.sh <project-directory>/Assets
   ```

8. Build and package the app:

   ```bash
   bash scripts/build_app.sh \
     --project <project-directory> \
     --app-name "<Pet Name> Companion" \
     --bundle-id "com.example.<pet-name>"
   ```

9. Launch the extracted app and test sitting, four-leg walking, jumping, sleeping, petting, dragging, Work, Bath, language switching, display-edge reversal, and Call Cat Back.
10. Run the privacy check before any commit, upload, or handoff:

   ```bash
   bash scripts/privacy_check.sh <repository-or-project-directory>
   ```

11. Report the exact `.app` and ZIP paths, explain the first-launch Control-click → Open step, and summarize which behaviors were tested.

## Sprite Rules

- Preserve one consistent identity, body scale, lighting direction, camera angle, and right-facing side profile.
- Make all four walking phases anatomically distinct. The rear paws must change both horizontal position and ground contact; do not animate only the front legs.
- Use a natural four-beat feline gait: contact, passing, opposite contact, opposite passing.
- Keep the complete tail and all four paws inside the canvas with generous transparent padding.
- Reject extra, fused, duplicated, or missing limbs.
- Use `jump.png` for a small airborne hop with both front paws and both rear paws visibly tucked.
- Do not use a person's hands, home interior, text, watermark, floor, cast shadow, or contact shadow in sprites.

## Privacy Boundary

Read [references/privacy-and-publishing.md](references/privacy-and-publishing.md) before publishing anything.

- Treat original photos, generated sprites, app bundles containing sprites, and signing identities as private.
- Keep `Photos/`, `Assets/*.png`, `build/`, `output/`, `.app`, and `.zip` files out of public git history.
- Publish only the Skill, source template, scripts, and documentation by default.
- Do not claim a private repository is publicly downloadable.
- Never add analytics, accounts, uploads, or network access to the generated app.

## Troubleshooting

Read [references/troubleshooting.md](references/troubleshooting.md) for green fringes, frozen rear legs, sprite jitter, Gatekeeper, signing, and File Provider issues.

## Resources

- `scripts/new_project.sh`: copy the reusable macOS project template.
- `scripts/validate_assets.sh`: validate PNG type, dimensions, alpha, and unique walk frames.
- `scripts/build_app.sh`: compile, ad-hoc sign, verify, and ZIP the app.
- `scripts/privacy_check.sh`: detect common private-photo, sprite, path, and credential leaks.
- `assets/macos-template/`: offline Swift/AppKit application template with no bundled pet images.
