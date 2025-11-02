# Budget Tracker Flutter - Migration Documentation

## Migration: CrewAI REST API → LangGraph Next.js WebView

**Date:** November 2, 2025
**Status:** ✅ Complete (pending CocoaPods fix for iOS deployment)

---

## Overview

Migrated the "Ask Budget" feature from a custom Flutter chat UI with CrewAI REST API backend to an embedded Next.js web interface powered by LangGraph agents.

---

## Changes Made

### 1. Dependencies

**File:** [pubspec.yaml](pubspec.yaml#L15)

```yaml
dependencies:
  webview_flutter: ^4.10.0  # Added for WebView support
```

- **Package:** `webview_flutter ^4.10.0`
- **Purpose:** Embed Next.js frontend directly in Flutter app
- **Platform Support:** iOS & Android

---

### 2. Screen Rewrite

**File:** [lib/screens/ask_budget_screen.dart](lib/screens/ask_budget_screen.dart)

**Before:**
- Custom chat UI with TextField, message bubbles, and ListView
- Direct REST API calls to CrewAI endpoint
- Manual message state management
- Custom loading states ("Thinking...")

**After:**
- Full-screen WebView embedding Next.js application
- JavaScript enabled (`JavaScriptMode.unrestricted`)
- Loading indicator (purple CircularProgressIndicator)
- No AppBar (fullscreen experience with SafeArea)
- Links open within the same WebView
- Hardcoded URL:
  ```
  http://raspberrypi4.tailad9f80.ts.net:3000/?apiUrl=http://raspberrypi4.tailad9f80.ts.net:8123&assistantId=agent
  ```

**Key Features:**
- ✅ Loading state while page loads
- ✅ Error handling with debug logging
- ✅ Navigation within WebView
- ✅ Platform-agnostic (works on iOS & Android)

---

### 3. Deleted Files

#### `lib/services/question_service.dart` ❌ DELETED
- **Purpose:** REST API client for CrewAI endpoint
- **Endpoint:** `http://raspberrypi4.tailad9f80.ts.net:5001/run`
- **Reason for deletion:** No longer needed with WebView approach

#### `lib/models/genai_question.dart` ❌ DELETED
- **Models:** `GenAIQuestion`, `GenAIResponse`
- **Reason for deletion:** API models no longer needed

---

### 4. Files Preserved

**File:** [lib/screens/home_screen.dart](lib/screens/home_screen.dart#L4)

- ✅ Import of `ask_budget_screen.dart` preserved
- ✅ Navigation to `AskBudgetScreen()` unchanged
- ✅ No updates required (screen API remains the same)

---

## Architecture Changes

### Old Architecture
```
Flutter UI (Custom Chat)
        ↓
  question_service.dart
        ↓
CrewAI REST API (Port 5001)
```

### New Architecture
```
Flutter WebView
        ↓
Next.js Frontend (Port 3000)
        ↓
LangGraph Agent API (Port 8123)
```

---

## Implementation Details

### WebView Configuration

```dart
WebViewController()
  ..setJavaScriptMode(JavaScriptMode.unrestricted)
  ..setNavigationDelegate(
    NavigationDelegate(
      onPageStarted: (url) => setState(() => _isLoading = true),
      onPageFinished: (url) => setState(() => _isLoading = false),
      onWebResourceError: (error) => debugPrint('WebView error: ${error.description}'),
    ),
  )
  ..loadRequest(Uri.parse('http://raspberrypi4.tailad9f80.ts.net:3000/...'))
```

**Settings:**
- JavaScript: Enabled
- Navigation: Within same WebView
- Error handling: Debug logging
- Loading state: Tracked via `onPageStarted`/`onPageFinished`

---

## Testing

### Pre-Deployment
- ✅ Dependencies installed (`flutter pub get`)
- ✅ Code compiles without errors
- ✅ No orphaned imports or references
- ✅ CocoaPods issue resolved
- ✅ iOS App Transport Security configured

### Deployment Status
- ✅ iOS release build tested on iPhone (iOS 26.0.1)
- ✅ Android release build tested on moto g54 5G (Android 15)
- ✅ WebView loading successfully on both platforms
- ✅ Release builds installed locally on both devices

### Known Issues - RESOLVED
- ~~CocoaPods version mismatch on macOS~~ ✅ Fixed
- ~~iOS App Transport Security blocking HTTP~~ ✅ Fixed (added NSAppTransportSecurity exception)
- ~~Android WebView not updated~~ ✅ Fixed (rebuilt APK)

---

## Platform-Specific Configuration

### iOS App Transport Security (ATS)

**Critical Requirement:** iOS blocks non-HTTPS connections by default. To allow HTTP access to the Tailscale domain, the following configuration was added to `ios/Runner/Info.plist`:

```xml
<key>NSAppTransportSecurity</key>
<dict>
  <key>NSExceptionDomains</key>
  <dict>
    <key>raspberrypi4.tailad9f80.ts.net</key>
    <dict>
      <key>NSExceptionAllowsInsecureHTTPLoads</key>
      <true/>
      <key>NSIncludesSubdomains</key>
      <true/>
    </dict>
  </dict>
</dict>
```

**Security Note:** This exception only affects the specific Tailscale domain. All other URLs still require HTTPS.

**File Location:** [ios/Runner/Info.plist](ios/Runner/Info.plist#L48-L60)

### Android Configuration

**Minimum Requirements:**
- Android SDK 20+ (API level 20+)
- WebView component enabled
- Internet permission (automatically handled by Flutter)

**No additional configuration needed** - WebView works out of the box on Android for HTTP connections.

### Building Release Versions

**iOS Release:**
```bash
flutter build ios --release
flutter install -d <device-id>
```
- Automatic code signing with development team
- Provisioning profile must be valid
- Device must be registered in Apple Developer account

**Android Release:**
```bash
flutter build apk --release
flutter install -d <device-id>
```
- Builds a universal APK (works on all architectures)
- No code signing required for local installation
- Can be directly installed via USB debugging

**Build Locations:**
- iOS: `build/ios/iphoneos/Runner.app` (28.2 MB)
- Android: `build/app/outputs/flutter-apk/app-release.apk` (49.9 MB)

---

## Backend Infrastructure

### Next.js Frontend
- **URL:** `http://raspberrypi4.tailad9f80.ts.net:3000`
- **Query Parameters:**
  - `apiUrl`: Backend API endpoint
  - `assistantId`: Agent identifier

### LangGraph API
- **URL:** `http://raspberrypi4.tailad9f80.ts.net:8123`
- **Purpose:** AI agent backend (replacing CrewAI)

### Hosting
- Raspberry Pi 4 (via Tailscale VPN)
- Docker containers
- Accessible remotely via Tailscale network

---

## Future Improvements

### Configuration
- [ ] Move hardcoded URL to environment variables or config file
- [ ] Make `apiUrl` and `assistantId` configurable
- [ ] Add feature flags for WebView vs native implementation

### Error Handling
- [ ] Custom error page for network failures
- [ ] Retry mechanism for failed loads
- [ ] Offline detection and messaging

### Performance
- [ ] WebView caching strategy
- [ ] Preload WebView on app startup
- [ ] Connection timeout handling

### UX Enhancements
- [ ] Pull-to-refresh in WebView
- [ ] Loading skeleton instead of spinner
- [ ] Custom progress bar matching app theme
- [ ] Back button handling (navigate within WebView history)

### Security
- [ ] HTTPS for production
- [ ] Content Security Policy
- [ ] JavaScript bridge security review (if needed)

---

## Rollback Plan

If rollback is needed:

1. **Restore deleted files:**
   ```bash
   git checkout HEAD -- lib/services/question_service.dart
   git checkout HEAD -- lib/models/genai_question.dart
   ```

2. **Revert screen changes:**
   ```bash
   git checkout HEAD -- lib/screens/ask_budget_screen.dart
   ```

3. **Remove WebView dependency:**
   ```bash
   # Edit pubspec.yaml, remove webview_flutter
   flutter pub get
   ```

4. **Ensure CrewAI API is accessible**

---

## Developer Notes

### Git Workflow & Branching Strategy

**IMPORTANT:** This project follows a feature-branch workflow. Always follow these steps:

1. **Create a new branch for each feature:**
   ```bash
   git checkout -b feature/feature-name
   ```

2. **Make commits on the feature branch:**
   ```bash
   git add .
   git commit -m "Descriptive commit message"
   ```

3. **Wait for approval before merging:**
   - DO NOT merge to main immediately
   - Present your work and wait for user approval
   - Only merge when explicitly requested

4. **Merge to main after approval:**
   ```bash
   git checkout main
   git merge feature/feature-name
   git push origin main
   ```

**Benefits:**
- Keeps main branch stable
- Allows review before integration
- Easy rollback if needed
- Clear feature history

**Example:**
```bash
# Starting a new feature
git checkout -b feature/add-dark-mode

# Making changes and commits
git add lib/theme/dark_theme.dart
git commit -m "Add dark theme configuration"

# Wait for user approval...
# User says: "looks good, merge it"

# Merge to main
git checkout main
git merge feature/add-dark-mode
git push origin main
```

---

### WebView Debugging (iOS)
- Enable Safari Web Inspector: Settings → Safari → Advanced → Web Inspector
- Connect device and use Safari → Develop → [Device Name]

### WebView Debugging (Android)
- Enable USB debugging on device
- Chrome → `chrome://inspect` → Find WebView

### Testing Locally
To test the Next.js frontend separately:
```bash
# On development machine
open http://raspberrypi4.tailad9f80.ts.net:3000/?apiUrl=http://raspberrypi4.tailad9f80.ts.net:8123&assistantId=agent
```

---

## Troubleshooting

### Common Issues and Solutions

#### 1. iOS: "The resource could not be loaded because the App Transport Security policy requires the use of a secure connection"

**Problem:** iOS blocks HTTP connections by default.

**Solution:** Ensure `ios/Runner/Info.plist` contains the NSAppTransportSecurity exception:
```bash
# Verify the configuration exists
cat ios/Runner/Info.plist | grep -A 10 "NSAppTransportSecurity"
```

**Fix:** Add the ATS exception as documented in the Platform-Specific Configuration section.

---

#### 2. Android: Old version without WebView shows

**Problem:** Android app not updated with latest changes.

**Solution:** Rebuild and reinstall the APK:
```bash
flutter clean
flutter pub get
flutter build apk --release
flutter install -d <device-id>
```

---

#### 3. CocoaPods installation fails

**Problem:** Ruby version mismatch or CocoaPods not installed.

**Solution:**
```bash
# Reinstall CocoaPods
sudo gem install cocoapods

# Or use Homebrew
brew install cocoapods

# Then install pods
cd ios
pod install
cd ..
```

---

#### 4. WebView shows "Could not connect to the server"

**Problem:** Device not connected to Tailscale network or backend not running.

**Solutions:**
- Ensure device is connected to Tailscale VPN
- Verify backend is running on Raspberry Pi
- Test URL in device browser: `http://raspberrypi4.tailad9f80.ts.net:3000`
- Check network connectivity

---

#### 5. "Provisioning profile has expired" (iOS)

**Problem:** Development certificate expired.

**Solution:**
```bash
# Build with automatic signing
flutter build ios --release
# Don't use --no-codesign flag
```

Ensure your Apple Developer account is active and device is registered.

---

## Contact & Resources

- **Flutter WebView Docs:** https://pub.dev/packages/webview_flutter
- **CocoaPods Installation:** https://guides.cocoapods.org/using/getting-started.html
- **Flutter iOS Setup:** https://flutter.dev/docs/get-started/install/macos

---

## Changelog

### v0.1.1 - 2025-11-02

**Migration: CrewAI → LangGraph WebView**

**Code Changes:**
- ✅ Migrated AskBudgetScreen to WebView implementation
- ✅ Removed CrewAI REST API integration
- ✅ Deleted obsolete service and model files
- ✅ Added webview_flutter ^4.10.0 dependency

**Platform Configuration:**
- ✅ Configured iOS App Transport Security for HTTP access
- ✅ Added NSAppTransportSecurity exception for Tailscale domain
- ✅ Updated CocoaPods dependencies (iOS/macOS)

**Testing & Deployment:**
- ✅ Tested on iPhone (iOS 26.0.1)
- ✅ Tested on moto g54 5G (Android 15)
- ✅ Released iOS build (28.2 MB)
- ✅ Released Android APK (49.9 MB)

**Documentation:**
- ✅ Added comprehensive migration guide (claude.md)
- ✅ Documented Git branching workflow
- ✅ Added platform-specific configuration notes
- ✅ Included troubleshooting steps

**Files Modified:** 17 files changed, 586 insertions(+), 171 deletions(-)

---

**Migration completed by:** Claude (Anthropic)
**Tested by:** User on iOS 26.0.1 & Android 15
**Status:** ✅ Production Ready
