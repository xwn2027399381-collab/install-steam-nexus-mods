# UE4SS and Unreal pak installs

Read this reference when a selected mod uses UE4SS, a proxy DLL, or Unreal pak containers.

## UE4SS release selection

1. Resolve the game executable directory, not merely the game root.
2. Inventory `dwmapi.dll`, `xinput1_3.dll`, `dinput8.dll`, `dsound.dll`, `winmm.dll`, existing `ue4ss` directories, and other loaders.
3. Use the exact release or experimental commit required by the mod author. Resolve it from the canonical UE4SS project and verify the final asset filename after redirects.
4. Preserve the original loader archive, record SHA-256, and inspect it offline before deployment.
5. Treat DLLs and proxy loaders as software. Follow the user's installation authorization and the environment's confirmation rules.

Do not substitute a stable release for an author-required experimental build. Do not install a second proxy loader to fix the first one.

## Layout and activation

- Derive the destination from the loader archive. Common layouts include a proxy DLL beside the game executable plus `ue4ss/UE4SS.dll` and `ue4ss/Mods`, but older releases differ.
- Install script mods into the Mods directory used by that exact build. Do not maintain both `Mods` and `ue4ss/Mods` speculatively.
- Inspect `mods.txt`, `mods.json`, `enabled.txt`, or author instructions to determine activation. A copied folder is not necessarily active.
- Add only selected mods to the controlling activation file. Preserve built-in entries and their order.
- Set an engine-version override only when the mod author or reliable game evidence establishes it. Make the change in staging, then deploy and hash-verify the configured file.

## Unreal pak compatibility

- Follow the author's documented destination. Keep `.pak/.ucas/.utoc` sets complete.
- Compare internal destination paths when possible. Prefer `UnrealPak -List`; use `scripts/inspect-unreal-pak-assets.ps1` only as a readable-index fallback.
- Treat packed assets that cannot be listed as `uncertain`.
- A pak replacing a core data table or blueprint can be incompatible even when its filename is unique and its malware scan is clean.
- If the mod was tested only on an older game patch, hold it back when it replaces a core asset and no current compatibility report exists.
- Do not deploy DLC-specific packages when Steam shows the DLC is absent. Preserve them in staging with an explicit exclusion reason.

## Verification and rollback

- Recheck that the game is stopped immediately before writing.
- Fail closed when a planned destination appeared after preflight; do not overwrite it silently.
- Hash every deployed proxy, loader configuration, script entry point, and pak against staging.
- Report installed, activated, and runtime-verified as separate states.
- Record exact loader, mod-folder, pak, backup, and rollback paths. Do not delete newly installed files during rollback unless the user requests rollback.
