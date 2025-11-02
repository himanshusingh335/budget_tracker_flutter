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

### Deployment Status
- 🔄 iOS deployment blocked by CocoaPods issue (user fixing)
- ⏳ Pending iOS device testing
- ⏳ Pending Android device testing

### Known Issues
- CocoaPods version mismatch on macOS (requires reinstall)

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

## Contact & Resources

- **Flutter WebView Docs:** https://pub.dev/packages/webview_flutter
- **CocoaPods Installation:** https://guides.cocoapods.org/using/getting-started.html
- **Flutter iOS Setup:** https://flutter.dev/docs/get-started/install/macos

---

## Changelog

### v0.1.1 - 2025-11-02
- ✅ Migrated AskBudgetScreen to WebView
- ✅ Removed CrewAI REST API integration
- ✅ Deleted obsolete service and model files
- ✅ Added webview_flutter dependency

---

**Migration completed by:** Claude (Anthropic)
**Reviewed by:** Pending user testing
