# Nexus browser downloads

Use this reference for authenticated Nexus manual downloads.

## Reliable sequence

1. Open one canonical Files tab per selected mod in the authorized browser session.
2. Keep a page-to-mod mapping and classify every visible file as main, base, addon, alternative, old, optional, or DLC-only.
3. If the user will click downloads, keep each created tab as a handoff. Do not close the pages they still need.
4. Confirm the visible file name, version, size, description, and variant.
5. Click the file-specific **Manual download**, not a page-level ambiguous control.
6. Verify the dependency dialog names the intended file.
7. Capture the browser `download` event before clicking **Slow download** when the browser surface supports it reliably.
8. Inspect the local download directory and move only completed archives into staging.
9. Reconcile every archive to the page-to-mod mapping; presence in Downloads does not mean it was selected for deployment.
10. Rename it locally with a stable mod/version name and compute SHA-256.

## Large files and unstable browser control

- Browser telemetry or control timeouts do not prove the Nexus download failed.
- A missing or timed-out browser download event does not prove the download failed. Local completed-file evidence takes precedence.
- If the control session resets, inspect for a completed file or `.crdownload` before retrying.
- Poll a `.crdownload` in short bounded intervals; keep user-visible progress updates under one minute apart.
- A slow-download click may navigate the controlled tab to an official, signed Nexus CDN URL instead of saving. Capture the download event before reloading that same authorized URL. Do not print, persist, or report the signed URL.
- If a large-file event wait times out while `.crdownload` is growing, let the existing download finish. Do not create a duplicate.
- Finalize only tabs created by the automation after all browser work is complete. Do not close unrelated user tabs.
- When the user requested separate download pages, finalize created tabs as handoffs so they remain available.

## File identity

- Treat file IDs as ephemeral evidence, not durable documentation.
- Compare the completed archive size with the Files page.
- Inventory recent files by modification time after the user says downloads are complete. Detect partial files and duplicate attempts before staging.
- When the page exposes a VirusTotal hash, require the local SHA-256 to match before staging.
- Preserve the original archive; extract to a separate directory.

## Boundaries

- Never request credentials or copy cookies.
- Never bypass CAPTCHA, timers, premium restrictions, or adult-content gates.
- Never expose account IDs or signed download URLs in reports.
- For a research-only request, do not start downloads.
