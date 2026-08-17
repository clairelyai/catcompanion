# Sprite Production

## Input roles

- Use the clearest full-body side profile as the composition reference.
- Use face close-ups as identity references, not edit targets.
- Use sitting and sleeping photos as pose references.
- Treat every input photo as private local material.

## Shared specification

Repeat these invariants in every generation or edit request:

```text
Asset type: photorealistic macOS desktop-pet sprite
Subject: the same cat shown in all reference images
Identity: preserve exact coat color and markings, eye color, roundness of face,
ears, muzzle, nose, whiskers, body proportions, paws, and tail
Composition: full body, all four paws, and full tail visible; right-facing side
profile; identical scale, camera angle, and canvas framing across the set
Backdrop: transparent, or a perfectly flat removable chroma-key color with no
shadow, gradient, floor, reflection, texture, or lighting variation
Avoid: extra, fused, duplicated, or missing limbs; collars; props; text;
watermarks; altered face; altered coat; cropped paws; cropped tail
```

For chroma key, choose a color absent from the cat. Use bright green for gray, orange, black, or white cats; use magenta for green accessories. Remove the key locally, preserve soft fur edges, and inspect for color fringe.

## Required poses

### sit.png

Create a relaxed upright sitting pose, awake, with front paws visible and tail naturally resting beside the body.

### sleep.png

Create a curled sleeping pose with eyes closed, relaxed ears, and the full silhouette visible.

### jump.png

Create a small right-facing hop at peak height. Bend and tuck both front paws under the chest and both rear paws under the belly. Keep all four paws airborne and individually readable.

### walk-1.png — contact

Place the near front paw forward in contact and the near rear paw backward in contact. Move the opposite pair toward passing positions.

### walk-2.png — passing

Plant the near front leg nearly vertically. Lift the near rear paw completely off the ground and swing it forward under the belly. Plant the far rear paw behind the hip.

### walk-3.png — opposite contact

Reverse frame 1. Put the near front paw backward and the near rear paw forward in contact. Lift or advance the opposite pair.

### walk-4.png — opposite passing

Lift the near front paw and swing it forward. Extend the near rear leg backward as it leaves the ground. Plant the far front leg under the shoulder and swing the far rear paw forward.

## Acceptance checks

- Compare all four walking frames side by side.
- Verify that both rear paws move horizontally across the cycle.
- Verify that each rear paw alternates between planted and airborne.
- Verify that the head and torso do not jump between frames.
- Reject any frame with a different face, coat, body length, scale, or lighting.
- Run `scripts/validate_assets.sh` after background removal.
