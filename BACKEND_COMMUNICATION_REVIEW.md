# DashboardModel Backend Communication Review

## Overview
The `DashboardModel` communicates with a **CodeIgniter 4 backend** using the **Dio HTTP client** with Bearer token authentication. This document outlines the architecture and communication flow.

---

## 1. HTTP Client Configuration

### Location: `lib/utils/Utility.dart` (Lines 23-28)

```dart
static Dio getDio() {
  final dio = Dio();
  String token = StringsUtils.API_TOKEN;
  dio.options.headers["Authorization"] = "Bearer $token";
  return dio;
}
```

### Key Points:
- **HTTP Library**: Dio (a powerful HTTP client for Dart/Flutter)
- **Authentication Method**: Bearer Token
- **API Token**: `StringsUtils.API_TOKEN = "4f1a23de-8899-4b22-b111-98db6cc77b11"`
- **Token Location**: Static constant in `StringsUtils.dart`
- **Security Concern**: ⚠️ Token is hardcoded in client-side code (visible in app bundle)

---

## 2. API Endpoint Structure

### Base URL
```
https://church.innovative.ng/
```

### DashboardModel Primary Endpoint

**Endpoint**: `/initapp`  
**Method**: POST  
**Full URL**: `https://church.innovative.ng/initapp`

---

## 3. Request/Response Flow

### 3.1 Request Payload

```dart
// From DashboardModel.fetchItems() - Line 75
final response = await Utility.getDio().post(
  ApiUrl.INIT_APP,  // https://church.innovative.ng/initapp
  data: jsonEncode({
    "data": {"email": userdata == null ? "" : userdata.email}
  }),
);
```

**Request Headers**:
```
Authorization: Bearer 4f1a23de-8899-4b22-b111-98db6cc77b11
Content-Type: application/json
```

**Request Body**:
```json
{
  "data": {
    "email": "user@example.com"  // or empty string if not logged in
  }
}
```

---

## 3.2 Response Structure

