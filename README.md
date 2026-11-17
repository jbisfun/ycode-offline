# ycode-offline

ycode Lua plugin that turns off the account and online features:

- no automatic sign-in at startup (`%hookf client::authenticate` that never calls `%orig`)
- swallows `client::*`, `collab::*`, `collab_panel::*`, `channel_modal::*`,
  `onboarding::SignIn`/`OpenAccount`, `zed::OpenAccountSettings`, `auto_update::Check`
- hides the sign-in button, user menu/avatar, collab panel button and onboarding banner
- telemetry off, auto-update off, edit predictions provider `none`
- dismisses the upsell/ad banners ("Welcome to Zed AI — Sign In to Try GPT Luna", trial
  ended, edit-prediction upsell, update announcement) via `ycode.kv_set`, and blocks the
  edit-prediction onboarding modal
- hides the account/collab namespaces from the command palette (`ycode.palette_hide`)
- `ycode_offline: undo` (command palette) brings the banners back

Settings go into ycode's in-memory plugin layer (`ycode.settings{}`), above settings.json
and never written to disk.

## Install

    ln -s ~/jbisfun/ycode-offline ~/.config/zed/hooks/ycode-offline

then "ycode: reload hooks". To undo, remove the link and reload. The startup sign-in veto
only takes effect from the next launch.
