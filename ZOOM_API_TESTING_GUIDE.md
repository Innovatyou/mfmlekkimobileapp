# Zoom API Testing Guide

## 🧪 How to Test the Zoom Service API

This guide helps you test the Zoom service API integration without needing a full Flutter build.

---

## 🔍 Quick API Test

### Using cURL

#### Test Live Response
```bash
curl -X GET https://church.innovative.ng/api/zoom/live \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -v
```

#### Expected Live Response (200 OK)
```json
{
  "status": "live",
  "data": {
    "title": "SUNDAY NIGHT PRAYER MEETING",
    "platform": "zoom",
    "meeting_url": "https://zoom.us/wc/join/abc123def456",
    "start_time": "2025-12-21 20:00:00"
  }
}
```

#### Expected Offline Response (200 OK)
```json
{
  "status": "offline",
  "message": "Zoom service holds every Sunday by 8:00 PM"
}
```

---

## 🛠️ Using Postman

### Setup

1. Open Postman
2. Click "New" → "Request"
3. Set Method to **GET**
4. Enter URL: `https://church.innovative.ng/api/zoom/live`
5. Add Headers:
   - `Content-Type: application/json`
   - `Accept: application/json`
6. Click "Send"

### Expected Results

**Status Code**: 200 OK

**Response Body**: Live or Offline JSON (see above)

---

## 🧪 Testing Scenarios

### Scenario 1: Service is Live
**Time**: Sunday 8:00 PM
**Expected**: 
- `status: "live"`
- Meeting URL present
- Title and start time present

**Verification**:
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

### Scenario 2: Service is Offline
**Time**: Any time except Sunday 8:00 PM
**Expected**: 
- `status: "offline"`
- Message about next service time
- No data object

**Verification**:
```json
{
  "status": "offline",
  "message": "Zoom service holds every Sunday by 8:00 PM"
}
```

### Scenario 3: Network Timeout
**Setup**: No internet or backend down
**Expected**: 
- Request times out after 10 seconds
- Error message displayed to user
- App shows "Failed to load service" message

### Scenario 4: Invalid JSON
**Setup**: Backend returns malformed JSON
**Expected**: 
- Error caught and handled
- User sees error message
- No app crash

### Scenario 5: Missing Fields
**Setup**: Backend missing required fields
**Expected**: 
- Fields treated as null
- App handles gracefully
- Defaults to safe state

---

## 📝 Mock API Responses for Testing

### Using a Mock Server

#### Option 1: Using RequestBin (Easy)
1. Go to https://requestbin.com
2. Create new endpoint
3. Send test requests to it
4. Use for debugging but not production

#### Option 2: Using Postman Mock Server
1. Create collection with requests
2. Set up Postman mock server
3. Use mock URL in app for testing
4. Example mock URL: `https://your-mock-server.postman.com/api/zoom/live`

#### Option 3: Local Mock Server (Node.js)
```javascript
const express = require('express');
const app = express();

app.get('/api/zoom/live', (req, res) => {
  // Simulate live service at specific time
  const hour = new Date().getHours();
  const day = new Date().getDay();
  
  if (day === 0 && hour >= 20) {
    // Sunday after 8 PM
    res.json({
      status: 'live',
      data: {
        title: 'SUNDAY NIGHT PRAYER MEETING',
        platform: 'zoom',
        meeting_url: 'https://zoom.us/wc/join/test123',
        start_time: new Date().toISOString()
      }
    });
  } else {
    res.json({
      status: 'offline',
      message: 'Zoom service holds every Sunday by 8:00 PM'
    });
  }
});

app.listen(3000, () => {
  console.log('Mock API running on port 3000');
});
```

---

## 🔧 Testing Different Responses

### Test with Custom Backend

#### 1. Modify API Endpoint (Temporary)
File: `lib/service/zoom_service.dart`
```dart
static const String _baseUrl = 'http://your-test-server:3000/api/zoom/live';
```

#### 2. Test Different Scenarios
```bash
# Live response
curl -X GET http://localhost:3000/api/zoom/live
# Returns: {"status": "live", "data": {...}}

# Offline response
curl -X GET http://localhost:3000/api/zoom/offline
# Returns: {"status": "offline", "message": "..."}

# Error response
curl -X GET http://localhost:3000/api/zoom/error
# Returns: {"error": "..."}
```

#### 3. Verify App Behavior
- Run app with test server
- Verify each response is handled correctly
- Check UI updates properly

---

## 📊 Performance Testing

### Test Response Time

```bash
# Measure API response time
time curl -X GET https://church.innovative.ng/api/zoom/live
```

**Expected**: < 1 second

### Test with Network Throttling

Using Chrome DevTools (for web testing):
1. Open DevTools (F12)
2. Go to "Network" tab
3. Set throttling to "Slow 3G"
4. Make API request
5. Verify timeout works correctly (10 sec)
6. Verify error UI displays

### Test Concurrent Requests

```bash
# Send multiple requests simultaneously
for i in {1..10}; do
  curl -X GET https://church.innovative.ng/api/zoom/live &
done
wait
```

**Expected**: All requests succeed without errors

---

## 🐛 Debugging API Issues

### Enable Request Logging

