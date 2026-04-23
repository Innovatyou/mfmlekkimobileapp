# InitPage Setup Error - Troubleshooting Guide

## Problem
App splash screens load fine, then shows login screen with error: **"Unfortunately, we could not complete setup at the moment, please check your internet connection"** when clicking retry.

## Root Causes (Fixed)

### 1. ❌ No Timeout Configuration (NOW FIXED)
**Problem**: Dio requests had no timeout settings, causing requests to hang indefinitely if backend was slow or unreachable.

**Fix Applied**:
```dart
// In Utility.dart getDio() method
dio.options.connectTimeout = Duration(seconds: 30);
dio.options.receiveTimeout = Duration(seconds: 30);
dio.options.sendTimeout = Duration(seconds: 30);
```

**Impact**: Requests will now fail after 30 seconds with clear timeout errors instead of hanging.

### 2. ❌ Poor Error Logging (NOW FIXED)
**Problem**: Generic `print(exception)` made debugging impossible.

**Fix Applied**:
```dart
// In DashboardModel.dart fetchItems() method
- Enhanced logging with categorized error messages
- Added DioException-specific handling
- Clear diagnostic messages for different failure types
```

**New Log Output Examples**:
```
[DashboardModel] Starting fetchItems...
[DashboardModel] User email: user@example.com
[DashboardModel] Making request to https://church.innovative.ng/initapp
[DashboardModel] DioException - Type: DioExceptionType.connectionTimeout
[DashboardModel] CAUSE: Connection timeout - backend server took too long to respond
[DashboardModel] CHECK: Is https://church.innovative.ng/ accessible?
```

---

## How to Diagnose the Issue

### Step 1: Check Logcat/Console Output
When the error occurs, look for logs starting with `[DashboardModel]`. These will tell you exactly what failed.

**Common Scenarios**:

#### A. Connection Timeout
```
[DashboardModel] Exception Type: DioExceptionType.connectionTimeout
[DashboardModel] CAUSE: Connection timeout - backend server took too long to respond
```
**Solution**: 
- Check if `https://church.innovative.ng/` is online
- Check your internet connection
- Backend server may be down or very slow

#### B. Receive Timeout
```
[DashboardModel] Exception Type: DioExceptionType.receiveTimeout
[DashboardModel] CAUSE: Receive timeout - response took too long
```
**Solution**:
- Backend is responding but too slowly
- Check backend performance
- Increase timeout in Utility.getDio() if needed

#### C. Network Error
```
[DashboardModel] Exception Type: DioExceptionType.unknown
[DashboardModel] CAUSE: Network error or socket error
[DashboardModel] CHECK: Internet connection available?
```
**Solution**:
- Check device internet connection
- Check if WiFi/data is enabled
- Try on different network

#### D. Settings Object Null
```
[DashboardModel] ERROR: Settings object is null in response
[DashboardModel] Response keys: [errors, message]
```
**Solution**:
- Backend API response format changed
- Check if `/initapp` endpoint returns `settings` object
- Check backend controller for bugs

#### E. API Token Validation Failed
```
[DashboardModel] API Token validation failed
[DashboardModel] CHECK: API_TOKEN is correct in StringsUtils.dart
```
**Solution**:
- Verify `StringsUtils.API_TOKEN` is correct: `4f1a23de-8899-4b22-b111-98db6cc77b11`
- Check if backend validation logic is correct
- Token may have expired

---

## Testing Checklist

### 1. Check Backend Connectivity
```bash
# Open terminal/command prompt
curl -X POST https://church.innovative.ng/initapp \
  -H "Authorization: Bearer 4f1a23de-8899-4b22-b111-98db6cc77b11" \
  -H "Content-Type: application/json" \
  -d '{"data":{"email":""}}'
```

**Expected Response** (HTTP 200):
```json
{
  "errors": false,
  "message": "success",
  "settings": {
    "features": "hymns|notes|photos|...",
    "app_login": "0",
    "allow_downloads": "0",
    ...
  },
  "latest_media": [...],
  "latest_articles": [...],
  ...
}
```

