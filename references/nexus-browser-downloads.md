# Nexus browser downloads

Use this reference for authenticated Nexus manual downloads.

## Reliable sequence

1. Open the canonical Files tab in the authorized browser session.
2. Confirm the visible file name, version, size, description, and variant.
3. Click the file-specific **Manual download**, not a page-level ambiguous control.
4. Verify the dependency dialog names the intended file.
5. Capture the browser `download` event before clicking **Slow download**.
6. Inspect the local download directory and move only the completed archive into staging.
7. Rename it locally with a stable mod/version name and compute SHA-256.

## Large files and unstable browser control

- Browser telemetry or control timeouts do not prove the Nexus download failed.
- If the control session resets, inspect for a completed file or `.crdownload` before retrying.
- Poll a `.crdownload` in short bounded intervals; keep user-visible progress updates under one minute apart.
- A slow-download click may navigate the controlled tab to an official, signed Nexus CDN URL instead of saving. Capture the download event before reloading that same authorized URL. Do not print, persist, or report the signed URL.
- If a large-file event wait times out while `.crdownload` is growing, let the existing download finish. Do not create a duplicate.
- Finalize only tabs created by the automation after all browser work is complete. Do not close unrelated user tabs.

## File identity

- Treat file IDs as ephemeral evidence, not durable documentation.
- Compare the completed archive size with the Files page.
- When the page exposes a VirusTotal hash, require the local SHA-256 to match before staging.
- Preserve the original archive; extract to a separate directory.

## Boundaries

- Never request credentials or copy cookies.
- Never bypass CAPTCHA, timers, premium restrictions, or adult-content gates.
- Never expose account IDs or signed download URLs in reports.
- For a research-only request, do not start downloads.
