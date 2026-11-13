## Verdict: safe to use. No malware and no data access were found. It is fairly reliable, with a few caveats below.

The files were only read; nothing was installed or run. The whole extension is about 130 lines of JavaScript plus JSON, and every line was read.

### Security

**No malicious or suspicious code:**
- **No network:** nothing calls `fetch`, opens sockets, or loads remote scripts.
- **No email access:** it never touches messages, accounts, contacts, storage or preferences.
- **No hidden code:** there is no `eval`, obfuscation, encoded payload, or hidden or unusual characters.
- **Clean icon:** [icon.png](../src/icon.png) is a plain 1000-byte PNG with nothing appended after its end marker. Its only metadata is an Adobe ImageReady tag from 2019.
- **Safe build script:** the [Makefile](../Makefile) only zips files. It downloads nothing.
- **Clean git repo:** no custom hooks, no leftover hidden objects, and five small commits by one author.
- **Same code as upstream:** your `main` (`cb8bd7b`) is identical to upstream `main` and its release tag `v2.0.3.0`.

**What deserves attention is how much access it has, not what the code does:**

1. **It runs with full Thunderbird privileges.** It asks for no normal permissions, but it uses an "Experiment" API ([experiment.js](../src/experiment.js)). That code runs unsandboxed inside Thunderbird and could in principle read anything there. The current code only replaces the main window's close behaviour ([experiment.js:29-38](../src/experiment.js#L29-L38)), so it is harmless. But any *future version* gets the same full access.

2. **Updates could replace the code you audited.** Your fork keeps the original add-on ID, `minimizeonclose@rsjtdrjgfuzkfg.com` ([manifest.json:5](../src/manifest.json#L5)). Thunderbird looks for updates by ID on addons.thunderbird.net. So either installing from that store, or installing your own build with the same ID, can silently swap in a new upstream release you haven't reviewed. To keep only the code you audited, do one of these:
   - Turn off automatic updates for this add-on (Add-ons Manager → the add-on → "Allow automatic updates: Off").
   - Change the ID in your fork, for example to `minimizeonclose@binarylogic.ro`.

### Reliability

The logic in [background.js](../src/background.js) is simple. Only main mail windows (type `"normal"`) are affected; compose and message windows close normally. Edge cases found:

- **Quitting still works.** File → Quit doesn't fire the window's close event, so it isn't blocked. Disabling or removing the add-on puts normal closing back ([experiment.js:50-57](../src/experiment.js#L50-L57)).
- **It sometimes fails to minimize. The fallback is harmless:** the window either closes normally or won't close.
  - Closed windows are never removed from its list (it doesn't listen for `windows.onRemoved`). If a main window closes some other way, it can lose count, and closing the last window then actually closes Thunderbird.
  - There's a small startup race between [background.js:35](../src/background.js#L35) and [background.js:36-39](../src/background.js#L36-L39). A window could be registered twice, which would break its close override.
  - Errors in the close handler are caught by nothing. If one happens, the window just won't close, and you can still quit from the menu.
- **Linux/Wayland caveat:** some Wayland setups don't report whether a window is minimized, and some, like plain GNOME, have no taskbar. There the window may minimize again when you try to close it while minimized, or seem to disappear. Try it on your desktop first.
- **Version range:** it is limited to Thunderbird 128 to 153 ([manifest.json:6-7](../src/manifest.json#L6-L7)). Experiment APIs can break on Thunderbird updates, so stay on ESR as the README advises. Avoid the "unsupported" build.
- **Install only one copy.** If the original and a renamed fork are both installed, they patch the same window, the original close function gets lost, and the window may never close.
- **`make` will produce a broken package in your fork right now.** The version comes from `git describe --match='v*'`, and your fork has no tags, so the manifest version would be empty and the add-on wouldn't install. Fix it with:
  ```
  git fetch https://github.com/rsjtdrjgfuzkfg/thunderbird-minimizeonclose.git --tags
  ```
  Or set the version by hand.

### Recommended usage
1. Fetch the tags and build with `make` from your fork.
2. Change the add-on ID, or turn off automatic updates for it.
3. Before installing any future version, re-check the diff of [experiment.js](../src/experiment.js), since that file has the full access.
