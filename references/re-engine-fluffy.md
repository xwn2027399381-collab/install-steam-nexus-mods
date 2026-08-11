# RE Engine, Fluffy, and REFramework

Use this reference for Capcom RE Engine games and Fluffy Mod Manager.

## Replacement slots and variants

- Record the exact character/costume slot for every appearance mod.
- Treat two mods replacing the same slot as mutually exclusive even when Fluffy can store both.
- An archive may contain several top-level variant folders. Inspect every `modinfo.ini`.
- Treat identical `NameAsBundle` values as a one-of-N selection.
- Treat `addonfor` as an ordered dependency: enable the base first and the addon last.
- Do not copy every archive root into Fluffy when the user selected only one variant.

## Fluffy installation

1. Download the current Fluffy release from its canonical Nexus page.
2. Verify its archive hash and executable inventory.
3. Extract it outside the game directory.
4. Run `Modmanager.exe` with the manager directory as its working directory. A first launch without that working directory may exit without a window or log.
5. Select the exact game entry and verify the detected Steam install path.
6. Place only selected mod folders or supported archives under `Games\<game-key>\Mods`.
7. Refresh the mod list.
8. Enable base mods before addons and record every successful `Installed mod:` message.
9. Never edit `installed.ini`, `ArchiveList.bin`, or manager caches manually.

Use the environment's Windows-automation confirmation rules before first running newly downloaded manager software.

## Fluffy verification

- Require one `installed.ini` section per enabled mod.
- Compare `file=` records with files present under the game directory.
- Hash the last owner of each destination-relative path against the corresponding source under `Games\<game-key>\Mods`.
- Use `scripts/verify-fluffy-install.ps1` for deterministic verification.
- Leave runtime claims unverified until the game launches and the correct outfit/feature is observed.

## Game updates

- Prefer uninstalling all Fluffy mods before a game patch.
- After a patch, re-read game archives before reinstalling.
- If the game patched while mods were enabled, preserve `installed.ini`, verify Steam files if needed, re-read archives, and reinstall deliberately. Do not delete manager state or backups without a rollback plan.

## REFramework

- Check the official REFramework GitHub releases when the Nexus copy is stale. Use an official source only.
- For a normal non-VR installation, install only the documented proxy DLL, commonly `dinput8.dll`, unless the release instructions say otherwise.
- Back up any existing proxy DLL before replacement and do not combine multiple proxy loaders without evidence.
- Place Lua autorun scripts under `reframework\autorun` and their data/fonts under the archive-documented paths.
- Install Direct2D or other optional plugins only when a selected feature requires them; optional rendering layers add compatibility risk.
- Verify the proxy DLL and script files separately from Fluffy's `installed.ini`.

## Save protection

- Locate Steam userdata by app ID and copy the complete app-specific directory before first activation.
- Keep saves outside the game-file rollback set; restoring game files must not overwrite newer saves unless the user explicitly chooses that backup.
