# Zoom Live Service Feature Implementation

## Overview
This implementation adds a complete Zoom Live Service feature to the MyChurchApp Flutter application. It allows church members to view and join live Zoom services directly within the app on Sundays at 8:00 PM.

## Features Implemented

### 1. **Zoom Service Status Screen** (`ZoomLiveServiceScreen`)
- **Live State**: Shows a prominent "LIVE NOW" red indicator with service details
- **Offline State**: Displays a user-friendly message indicating the next service time
- **Service Information**:
  - Service title
  - Start time
  - Real-time status updates
- **Refresh Capability**: Pull-to-refresh to check latest status
- **Join Options**:
  - Open in-app WebView
  - Open in browser
  - Launch Zoom app directly

### 2. **Zoom WebView Screen** (`ZoomWebViewScreen`)
- **Embedded Zoom Meeting**: Uses `webview_flutter` to display the Zoom meeting inside the app
- **JavaScript Enabled**: Allows Zoom interactivity
- **Controls**:
  - Refresh button
  - Open in Zoom app button
  - Back navigation
- **Error Handling**:
  - Shows user-friendly error messages
  - Retry mechanism
  - Fallback options to external apps

### 3. **Zoom API Service** (`zoom_service.dart`)
- **API Endpoint**: `https://church.innovative.ng/api/zoom/live`
- **Response Handling**:
  - **Live Response**: Returns meeting URL, title, platform, and start time
  - **Offline Response**: Returns message indicating next service time
- **Error Management**: Handles network errors, timeouts (10-second limit), and invalid responses
- **No URL Caching**: Always fetches fresh data from backend

## Architecture

### File Structure
```
lib/
├── service/
│   └── zoom_service.dart          # API service and models
├── screens/
│   ├── ZoomLiveServiceScreen.dart  # Main service status screen
│   └── ZoomWebViewScreen.dart      # WebView for Zoom meeting
└── DashboardScreen.dart            # Updated with Zoom shortcut
```

### Dependencies Added
```yaml
dependencies:
  webview_flutter: ^4.7.0
  http: ^1.2.0  # Already present
  url_launcher: ^6.3.0  # Already present
```

## Platform Configuration

### Android Configuration
**File**: `android/app/src/main/AndroidManifest.xml`

Added Permissions:
- `android.permission.CAMERA` - For video participation
- `android.permission.RECORD_AUDIO` - For audio during meetings
- `android.permission.MODIFY_AUDIO_SETTINGS` - For audio control

### iOS Configuration
**File**: `ios/Runner/Info.plist`

Added Permission Descriptions:
- `NSCameraUsageDescription` - Camera access for Zoom
- `NSMicrophoneUsageDescription` - Already present
- All permissions use user-friendly descriptions

## Navigation & Routing

### Route Registration (MyApp.dart)
```dart
ZoomLiveServiceScreen.routeName = "/zoom_live_service"
ZoomWebViewScreen.routeName = "/zoom_webview"
```

Routes are automatically handled by the `onGenerateRoute` in MyApp.dart

### Home Screen Integration (DashboardScreen.dart)
Added a new menu item:
- Icon: Video Camera
- Title: "Live Zoom Service"
- Description: "Join our live Sunday service on Zoom"
- Always visible (not feature-gated)

## API Response Format

### Live Service Response
```json
{
  "status": "live",
  "data": {
    "title": "SUNDAY NIGHT PRAYER MEETING",
    "platform": "zoom",
    "meeting_url": "https://zoom.us/wc/join/...",
    "start_time": "2025-12-21 20:00:00"
  }
}
```

### Offline Service Response
```json
{
  "status": "offline",
  "message": "Zoom service holds every Sunday by 8:00 PM"
}
```

## UI/UX Components

### Live State UI
- Red "LIVE NOW" badge with pulsing indicator
- Service title in gradient card
- Start time display
- "Join Live Service" button (opens WebView)
- "Open in Browser" button (external)
- Information card with connection tips

### Offline State UI
- Gray offline indicator
- "Service Not Live" title
- Yellow warning card with service schedule
- Disabled "Join" button
- Next service information
- Pull-to-refresh prompt