In `lib/service/zoom_service.dart`, add logging:

```dart
print('📡 API Request: $_baseUrl');
print('Headers: $headers');

if (response.statusCode == 200) {
  print('✅ Response: ${response.body}');
} else {
  print('❌ Error: ${response.statusCode} - ${response.body}');
}
```

### Monitor Network Activity

**Android**:
1. Open Android Studio
2. Tools → App Inspection → Database Inspector
3. Monitor HTTP requests in real-time

**iOS**:
1. Open Xcode
2. Debug → View Memory Graph
3. Monitor network calls

### Check Response Headers

```bash
curl -i https://church.innovative.ng/api/zoom/live
```

Look for:
- `Content-Type: application/json`
- `Content-Length: {size}`
- `Cache-Control: no-cache` (recommended)

---

## ✅ Testing Checklist

### API Endpoint Tests
- [ ] Endpoint is accessible
- [ ] Returns 200 status code
- [ ] Returns valid JSON
- [ ] Live response has all required fields
- [ ] Offline response has all required fields
- [ ] Response headers are correct

### Response Validation
- [ ] `status` field is "live" or "offline"
- [ ] Live response includes meeting URL
- [ ] Offline response includes message
- [ ] Start time is valid datetime
- [ ] Title is not empty
- [ ] Platform is specified

### Error Scenarios
- [ ] 404 error handled gracefully
- [ ] 500 error handled gracefully
- [ ] Timeout handled gracefully
- [ ] Invalid JSON handled gracefully
- [ ] Missing fields handled gracefully

### Performance
- [ ] Response time < 1 second
- [ ] Timeout works after 10 seconds
- [ ] No memory leaks on multiple requests
- [ ] Concurrent requests work

### Integration
- [ ] App fetches data correctly
- [ ] UI updates with correct state
- [ ] Error messages display properly
- [ ] Retry mechanism works
- [ ] Refresh updates data

---

## 🔐 Security Testing

### HTTPS Verification
```bash
# Verify SSL certificate
openssl s_client -connect church.innovative.ng:443 -tls1_2
```

### Certificate Validation
```bash
# Check certificate chain
openssl s_client -showcerts -connect church.innovative.ng:443
```

### Test Invalid Certificate
```bash
# This should fail in app
curl -k https://invalid-cert.example.com/api/zoom/live
```

**Expected**: App rejects invalid certificates

---

## 📋 API Specification Template

Fill this out for your API:

```
Endpoint: https://church.innovative.ng/api/zoom/live
Method: GET
Auth: None required

Query Parameters: None

Request Headers:
- Content-Type: application/json
- Accept: application/json

Response (Live):
{
  "status": "live",
  "data": {
    "title": "SUNDAY NIGHT PRAYER MEETING",
    "platform": "zoom",
    "meeting_url": "https://zoom.us/wc/join/...",
    "start_time": "2025-12-21 20:00:00"
  }
}

Response (Offline):
{
  "status": "offline",
  "message": "Zoom service holds every Sunday by 8:00 PM"
}

Status Codes:
- 200: Success
- 404: Not Found (treated as offline)
- 500: Server Error (show error to user)

Timeout: 10 seconds
Retry: Yes (user can retry)
Cache: No (always fetch fresh)
```

---

## 🎯 Integration Testing

### Simulate Live Service

1. **Backend Configuration**:
   - Set service status to "live"
   - Provide valid Zoom meeting URL
   - Set current time to Sunday 8:00 PM

2. **Run App**:
   ```bash
   flutter run
   ```

3. **Verify**:
   - "Live Zoom Service" screen shows live state
   - Red "LIVE NOW" badge appears
   - Join buttons are enabled
   - Can open meeting in WebView

### Simulate Offline Service

1. **Backend Configuration**:
   - Set service status to "offline"
   - Clear meeting URL
   - Set any other time

2. **Run App**:
   ```bash
   flutter run
   ```

3. **Verify**:
   - "Service Not Live" message appears
   - Join button disabled
   - Next service info displays
   - Can't click join

---

## 📚 Additional Resources

- [Flutter HTTP Package](https://pub.dev/packages/http)
- [Postman Documentation](https://learning.postman.com)
- [cURL Manual](https://curl.se/docs/manpage.html)
- [JSON Schema Validator](https://www.jsonschemavalidator.net/)
- [API Testing Best Practices](https://restfulapi.net/http-status-codes/)

---

## 🆘 Troubleshooting

### "Connection refused"
- Backend not running
- Wrong URL or port
- Firewall blocking

### "SSL Certificate Error"
- Expired certificate
- Self-signed cert needs exception
- Check certificate validity

### "Timeout"
- Network too slow
- Backend not responding
- 10-second timeout limit reached

### "Invalid JSON"
- Backend returning wrong format
- Check response headers
- Validate with JSON validator

### "404 Not Found"
- Wrong endpoint URL
- Backend not deployed
- Route not configured

---

**For more help, refer to:**
- `ZOOM_SETUP_QUICK_START.md`
- `ZOOM_FEATURE_IMPLEMENTATION.md`
- `ZOOM_IMPLEMENTATION_SUMMARY.md`

---

**Last Updated**: December 2025
