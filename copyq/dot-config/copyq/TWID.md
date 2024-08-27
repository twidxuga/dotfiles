From https://github.com/hluk/CopyQ/issues/1087

1st, unselect 'Autostart' section in CopyQ preferences.
2nd, create a plist file. ~/Library/LaunchAgents/run_copyq.plist (or anyname would be ok)
  - TWID - see included run_copyq.plist

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>EnvironmentVariables</key>
	<dict>
		<key>COPYQ_SETTINGS_PATH</key>
		<string>/Users/myuserid/.config/copyq_plaintext</string>
	</dict>
	<key>Label</key>
	<string>Run.Copyq</string>
	<key>ProgramArguments</key>
	<array>
		<string>/Applications/CopyQ.app/Contents/MacOS/copyq</string>
	</array>
	<key>RunAtLoad</key>
	<true/>
	<key>ServiceIPC</key>
	<false/>
</dict>
</plist>
```

3rd and finally, reboot.