The backend returns a JSON response with the following structure:

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
    "facebook": "https://facebook.com/churchname",
    "twitter": "https://twitter.com/churchname",
    "instagram": "https://instagram.com/churchname",
    "youtube": "https://youtube.com/churchname",
    "website": "https://churchwebsite.com",
    "donations_link": "https://donations.com"
  },
  "latest_media": [...],
  "latest_articles": [...],
  "latest_books": [...],
  "upcoming_events": [...],
  "members": [...]
}
```

---

## 4. Response Validation & Error Handling

### 4.1 Error Checks (Lines 87-102)

```dart
if (response.statusCode == 200) {
  dynamic res = jsonDecode(response.data);

  // CHECK 1: API Token Validation Error
  if (res["errors"] == true &&
      (res["message"]?.toString().toLowerCase() ?? "")
          .contains("no api token")) {
    Navigator.of(context!).pushReplacementNamed(AuthPage.routeName);
    return;
  }

  // CHECK 2: Settings Validity
  if (res["settings"] == null) {
    setFetchError();
    return;
  }
```

**Error Handling Logic**:
1. ✅ HTTP 200 status code validation
2. ✅ Backend error response checking (`res["errors"]`)
3. ✅ API token validation error detection
4. ✅ Settings object validation
5. ❌ No timeout handling
6. ❌ No specific error messages for users
7. ❌ Generic exception catch-all (Line 368)

---

## 5. Data Parsing & Transformation

### 5.1 Settings Parsing (Lines 104-117)

```dart
var settings = res["settings"];

// Boolean Logic Note: "0" = true, anything else = false
data['features'] = settings['features'] ?? "";
data['app_login'] = settings['app_login'] == "0";        // String "0" == true
data['allow_downloads'] = settings['allow_downloads'] == "0";
data['join_groups'] = settings['join_groups'] == "0";
data['post_prayer'] = settings['post_prayer'] == "0";
data['post_testimony'] = settings['post_testimony'] == "0";
```

⚠️ **Unusual Logic**: The backend returns `"0"` (string) to represent `true`
- `"0"` → converted to `true`
- Anything else → `false`
- This is likely a CodeIgniter convention but is counterintuitive

### 5.2 List Data Parsing (Lines 119-128)

```dart
recentmedia = settings.containsKey("latest_media") ? parseMedia(res) : [];
recentarticles = settings.containsKey("latest_articles") ? parseArticles(res) : [];
recentbooks = settings.containsKey("latest_books") ? parseBooks(res) : [];
upcomingevents = settings.containsKey("upcoming_events") ? parseEvents(res) : [];
recentmembers = settings.containsKey("members") ? parseMembers(res) : [];
```

**Parser Methods** (Lines 340-357):
```dart
static List<Media> parseMedia(dynamic res) {
  final parsed = res["latest_media"].cast<Map<String, dynamic>>();
  return parsed.map<Media>((json) => Media.fromJson(json)).toList();
}

static List<Articles> parseArticles(dynamic res) {
  final parsed = res["latest_articles"].cast<Map<String, dynamic>>();
  return parsed.map<Articles>((json) => Articles.fromJson(json)).toList();
}

// Similar methods for Books, Events, Members...
```

---

## 6. State Management & Navigation

### 6.1 ChangeNotifier Pattern

```dart
class DashboardModel with ChangeNotifier {
  bool isError = false;
  bool isLoading = true;
  // ... data fields ...

  void loadItems() {
    isError = false;
    isLoading = true;
    notifyListeners();  // Notify UI to show loading state
    fetchItems();
  }

  // In fetchItems():
  isLoading = false;
  isError = false;
  notifyListeners();  // Notify UI with data
}
```

### 6.2 Navigation Flow (Lines 130-139)

```dart
// After successful data fetch:
Userdata? u = await SQLiteDbProvider.db.getUserData();

if (u == null && data['app_login'] == true) {
  // Force login if user not found and login required
  Navigator.of(context!).pushReplacementNamed(AuthPage.routeName);
} else {
  // Show home page
  Navigator.of(context!).pushReplacementNamed(HomePage.routeName);
}
```

---

## 7. Feature Availability System

### 7.1 Feature Detection (Lines 311-325)

```dart
bool isFeatureAvailable(String type) {
  if (type == "media") {
    return ((data['features'] as String).contains("audiomessages") ||
            (data['features'] as String).contains("videomessages"));
  }
  if (type == "publications") {
    return ((data['features'] as String).contains("articles") ||
            (data['features'] as String).contains("books"));
  }
  if (type != "") {
    return (data['features'] as String).contains(type);
  }
  return true;
}
```

**Features String Format**: `"hymns|notes|photos|radio|livestreams|prayer|testimony"`
- Features are pipe-delimited
- Checked via substring matching
- Uses shorthand feature names different from display names

---

## 8. Database Interaction

### Local Database Usage

```dart
// Retrieve user email for request
Userdata? userdata = await SQLiteDbProvider.db.getUserData();

// Check if user logged in after fetch
Userdata? u = await SQLiteDbProvider.db.getUserData();
```

**Database Provider**: SQLite via `SQLiteDbProvider`
- Used to get current user data
- Used to verify authentication status
- Used as cache layer for user info

---

## 9. Event Bus Integration

```dart
registerEvents() {
  eventBus.on<OnLanguageChange>().listen((event) {
    setListItems();  // Rebuild UI when language changes
  });
}
```

**Integration**: Uses EventBus for reactive updates
- Triggers UI refresh when language preference changes
- Updates feature list display

---

## 10. Potential Issues & Improvements

### Security Issues
1. ⚠️ **Hardcoded API Token**: Token is visible in compiled APK
   - **Recommendation**: Move to backend-authenticated token system
   
2. ⚠️ **No Certificate Pinning**: SSL/TLS verification not mentioned
   - **Recommendation**: Implement certificate pinning for production

3. ⚠️ **No Request Signing**: No signature verification for response integrity
   - **Recommendation**: Implement HMAC signatures for critical data

### Code Quality Issues
1. ❌ **No Timeout Configuration**: Dio requests may hang indefinitely
   - **Fix**: Add `dio.options.connectTimeout` and `receiveTimeout`
   
2. ❌ **Poor Error Messaging**: Generic error on failed response
   - **Fix**: Parse and display specific backend error messages
   
3. ❌ **No Null Safety**: Response parsing can throw if fields missing
   - **Fix**: Use `.containsKey()` checks before accessing nested data
   
4. ❌ **Inconsistent Boolean Logic**: String "0" = true is confusing
   - **Recommend**: Backend should return proper boolean values
   
5. ❌ **No Retry Logic**: Failed requests not retried
   - **Fix**: Add exponential backoff retry mechanism

### Performance Issues
1. ⚠️ **No Response Caching**: Every load fetches all data from backend
   - **Fix**: Cache response locally for X minutes
   
2. ⚠️ **No Pagination**: All items fetched at once
   - **Fix**: Implement pagination for media, articles, books, members

3. ⚠️ **Synchronous Data Parsing**: Large lists block UI thread
   - **Fix**: Parse in separate isolate using `compute()`

---

## 11. Recommended Improvements

### Enhanced Configuration
```dart
static Dio getDio() {
  final dio = Dio();
  String token = StringsUtils.API_TOKEN;
  
  dio.options.headers["Authorization"] = "Bearer $token";
  dio.options.connectTimeout = Duration(seconds: 30);
  dio.options.receiveTimeout = Duration(seconds: 30);
  
  // Add response interceptor for token refresh
  dio.interceptors.add(
    InterceptorsWrapper(
      onError: (e, handler) {
        if (e.response?.statusCode == 401) {
          // Handle token expiry
        }
        return handler.next(e);
      },
    ),
  );
  
  return dio;
}
```

### Better Error Handling
```dart
try {
  final response = await Utility.getDio().post(ApiUrl.INIT_APP, data: ...);
  
  if (response.statusCode == 200) {
    // Handle response
  }
} on DioException catch (e) {
  if (e.type == DioExceptionType.connectionTimeout) {
    _showError("Connection timeout. Please check your internet.");
  } else if (e.type == DioExceptionType.receiveTimeout) {
    _showError("Server took too long to respond.");
  }
} catch (e) {
  _showError("An unexpected error occurred.");
}
```

---

## 12. CodeIgniter 4 Endpoint Expectations

### Backend Route (Likely Structure)
```php
// routes/Routes.php
$routes->post('initapp', 'Dashboard::initapp');

// app/Controllers/Dashboard.php
public function initapp() {
    $email = $this->request->getJSON('data')['email'] ?? '';
    
    // Validate API token
    $token = $this->request->getHeaderLine('Authorization');
    // Bearer token validation...
    
    // Fetch settings from database
    $settings = $this->db->table('settings')->get()->getRowArray();
    
    // Fetch dynamic content
    $media = $this->db->table('media')->limit(10)->get()->getResultArray();
    
    return $this->response->setJSON([
        'errors' => false,
        'message' => 'success',
        'settings' => $settings,
        'latest_media' => $media,
        'latest_articles' => [...],
        'latest_books' => [...],
        'upcoming_events' => [...],
        'members' => [...]
    ]);
}
```

---

## 13. Summary Table

| Aspect | Implementation | Status |
|--------|-----------------|--------|
| HTTP Client | Dio | ✅ Good choice |
| Authentication | Bearer Token | ✅ Implemented |
| Error Handling | Basic validation | ⚠️ Needs improvement |
| Timeout Handling | None | ❌ Missing |
| Caching | None | ❌ Missing |
| Pagination | None | ❌ Missing |
| Retry Logic | None | ❌ Missing |
| Security | Token in code | ⚠️ Risk |
| Code Quality | Acceptable | ⚠️ Can improve |
| State Management | ChangeNotifier | ✅ Good |

---

## Conclusion

The `DashboardModel` implements a functional client-server communication pattern using **Dio and Bearer token authentication** with a CodeIgniter 4 backend. While the basic structure is sound, it lacks enterprise-grade features like timeouts, caching, retry logic, and advanced error handling. The hardcoded API token poses a security risk and should be replaced with a dynamic authentication system.

