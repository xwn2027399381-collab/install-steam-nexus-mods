# Clair Obscur: Expedition 33 reference

Use this reference only for this game. Re-check current Nexus pages and the local Steam manifest before acting; IDs and compatibility can change.

## Known Windows/Steam layout

- Steam app ID observed: `1903340`
- Game root example: `D:\Steam\steamapps\common\Expedition 33`
- Standard pak mods: `<game>\Sandfall\Content\Paks\~mods`
- DML loader: `<game>\Sandfall\Content\Paks\dml`
- LogicMods: `<game>\Sandfall\Content\Paks\LogicMods`
- ClairObscurFix Steam/Epic archive: extract its `Sandfall` tree into the game root; expected files include `ClairObscurFix.asi`, `ClairObscurFix.ini`, and `dsound.dll` under `Sandfall\Binaries\Win64`.

## Verified selections from 2026-07-25

Treat these as historical evidence, not permanent latest-file IDs.

| Feature | Nexus mod | Selected file ID | Variant |
|---|---:|---:|---|
| AP cost | 813 | 3488 | AP Reduced 1 |
| Critical damage | 817 | 3491 | +250%, game patch 1.5.6 |
| Experience | 59 | 253 | Faster Leveling x2 |
| Weapon upgrades | 153 | 518 | Cost 0, not Half |
| Lumina cost | 814 | 3494 | 50% reduction |
| Fast travel | 690 | 2936 | BaseSpeed |
| ClairObscurFix | 24 | 2513 | Steam/Epic 0.0.15 |
| Minimap | 383 | 2406 | 2.2.4 |
| DML | 226 | 2408 | 0.8.5 |
| Chinese enhanced descriptions | 702 | 2944 | Simplified Chinese 1.5.1.1 |
| Place level indicator | 200 | 1143 | Simplified/Traditional Chinese |
| Dodge/parry | 28 | 2328 | x2 easier |
| Upgrade materials | 31 | 77 | More Upgrade Materials |

## Important conflict and variant lessons

- Chinese Enhanced Descriptions already contains the enhanced-description functionality. Do not also install the English Enhanced Descriptions mod.
- Place Name Level Indicator file `1230` is Korean. The Simplified/Traditional Chinese file observed was `1143`.
- AP, critical damage, weapon cost, Lumina cost, and dodge/parry pages expose mutually exclusive variants. Install one variant from each page.
- Compare packed data domains when possible. In the observed set, AP, critical damage, experience, weapon-cost, Lumina-cost, difficulty-window, and loot changes used different data assets, but packed assets still require cautious runtime testing.

## Loader notes

- DML extracts as a `dml` folder directly under `Paks`.
- Minimap requires a loader. With DML, place its three files in `LogicMods` and activate at the main menu with:

  `dml add minimapfx`

- Fast Travel's author documents UE4SS and says no setup is needed under UE4SS. The archive is a LogicMod. Using DML as a shared lightweight alternative may require:

  `dml add FastTravel`

  Treat DML loading of Fast Travel as runtime-uncertain until observed. If DML returns `Invalid Class`, do not install UE4SS alongside it automatically; investigate or switch loader stacks deliberately.

- ClairObscurFix uses an ASI loader through `dsound.dll`. Check for existing proxy DLLs and loader combinations before installation.

## Observed archive shapes

- Standard data mods usually contain a `.pak/.ucas/.utoc` triad and belong in `~mods`.
- Enhanced Descriptions Chinese may be a standalone `.pak`.
- DML contains `dml_core*` and `dml*` files inside a `dml` folder.
- Minimap contains `MinimapFx.pak`, `MinimapFx.ucas`, and `MinimapFx.utoc`.
- Fast Travel BaseSpeed contains a game-root-relative `Sandfall\Content\Paks\LogicMods` tree.

## First-launch handoff

- Ask the user to choose Story difficulty for a fast narrative playthrough if no settings file exists.
- Enter DML activation commands only after DML is visible and the console opens.
- Record whether Minimap and Fast Travel were merely installed or actually activated and observed.
