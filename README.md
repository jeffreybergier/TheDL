# TheDL
iOS and macOS Client with Matching Server Applications

## Development & Debugging

### iOS Simulator Debugging
To launch the application in the simulator and attach the debugger simultaneously, use the following command on the Mavericks VM:

```bash
# Launch and wait for debugger
xcrun simctl launch -w A8441971-559A-4FF5-ABD8-4D2C2B4219E0 com.kumasan.thedl.ios & xcrun lldb -n TheDL -waitfor
```

*   **UDID:** `A8441971-559A-4FF5-ABD8-4D2C2B4219E0` (iPhone 4s)
*   **Bundle ID:** `com.kumasan.thedl.ios`
*   **Process Name:** `TheDL`
