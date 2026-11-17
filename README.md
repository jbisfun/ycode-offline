# ycode-offline

ycode Lua plugin that turns off the account and online features:

- no automatic sign-in at startup (`%hookf client::authenticate` that never calls `%orig`)
- swallows `client::*`, `collab::*`, `collab_panel::*`, `channel_modal::*`,
  `onboarding::SignIn`/`OpenAccount`, `zed::OpenAccountSettings`, `auto_update::Check`
- hides the sign-in button, user menu/avatar, collab panel button and onboarding banner
- telemetry off, auto-update off, edit predictions provider `none`

Settings go into ycode's in-memory plugin layer (`ycode.settings{}`), above settings.json
and never written to disk.

## Install

    ln -s ~/jbisfun/ycode-offline ~/.config/zed/hooks/ycode-offline

then "ycode: reload hooks". To undo, remove the link and reload. The startup sign-in veto
only takes effect from the next launch.
