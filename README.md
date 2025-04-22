# Alfred Ghostty Integration
AppleScript to integrate [Ghostty](https://ghostty.org/) with [Alfred](https://www.alfredapp.com/help/features/terminal/).

## Usage

1. Copy the [script](https://github.com/zeitlings/alfred-ghostty-script/blob/main/GhosttyAlfred.applescript) to your clipboard
2. In Alfred Preferences, navigate to `Features > Terminal > Application → Custom`
3. Paste the script into the text box
4. Optionally configure the script's properties

## Properties

- `open_new` : either <kbd>t</kbd>, <kbd>n</kbd> or <kbd>d</kbd>
  * <kbd>t</kbd> open new tab
  * <kbd>n</kbd> open new window
  * <kbd>d</kbd> open new split
- `run_cmd` : either `true` or `false`
  * `true` paste and run the command
  * `false` paste the command, do not run it
- `reuse_tab` : either `true` or `false` 
- `timeout_seconds`
- `shell_load_delay`
- `switch_delay`

