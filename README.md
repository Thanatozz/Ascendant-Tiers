# Ascendant Tiers (Desynced Mod Project)

Repository scaffold for a Desynced mod focused on tiered upgrades and stronger progression.

This project is currently in the setup/documentation stage. Gameplay content is not implemented yet.

## Repository Purpose

This repository keeps three clearly separated areas:

- `base-game/`: Extracted data from Desynced `main.zip` for reference only (read-only).
- `mod-reference/`: Extracted `AllTheTiers` mod content for reference only (read-only).
- `mod/`: The only writable area for new mod development.

## Working Rules

- Do not edit files inside `base-game/` or `mod-reference/`.
- Build all new content, scripts, and data for this project inside `mod/`.
- Treat reference folders as study/comparison sources only.

## Current Status

- Repository hygiene initialized (`.gitignore`, README, structure rules).
- No gameplay changes or production mod content added yet.

## Notes

- Reference extracts are intentionally separated from development to reduce accidental edits.
- This layout is designed for maintainable, AI-assisted iteration as the mod grows.
