## Verdict: safe to use. No malware and no data access were found. It is fairly reliable, with a few caveats below.

The files were only read; nothing was installed or run. The whole extension is about 130 lines of JavaScript plus JSON, and every line was read.

### Security

**No malicious or suspicious code:**
- **No network:** nothing calls `fetch`, opens sockets, or loads remote scripts.
- **No email access:** it never touches messages, accounts, contacts, storage or preferences.
- **No hidden code:** there is no `eval`, obfuscation, encoded payload, or hidden or unusual characters.
- **Clean icon:** [icon.png](../src/icon.png) is a plain 1000-byte PNG with nothing appended after its end marker. Its only metadata is an Adobe ImageReady tag from 2019.
- **Safe build script:** the [Makefile](../Makefile) only zips files. It downloads nothing.
- **Clean git repo:** no custom hooks and no leftover hidden objects.
- **Add-on code unchanged since the fork:** `background.js`, `experiment.js`, `experiment.json` and `icon.png` are identical to the original repository's release `v2.0.3.0`. This fork changes only the manifest metadata, the build and the documentation.

**What deserves attention is how much access it has, not what the code does:**

1. **It runs with full Thunderbird privileges.** It asks for no normal permissions, but it uses an "Experiment" API ([experiment.js](../src/experiment.js)). That code runs unsandboxed inside Thunderbird and could in principle read anything there. The current code only replaces the main window's close behaviour ([experiment.js:29-38](../src/experiment.js#L29-L38)), so it is harmless. But any *future version* gets the same full access.

2. **Only binarylogic.ro can supply updates.** The add-on has its own ID, `minimizeonclose@binarylogic.ro`, and its `update_url` is `https://binarylogic.ro/minimizeonclose.json` ([manifest.json:5-6](../src/manifest.json#L5-L6)). Thunderbird therefore never asks addons.thunderbird.net for updates, so nobody can push code by uploading an add-on under this ID there. Whoever controls that URL, however, can push an update with full privileges: keep the domain secure and do not publish that file unless an update is intended. To stop update checks entirely, see [INSTALL.md](INSTALL.md).

### Reliability

The logic in [background.js](../src/background.js) is simple. Only main mail windows (type `"normal"`) are affected; compose and message windows close normally. Edge cases found:

- **Quitting still works.** File → Quit doesn't fire the window's close event, so it isn't blocked. Disabling or removing the add-on puts normal closing back ([experiment.js:50-57](../src/experiment.js#L50-L57)).
- **It sometimes fails to minimize. The fallback is harmless:** the window either closes normally or won't close.
  - Closed windows are never removed from its list (it doesn't listen for `windows.onRemoved`). If a main window closes some other way, it can lose count, and closing the last window then actually closes Thunderbird.
  - There's a small startup race between [background.js:35](../src/background.js#L35) and [background.js:36-39](../src/background.js#L36-L39). A window could be registered twice, which would break its close override.
  - Errors in the close handler are caught by nothing. If one happens, the window just won't close, and you can still quit from the menu.
- **Linux/Wayland caveat:** some Wayland setups don't report whether a window is minimized, and some, like plain GNOME, have no taskbar. There the window may minimize again when you try to close it while minimized, or seem to disappear. Try it on your desktop first.
- **Version range:** Thunderbird 128 or newer, with no upper limit ([manifest.json:7-8](../src/manifest.json#L7-L8)). Experiment APIs can break on Thunderbird updates, more likely on the monthly release channel than on ESR. If that happens, the window simply closes as usual.
- **Install only one copy.** If the original add-on and this fork are both installed, they patch the same window, the original close function gets lost, and the window may never close.

### Recommended usage
1. Build and install the add-on as described in [INSTALL.md](INSTALL.md).
2. Before installing any future version, re-check the diff of [experiment.js](../src/experiment.js), since that file has the full access.