## Error Handling & Fallback Behavior

### Network Errors
1. Shows error message to user
2. Provides "Try Again" button
3. Network timeout: 10 seconds

### WebView Failures
1. Shows error page in WebView
2. Displays error message
3. Provides "Retry" button
4. "Open in Zoom App" fallback button

### Graceful Degradation
- If WebView fails → Open in Zoom app or browser
- If API fails → Show offline state with retry option
- If Zoom app unavailable → Opens browser instead

## State Management

Uses **FutureBuilder** for:
- Asynchronous API calls
- Loading state display
- Error state handling
- Data display

**Refresh Mechanism**: Pull-to-refresh or manual button
- Rebuilds the FutureBuilder
- Re-fetches data from backend
- No caching of stale data

## Security & Privacy

✅ **No Local Storage**: Meeting URLs are never cached locally
✅ **Fresh Data**: Always fetches current data from backend
✅ **HTTPS Only**: All API calls use HTTPS
✅ **User Control**: Backend completely controls meeting availability
✅ **Permission Scope**: Only camera/audio for actual meeting participation

## Testing Recommendations

### Manual Testing Checklist
- [ ] Verify "Live" state displays correctly when service is active
- [ ] Verify "Offline" state shows proper message
- [ ] Test WebView loading of Zoom meeting
- [ ] Test refresh/retry mechanisms
- [ ] Test opening in browser fallback
- [ ] Test opening in Zoom app
- [ ] Test on both Android and iOS
- [ ] Verify permissions are requested on first use
- [ ] Test network error handling
- [ ] Test timeout scenarios

### API Endpoint Testing
```bash
# Test live endpoint
curl -X GET https://church.innovative.ng/api/zoom/live

# Expected responses documented above
```

## Performance Considerations

- **API Timeout**: 10 seconds (configurable in `zoom_service.dart`)
- **WebView**: Minimal overhead, uses platform WebView
- **Memory**: Proper disposal of WebViewController
- **Bandwidth**: Only fetches data on demand, no background polling

## Future Enhancements

1. **Meeting Recording Access**: Display past recordings
2. **Participant Notifications**: Notify users 5 minutes before service
3. **Chat Integration**: In-app prayer requests during service
4. **Automatic Refresh**: Background refresh to check for live status
5. **Multiple Zoom Meetings**: Support for different meeting times
6. **Analytics**: Track join rates and session duration

## Troubleshooting

### Common Issues

**Issue**: WebView shows blank page
- **Solution**: Check internet connection, ensure HTTPS URL is valid

**Issue**: Camera/Microphone not working in Zoom
- **Solution**: Verify permissions are granted in phone settings

**Issue**: "Open in Zoom App" button doesn't work
- **Solution**: Ensure Zoom app is installed, or use browser fallback

**Issue**: API returns 404
- **Solution**: Check backend endpoint URL and ensure API is deployed

## Code Quality

- **Type Safe**: Full null safety enabled
- **Error Handling**: Comprehensive try-catch blocks
- **User Feedback**: Loading, error, and success states
- **Accessible**: Proper contrast ratios and readable text
- **Responsive**: Works on various screen sizes

## Deployment Checklist

Before deploying to production:

- [ ] Verify API endpoint is correct and live
- [ ] Test on real Android and iOS devices
- [ ] Verify Zoom meeting URLs are valid
- [ ] Check permission requests work on app first launch
- [ ] Test network error scenarios
- [ ] Verify app doesn't crash on bad API responses
- [ ] Test WebView performance with large meetings
- [ ] Verify all UI elements are properly sized for all screen sizes
- [ ] Test on minimum supported Android (API 23+) and iOS (11.0+)
- [ ] Get app store approval for microphone/camera permissions

## Support & Maintenance

### Regular Checks
- Monitor API response times
- Check for WebView plugin updates
- Review user feedback for issues
- Test edge cases regularly

### Backend Integration
- Coordinate with backend team for API changes
- Ensure meeting URLs are always fresh
- Implement rate limiting if needed
- Add logging for debugging

---

**Last Updated**: December 2025
**Feature Status**: ✅ Complete and Ready for Testing
