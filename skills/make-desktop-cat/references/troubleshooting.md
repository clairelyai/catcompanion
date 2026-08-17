# Troubleshooting

## Rear legs look frozen

Open all four walking sprites side by side. If the same rear paw touches the same point in every frame, regenerate frames 2–4 with explicit planted/airborne instructions. Code cannot create anatomical rear-leg motion from four nearly identical whole-body images.

## The cat slides instead of walking

Keep the torso, head, scale, canvas, and ground baseline fixed across frames. Change the legs, not the entire image placement. Use the same dimensions for all seven sprites.

## Green or magenta fur fringe

Repeat background removal with a soft matte, despill, and a one-pixel edge contraction. Inspect on both black and white backgrounds. Do not hard-cut fur unless the result is intentionally pixel art.

## Transparent edges look clipped

Regenerate with more padding. Keep whiskers, ear tips, paws, and tail away from the canvas edge.

## Build reports a missing asset

Verify exact lowercase filenames in `Assets/`: `sit.png`, `sleep.png`, `jump.png`, and `walk-1.png` through `walk-4.png`.

## macOS blocks the app

The included builder uses an ad-hoc signature. Control-click the app and choose Open. Wide public distribution without this step requires the publisher's Developer ID certificate and Apple notarization.

## Signing fails inside iCloud or File Provider

Build and sign in a temporary local directory, create the ZIP there, then copy only the ZIP back. File Provider may reattach extended attributes to an unpacked app bundle and invalidate strict signing checks.
