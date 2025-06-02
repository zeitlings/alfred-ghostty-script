-- AlfredGhostty Script v1.4.0
-- Control Ghostty terminal via Alfred with enhanced error handling and clarity

-- Configuration constants
property NEW_TAB : "t" -- Open new tab
property NEW_WINDOW : "n" -- Open new window
property NEW_SPLIT : "d" -- Open new split
property QUICK_TERMINAL : "qt" -- Open quick terminal
property OPEN_MODE : NEW_TAB -- Default open mode
property RUN_COMMAND : true -- Auto-run pasted commands
property REUSE_TAB : false -- Reuse existing tab if true
property WINDOW_TIMEOUT : 3 -- Seconds to wait for window
property SHELL_LOAD_DELAY : 0.2 -- Delay for shell to load
property SWITCH_DELAY : 0.2 -- Delay for window switching
property LOG_FILE : "/tmp/alfred_ghostty/debug.log" -- Debug log path
property ENABLE_LOGGING : true -- Toggle debug logging

-- Check if Ghostty is running
on isGhosttyRunning()
	tell application "System Events" to return (application process "Ghostty" exists)
end isGhosttyRunning

-- Activate Ghostty
on activateGhostty()
	try
		tell application "Ghostty" to activate
		return true
	on error errMsg
		logError("activateGhostty", "Failed to activate Ghostty: " & errMsg)
		return false
	end try
end activateGhostty

-- Check if Ghostty has open windows
on hasGhosttyWindows()
	if not isGhosttyRunning() then return false
	tell application "System Events"
		return (count of windows of process "Ghostty") > 0
	end tell
end hasGhosttyWindows

-- Wait for a Ghostty window to appear
on waitForGhosttyWindow(timeoutSeconds)
	set endTime to (current date) + timeoutSeconds
	repeat while (current date) < endTime
		if hasGhosttyWindows() then return true
		delay 0.05
	end repeat
	return false
end waitForGhosttyWindow

-- Log messages to debug file
on logError(prefix, message)
	if not ENABLE_LOGGING then return
	try
		set logMessage to "[" & (current date) & "] " & prefix & ": " & message & "\n"
		do shell script "mkdir -p /tmp/alfred_ghostty"
		write logMessage to file LOG_FILE starting at eof
	on error errMsg
		-- Silent fail to avoid log-related crashes
	end try
end logError

-- Clean up temporary files
on cleanupTempFile(filePath)
	try
		do shell script "rm -f " & quoted form of filePath
	on error errMsg
		logError("cleanupTempFile", "Failed to remove " & filePath & ": " & errMsg)
	end try
end cleanupTempFile

-- Send command to Ghostty
on sendCommandToGhostty(commandText, isNewlyActivated)
	if commandText is "" then
		logError("sendCommandToGhostty", "Empty command received")
		return false
	end if
	
	if not isNewlyActivated then delay SWITCH_DELAY
	set hadWindows to hasGhosttyWindows()
	createNewGhosttyContext(isNewlyActivated, hadWindows)
	
	-- Wait for shell if new session or no prior windows
	if isNewlyActivated or not REUSE_TAB or (REUSE_TAB and not hadWindows) then
		delay SHELL_LOAD_DELAY
	end if
	
	if not waitForGhosttyWindow(1) then
		logError("sendCommandToGhostty", "No Ghostty window found")
		display dialog "Failed to verify Ghostty window exists" buttons {"OK"} default button "OK"
		return false
	end if
	
	-- Direct input instead of clipboard
	tell application "System Events"
		tell process "Ghostty"
			repeat with char in characters of commandText
				keystroke char
			end repeat
			if RUN_COMMAND then
				keystroke return
			end if
		end tell
	end tell
	return true
end sendCommandToGhostty

-- Create new tab, window, or split based on mode
on createNewGhosttyContext(isNewlyActivated, hadWindows)
	if isNewlyActivated then return
	
	set needsNewWindow to not hadWindows
	set overrideReuse to (REUSE_TAB and not hadWindows)
	
	tell application "System Events"
		if needsNewWindow or overrideReuse then
			keystroke "n" using command down -- New window
			return
		end if
		if not REUSE_TAB then
			if OPEN_MODE is NEW_SPLIT and hadWindows then
				keystroke "d" using command down -- New split
			else
				keystroke OPEN_MODE using command down -- New tab or window
			end if
		end if
	end tell
end createNewGhosttyContext

-- Send command to Quick Terminal
on sendToQuickTerminal(commandText, needsActivation)
	if commandText is "" then
		logError("sendToQuickTerminal", "Empty command received")
		return false
	end if
	
	if needsActivation then
		if not activateGhostty() then return false
	end if
	
	tell application "System Events"
		tell process "Ghostty"
			set viewMenu to menu 1 of menu bar item "View" of menu bar 1
			if exists menu item "Quick Terminal" of viewMenu then
				click menu item "Quick Terminal" of viewMenu
			else
				logError("sendToQuickTerminal", "Quick Terminal menu item not found")
				return false
			end if
			repeat with char in characters of commandText
				keystroke char
			end repeat
			if RUN_COMMAND then
				keystroke return
			end if
		end tell
	end tell
	return true
end sendToQuickTerminal

-- Main Alfred entry point
on alfred_script(query)
	if query is missing value or query is "" then
		logError("alfred_script", "No query provided")
		display dialog "No command provided" buttons {"OK"} default button "OK"
		return
	end if
	
	if OPEN_MODE is QUICK_TERMINAL then
		sendToQuickTerminal(query, not isGhosttyRunning())
	else
		set isNewlyActivated to not isGhosttyRunning()
		if not activateGhostty() then
			display dialog "Failed to activate Ghostty" buttons {"OK"} default button "OK"
			return
		end if
		if isNewlyActivated and not waitForGhosttyWindow(WINDOW_TIMEOUT) then
			logError("alfred_script", "Failed to create initial window")
			display dialog "Failed to create initial Ghostty window" buttons {"OK"} default button "OK"
			return
		end if
		sendCommandToGhostty(query, isNewlyActivated)
	end if
end alfred_script
