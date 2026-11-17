-- ycode-offline: turn off ycode/Zed's account and online features.
--
-- * never signs in automatically at startup (vetoes the `client::authenticate` hook point)
-- * swallows sign-in, account, collaboration/channel/call and update-check actions
-- * hides the sign-in button, user menu/avatar, collab panel button, onboarding banner
-- * turns off telemetry, auto-update and the zed.dev edit-prediction provider
--
-- Settings are applied as an in-memory layer above settings.json (nothing is written to
-- disk); remove or disable the extension and "ycode: reload hooks" to undo everything.

local blocked = 0

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
