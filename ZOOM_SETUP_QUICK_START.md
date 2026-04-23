# Zoom Live Service - Quick Setup Guide

## What's Been Implemented

A complete **Zoom Live Service** feature has been added to your Flutter church app, allowing members to view and join live Zoom services directly from within the application.

## Files Added/Modified

### New Files Created:
1. **`lib/service/zoom_service.dart`** - API service for fetching Zoom status
2. **`lib/screens/ZoomLiveServiceScreen.dart`** - Main Zoom service UI (Live/Offline states)
3. **`lib/screens/ZoomWebViewScreen.dart`** - WebView for displaying Zoom meeting

### Modified Files:
1. **`pubspec.yaml`** - Added `webview_flutter: ^4.7.0`
2. **`lib/screens/DashboardScreen.dart`** - Added import and Zoom shortcut to home
3. **`lib/MyApp.dart`** - Added route handlers for Zoom screens
4. **`android/app/src/main/AndroidManifest.xml`** - Added camera/microphone permissions
5. **`ios/Runner/Info.plist`** - Added camera permission description

## How to Use

### 1. Get Dependencies
Run in your project root:
```bash
flutter pub get
```

### 2. Run the App
```bash
flutter run
```

### 3. Navigate to Zoom Service
- Go to Home/Dashboard
- Look for **"Live Zoom Service"** menu item
- Tap to open the Zoom service screen

## Feature Overview

### 🔴 When Service is LIVE (Sunday 8:00 PM)
The screen displays:
- Red "LIVE NOW" indicator
- Service title
- Start time
- **"Join Live Service"** button → Opens Zoom in WebView
- **"Open in Browser"** button → Opens in default browser
- Connection tips

### ⚫ When Service is OFFLINE
The screen displays:
- "Service Not Live" message
- Next service schedule
- "Every Sunday by 8:00 PM" info
- Disabled join button
- Pull-to-refresh to check status

## API Integration

The app fetches data from:
```
GET https://church.innovative.ng/api/zoom/live
```

### Expected Response Format

**When Live:**
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

**When Offline:**
```json
{
  "status": "offline",
  "message": "Zoom service holds every Sunday by 8:00 PM"
}
```

## Permissions

The app now requests:
- **Camera** - For Zoom video calls
- **Microphone** - For Zoom audio
- **Audio Settings** - For volume control during meetings

These are requested automatically when opening Zoom for the first time.

## Testing

### Test the Feature:
1. Run the app: `flutter run`
2. Go to Home → "Live Zoom Service"
3. You'll see either:
   - **Live state** if service is currently active
   - **Offline state** if service is not active
4. Test **Refresh** button (pull down) to reload status
5. Test **Join** button to open WebView
6. Test **Open in Browser** button

### Simulate Different States:
- Modify the `_baseUrl` in `lib/service/zoom_service.dart` to test with a mock endpoint
- Or manually change the service status on your backend

## Troubleshooting

### Issue: "Failed to load Zoom service"
**Solution**: 
- Check internet connection
- Verify API endpoint is accessible
- Check that backend is returning proper JSON

### Issue: Zoom WebView shows blank page
**Solution**:
- Verify the `meeting_url` is a valid Zoom web URL
- Check internet connection
- Try opening in browser instead

### Issue: Camera/Microphone permissions denied
**Solution**:
- Grant permissions in phone Settings → App Permissions
- Some devices require permission requests during app usage

### Issue: Routes not found
**Solution**:
- Run `flutter pub get` again
- Clean build: `flutter clean && flutter pub get`

## Key Features

✅ **Live/Offline States** - Clear indication of service status  
✅ **WebView Integration** - Join meetings directly in app  
✅ **Fallback Options** - Open in browser or Zoom app  
✅ **Error Handling** - Graceful error messages and retries  
✅ **Refresh Capability** - Pull-to-refresh or button refresh  
✅ **Responsive Design** - Works on all screen sizes  
✅ **No URL Caching** - Always fetches fresh data  
✅ **Platform Support** - Android and iOS  

## Configuration Options

### Change API Endpoint
In `lib/service/zoom_service.dart`, line 41:
```dart
static const String _baseUrl = 'https://your-api.com/api/zoom/live';
```

### Change Request Timeout
In `lib/service/zoom_service.dart`, line 55:
```dart
).timeout(
  const Duration(seconds: 10),  // Change this value
  ...
```

### Customize UI Text
All strings are in the screen files and can be customized:
- `lib/screens/ZoomLiveServiceScreen.dart`
- `lib/screens/ZoomWebViewScreen.dart`

## Next Steps

1. **Test on Device**: Build and run on Android/iOS device
2. **Backend Integration**: Ensure your API returns correct response format
3. **Meeting URLs**: Verify Zoom meeting URLs are valid
4. **User Testing**: Get feedback from church members
5. **Analytics**: Consider adding tracking for feature usage

## Documentation

See **`ZOOM_FEATURE_IMPLEMENTATION.md`** for:
- Complete architecture overview
- API response format details
- Platform configuration details
- Future enhancement ideas
- Troubleshooting guide

## Support

If you encounter issues:
1. Check `ZOOM_FEATURE_IMPLEMENTATION.md` documentation
2. Verify all files are created correctly
3. Run `flutter pub get` and `flutter clean`
4. Check your backend API is returning correct data
5. Review Flutter and dart logs for errors

---

**Ready to Deploy!** 🚀

Once tested, you can build and deploy to app stores:
```bash
flutter build apk      # Android
flutter build ios      # iOS
```

For detailed deployment instructions, see your Flutter documentation.
