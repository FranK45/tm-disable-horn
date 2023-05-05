bool HornDisabled = false;
bool HornDefaultBypass = false;
bool Disable_Notification = false;
bool inGame = true;

/** Called every frame. `dt` is the delta time (milliseconds since last frame).
*/


void SetHornsDisabled() {
    try {
        cast<CTrackManiaNetworkServerInfo>(cast<CGameManiaPlanet>(GetApp()).Network.ServerInfo).DisableHorns = true;
        HornDisabled = true;
		if (S_ShowNotificationsHorn && Disable_Notification == false)
            Notify("Disabled horns.");
    } catch {
        NotifyWarning("Exception while disabling horns: " + getExceptionInfo());
    }
}

void SetHornsEnabled() {
    try {
        cast<CTrackManiaNetworkServerInfo>(cast<CGameManiaPlanet>(GetApp()).Network.ServerInfo).DisableHorns = false;
		HornDisabled = false;
        if (S_ShowNotificationsHorn)
            Notify("Enabled horns.");
    } catch {
        NotifyWarning("Exception while enabling horns: " + getExceptionInfo());
    }
}

void Notify(const string &in msg) {
    UI::ShowNotification(Meta::ExecutingPlugin().Name, msg);
    trace("Notified: " + msg);
}

void NotifyError(const string &in msg) {
    warn(msg);
    UI::ShowNotification(Meta::ExecutingPlugin().Name + ": Error", msg, vec4(.9, .3, .1, .3), 5000);
}

void NotifyWarning(const string &in msg) {
    warn(msg);
    UI::ShowNotification(Meta::ExecutingPlugin().Name + ": Warning", msg, vec4(.9, .6, .2, .3), 5000);
}

void NotifyInfo(const string &in msg) {
    trace("[INFO] " + msg);
    UI::ShowNotification(Meta::ExecutingPlugin().Name, msg, vec4(.1, .5, .9, .3), 5000);
}

/** Called whenever a key is pressed on the keyboard. See the documentation for the [`VirtualKey` enum](https://openplanet.dev/docs/api/global/VirtualKey). */
UI::InputBlocking OnKeyPress(bool down, VirtualKey key) {
    if (down && key == S_ShortcutKey)
		if(HornDisabled == false) {
			SetHornsDisabled();
			HornDefaultBypass = false;
			if (S_ShowNotificationsHorn){
				Notify("Horn Bypass Deactivated");
			}
		} else {
			SetHornsEnabled();
			HornDefaultBypass = true;
			if (S_ShowNotificationsHorn){
				Notify("Horn Bypass Activated");
			}
		}	
    return UI::InputBlocking::DoNothing;
}

void Main()
{
	while (true){
		// Check for connection to server. If true check if horns need to be disabled.
		try {
			if(cast<CTrackManiaNetworkServerInfo>(cast<CGameManiaPlanet>(GetApp()).Network.ServerInfo).ServerName != ""){
				sleep(1000); //Let server some time to connect
				if(S_DisableHorns && cast<CTrackManiaNetworkServerInfo>(cast<CGameManiaPlanet>(GetApp()).Network.ServerInfo).DisableHorns == false && HornDefaultBypass == false) {
					Disable_Notification = true; // Bypass notifications because server reupdates .DisableHorns frequently
					sleep(20);
					startnew(SetHornsDisabled);
					sleep(100);
					Disable_Notification = false;
				}
			}
		} catch {
			NotifyWarning("Exception while enabling horns: " + getExceptionInfo());
		}

		sleep(1000);
	}
}