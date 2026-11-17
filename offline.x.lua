-- ycode-offline: turn off ycode/Zed's account and online features.
--
-- * never signs in automatically at startup (vetoes the `client::authenticate` hook point)
-- * swallows sign-in, account, collaboration/channel/call and update-check actions
-- * hides the sign-in button, user menu/avatar, collab panel button, onboarding banner
-- * turns off telemetry, auto-update and the zed.dev edit-prediction provider
-- * dismisses the upsell banners ("Welcome to Zed AI. Sign In to Try ...", trial ended,
--   edit-prediction upsell, update announcement) and blocks the predict onboarding modal
-- * removes all of the above from the command palette
--
-- Settings are applied as an in-memory layer above settings.json (nothing is written to
-- disk); remove the extension and "ycode: reload hooks" to undo. Banner dismissals are
-- stored in the app database, like clicking "dismiss", and stay after removal.

local blocked = 0

-- Keys of Zed's "Dismissable" banners (crates/*: `impl Dismissable`).
local ADS = {
    "dismissed-trial-upsell",                 -- agent panel: Welcome to Zed AI / Sign In to Try
    "dismissed-trial-end-upsell",             -- agent panel: trial ended
    "dismissed-edit-predict-upsell",          -- edit prediction upsell
    "free-plan-edit-predictions-ended-notice",
    "delta_announcement_dismissed",           -- auto-update announcement
}

-- Account/online namespaces: swallowed below and hidden from the command palette.
local NAMESPACES = { "client", "collab", "collab_panel", "channel_modal", "zed_predict_onboarding" }

local function block(self)
    blocked = blocked + 1
    ycode.log("ycode-offline: blocked " .. self.name)
end

%ctor
    ycode.settings{
        title_bar = {
            show_sign_in = false,
            show_user_menu = false,
            show_user_picture = false,
            show_onboarding_banner = false,
        },
        collaboration_panel = { button = false },
        telemetry = { diagnostics = false, metrics = false },
        auto_update = false,
        edit_predictions = { provider = "none" },
    }
    for _, key in ipairs(ADS) do
        ycode.kv_set(key, "1")
    end
    ycode.palette_hide(table.unpack(NAMESPACES))
    ycode.log("ycode-offline: active")
end

%hook client
- *
    block(self)
end
%end

-- Automatic sign-in at startup: don't call %orig. Defined after `client::*` so it
-- runs first (the most recently defined hook wraps the others).
%hookf client::authenticate(args)
    ycode.log("ycode-offline: skipped automatic sign-in")
end

%hook collab
- *
    block(self)
end
%end

%hook collab_panel
- *
    block(self)
end
%end

%hook channel_modal
- *
    block(self)
end
%end

%hook onboarding
- SignIn
    block(self)
end
- OpenAccount
    block(self)
end
%end

%hook zed
- OpenAccountSettings
    block(self)
end
%end

%hook auto_update
- Check
    block(self)
end
%end

%hook zed_predict_onboarding
- *
    block(self)
end
%end
