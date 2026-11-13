# Installing from the build output

Requires Thunderbird 128 or newer, plus `git`, `make`, `zip` and `sed`.

## 1. Build

```sh
git clone --depth 1 https://github.com/BinaryLogicRo/thunderbird-minimizeonclose.git
cd thunderbird-minimizeonclose
make
```

Output: `dist/minimizeonclose.xpi`. The version comes from the `VERSION` file (`MAJOR.MINOR.PATCH`).

## 2. Block update checks

The manifest's `update_url` points to `https://binarylogic.ro/minimizeonclose.json`, so Thunderbird looks for updates to this add-on only there, never on addons.thunderbird.net. No update is offered unless that file is published.

To stop Thunderbird from even attempting the daily check, create `policies.json` in the `distribution` folder of the Thunderbird install folder (for example `~/Applications/thunderbird/distribution/policies.json`; for a system package, `/etc/thunderbird/policies/policies.json`):

```json
{
  "policies": {
    "ExtensionSettings": {
      "minimizeonclose@binarylogic.ro": {
        "updates_disabled": true
      }
    }
  }
}
```

If the file already exists, add the `minimizeonclose@binarylogic.ro` entry to it instead. Restart Thunderbird.

## 3. Install

1. In Thunderbird, open **≡ menu → Add-ons and Themes**.
2. Click the **gear icon → Install Add-on From File…**.
3. Select `dist/minimizeonclose.xpi` and confirm.
