-- Latest: https://github.com/zeitlings/alfred-ghostty-script
-- v1.0.0 - 02.01.2025

-- tab : t | window: n | split: d
property open_new : "t"
property reuse_tab : false
property timeout_seconds : 3
property shell_load_delay : 1.0 -- Delay for session to load
property switch_delay : 0.35 -- Delay when switching windows

on isRunning()
	application "Ghostty" is running
end isRunning

on summon()
	tell application "Ghostty" to activate
end summon

on hasWindows()
	if not isRunning() then return false
	tell application "System Events"
		return exists window 1 of process "Ghostty"
	end tell
end hasWindows

on waitForWindow(timeout_s)
	set end_time to (current date) + timeout_s
	repeat until hasWindows() or ((current date) > end_time)
		delay 0.05
	end repeat
	return hasWindows()
end waitForWindow

on handleWindow(just_activated)
	if just_activated then
		return
	end if
	set has_windows to hasWindows()
	set needs_window to not has_windows
	set override_reuse to (reuse_tab and not has_windows)
	tell application "System Events"
		if needs_window or override_reuse then
			keystroke "n" using command down -- New window
			return
		end if
		if not reuse_tab then
			if open_new is "d" and has_windows then
				keystroke "d" using command down -- New split right
			else
				keystroke open_new using command down -- New window or tab
			end if
		end if
	end tell
end handleWindow

on send(a_command, just_activated)
	if not just_activated then
		delay switch_delay -- We might be switching to an existing window
	end if
	set had_windows to hasWindows()
	handleWindow(just_activated)
	
	-- Only wait for session to load if:
	-- 1. We just activated Ghostty, or
	-- 2. We created a new window/tab/split (i.e., not reusing), or
	-- 3. There was no window to reuse (had_windows was false)
	if just_activated or not reuse_tab or (reuse_tab and not had_windows) then
		delay shell_load_delay
	end if
	if not waitForWindow(1) then -- Additional fail-safe
		display dialog "Failed to verify window exists"
		return
	end if
	tell application "System Events"
		keystroke a_command
		keystroke return
	end tell
end send

on alfred_script(query)
	set just_activated to not isRunning()
	summon()
	if just_activated then
		if not waitForWindow(timeout_seconds) then
			display dialog "Failed to create initial window"
			return
		end if
	end if
	send(query, just_activated)
end alfred_script