### 2. Check API Endpoint
```bash
# Verify the endpoint exists and responds
curl -I https://church.innovative.ng/initapp
```

**Expected Response** (at least HTTP 200-404, not timeout):
```
HTTP/2 200
```

### 3. Monitor App Logs
Run the app with:
```bash
flutter run -v
```

Look for `[DashboardModel]` logs to see the exact failure point.

---

## Request/Response Flow Verification

### Request Format
```
POST https://church.innovative.ng/initapp
Headers:
  Authorization: Bearer 4f1a23de-8899-4b22-b111-98db6cc77b11
  Content-Type: application/json

Body:
{
  "data": {
    "email": "user@example.com"
  }
}
```

### Expected Response Structure
```json
{
  "errors": false,
  "message": "success",
  "settings": {
    "features": "hymns|notes|photos|radio|livestreams|prayer|testimony",
    "app_login": "0",
    "allow_downloads": "0",
    "join_groups": "0",
    "post_prayer": "0",
    "post_testimony": "0",
    "facebook": "...",
    "twitter": "...",
    "instagram": "...",
    "youtube": "...",
    "website": "...",
    "donations_link": "..."
  },
  "latest_media": [],
  "latest_articles": [],
  "latest_books": [],
  "upcoming_events": [],
  "members": []
}
```

---

## Code Changes Made

### 1. Utility.dart - Added Timeouts
```dart
static Dio getDio() {
  final dio = Dio();
  String token = StringsUtils.API_TOKEN;
  
  // NEW: Set timeout for connection and response (30 seconds)
  dio.options.connectTimeout = Duration(seconds: 30);
  dio.options.receiveTimeout = Duration(seconds: 30);
  dio.options.sendTimeout = Duration(seconds: 30);
  
  dio.options.headers["Authorization"] = "Bearer $token";
  return dio;
}
```

### 2. DashboardModel.dart - Enhanced Error Handling
- Added detailed logging at every step
- Added DioException-specific error handling
- Added diagnostic messages for each error type
- Added response structure validation
- Logs now include:
  - Request URL
  - User email
  - Response status code
  - Response data preview
  - Specific error causes
  - Suggested fixes

---

## Next Steps

1. **Run the app** with updated code
2. **Look at console logs** for `[DashboardModel]` messages
3. **Identify the exact error** from the diagnostic output
4. **Take corrective action** based on the error type above
5. **Test backend connectivity** using curl command if needed

---

## Additional Improvements to Consider

1. **Retry Logic**: Add exponential backoff retry for failed requests
   ```dart
   int retryCount = 0;
   while (retryCount < 3) {
     try {
       // Make request
       break; // Success
     } catch (e) {
       retryCount++;
       if (retryCount >= 3) rethrow;
       await Future.delayed(Duration(seconds: 2 << retryCount));
     }
   }
   ```

2. **Offline Support**: Cache the last successful response locally
   ```dart
   // Save response to SQLite if successful
   // Use cached response if offline
   ```

3. **User-Friendly Error Messages**: Show specific errors in InitPage
   ```dart
   String errorMessage = "Connection failed";
   if (e.type == DioExceptionType.connectionTimeout) {
     errorMessage = "Server not responding. Check if church.innovative.ng is online.";
   }
   // Display errorMessage to user
   ```

4. **Certificate Pinning**: Secure the backend connection
   ```dart
   SecurityContext securityContext = SecurityContext.defaultContext;
   // Pin certificate for church.innovative.ng
   ```

---

## Support Resources

- **Backend URL**: https://church.innovative.ng/
- **API Endpoint**: `/initapp` (POST)
- **Auth Method**: Bearer Token
- **Token**: `4f1a23de-8899-4b22-b111-98db6cc77b11`
- **Timeout**: 30 seconds (per request type)

---

## Summary of Fixes

| Issue | Fix | Impact |
|-------|-----|--------|
| No timeouts | Added 30s timeouts to Dio | Prevents infinite hangs |
| Poor logging | Enhanced logging with categories | Enables diagnosis of failures |
| Generic errors | Added DioException handling | Clear error identification |
| No diagnostics | Added response validation | Validates backend response format |

