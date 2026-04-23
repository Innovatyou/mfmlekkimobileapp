# 🚨 Google Play Store & Apple App Store Compliance Review

**Date:** December 21, 2025  
**Status:** ⚠️ CRITICAL ISSUES FOUND - MUST FIX BEFORE SUBMISSION

---

## 🔴 CRITICAL VIOLATIONS (App Will Be Rejected)

### 1. **INSECURE NETWORK COMMUNICATION - HTTP Instead of HTTPS**
**Severity:** CRITICAL ❌  
**Impact:** App Store Rejection on Android and iOS  

**Issue:**
```dart
// lib/utils/ApiUrl.dart (Line 6)
static const String BASEURL = "http://192.168.100.12/churchapp/";

// Also present:
// static const String BASEURL = "http://10.0.2.2/churchapp/";
```

**Production URL is NOT visible but must be HTTPS:**
```dart
// static const String BASEURL = "https://church.innovative.ng/";
```

**Problem:**
- ❌ Android 9+ (API 28) requires HTTPS by default
- ❌ All API calls must use HTTPS for production
- ❌ Development IP address (192.168.100.12) exposed in code
- ❌ Google Play Store rejects apps with cleartext traffic

**Fix Required:**
```dart
// lib/utils/ApiUrl.dart
class ApiUrl {
  // PRODUCTION - Must be HTTPS
  static const String BASEURL = "https://church.innovative.ng/";
  
  // Development endpoints should NOT be in production build
  // Use BuildConfiguration or environment variables instead
}
```

**Also in AndroidManifest.xml (Line 48):**
```xml
android:usesCleartextTraffic="true"  <!-- ❌ MUST BE REMOVED FOR PRODUCTION -->
```

---

### 2. **HARDCODED API TOKEN EXPOSED**
**Severity:** CRITICAL ❌  
**Impact:** Security Breach, Store Rejection, Account Compromise  

**Issue:**
```dart
// lib/utils/StringsUtils.dart (Line 2)
static const String API_TOKEN = "4f1a23de-8899-4b22-b111-98db6cc77b11";

// Used in:
// lib/utils/ApiUrl.dart Lines 14, 16, 18
static const String TERMS = BASEURL + "terms?_p=" + StringsUtils.API_TOKEN;
static const String PRIVACY = BASEURL + "privacy?_p=" + StringsUtils.API_TOKEN;
static const String DONATE = BASEURL + "donate/" + StringsUtils.API_TOKEN;
```

**Problems:**
- ❌ API Token is hardcoded in source code
- ❌ Anyone can reverse engineer APK and get token
- ❌ Token can be used to abuse backend services
- ❌ Security violation flagged by both stores

**Fix Required:**
1. **Remove token from code** - Use backend authentication instead
2. **Move to backend** - Generate session/JWT tokens on login
3. **Use secure storage** - Store tokens in encrypted keychain/keystore
4. **Token rotation** - Implement token expiration

```dart
// WRONG ❌
static const String API_TOKEN = "4f1a23de-8899-4b22-b111-98db6cc77b11";

// RIGHT ✅
// Store token securely after login, not in code
String? token = await secureStorage.read(key: 'api_token');
```

---

### 3. **GOOGLE MAPS API KEY EXPOSED**
**Severity:** HIGH ⚠️  
**Impact:** Billing Fraud, Quota Abuse, Store Warning  

**Issue:**
```dart
// lib/utils/StringsUtils.dart (Line 3-4)
static const String GOOGLE_MAPS_API_KEY = "AIzaSyBfuhQRA34pDiVzu0jYfkTi6Cw72d9vQzY";
```

**Problems:**
- ❌ API key visible in source code
- ❌ Attackers can use key for fraudulent requests
- ❌ Google charges for unauthorized usage
- ❌ Key should be restricted in Google Cloud Console

**Fix Required:**
1. **Regenerate the key immediately**
   - Go to Google Cloud Console
   - Delete the exposed key
   - Create new key with Android/iOS app restrictions
   
2. **Move key to backend**
   ```dart
   // WRONG ❌
   static const String GOOGLE_MAPS_API_KEY = "AIzaSyBfuhQRA34pDiVzu0jYfkTi6Cw72d9vQzY";
   
   // RIGHT ✅
   // Call backend endpoint that returns map data using server-side key
   final mapData = await apiClient.get('/api/maps/data');
   ```

3. **Use Android/iOS Configuration**
   - Android: `AndroidManifest.xml` meta-data with restrictions
   - iOS: `Info.plist` with restrictions

---

### 4. **CLEARTEXT TRAFFIC ENABLED**
**Severity:** CRITICAL ❌  
**Impact:** Android App Store Rejection  

**Issue:**
```xml
<!-- android/app/src/main/AndroidManifest.xml (Line 48) -->
android:usesCleartextTraffic="true"
```

**Problem:**
- ❌ Allows unencrypted HTTP traffic
- ❌ Google Play requires HTTPS-only for API 28+
- ❌ Violates Play Store security policies
- ❌ User data transmitted unencrypted

**Fix Required:**
1. Change to HTTPS everywhere
2. Remove `usesCleartextTraffic="true"`
3. Use proper `network_security_config.xml`

---

## 🟠 HIGH PRIORITY ISSUES

### 5. **MISSING PRIVACY POLICY**
**Severity:** HIGH ⚠️  
**Impact:** App Store Rejection  

**Current State:**
- Privacy policy is linked via API endpoint: `ApiUrl.PRIVACY`
- Need to verify privacy policy covers:
  - ✅ Data collection practices
  - ✅ Third-party service usage
  - ✅ User rights
  - ✅ Data storage
  - ✅ GDPR compliance (if EU users)

**Required Actions:**
1. Ensure comprehensive privacy policy exists
2. Make it easily accessible in app
3. Add link to privacy policy in store listing
4. Keep updated with any data practice changes

---

### 6. **EXCESSIVE PERMISSIONS REQUESTED**
**Severity:** MEDIUM ⚠️  
**Impact:** User Distrust, Store Warning  

**Current Permissions:**
```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<uses-permission android:name="android.permission.INTERNET" />              ✅ Needed
<uses-permission android:name="android.permission.WAKE_LOCK"/>             ⚠️  Why?
<uses-permission android:name="android.permission.FOREGROUND_SERVICE"/>    ⚠️  For background?
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/> ⚠️  Scoped storage?
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>  ⚠️  Scoped storage?
<uses-permission android:name="android.permission.CAMERA" />               ⚠️  Why?
<uses-permission android:name="android.permission.RECORD_AUDIO" />         ⚠️  For video?
<uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS"/> ⚠️  For audio?
<uses-permission android:name="android.permission.BLUETOOTH" />            ⚠️  Why?
<uses-permission android:name="android.permission.BLUETOOTH_ADMIN" />      ⚠️  Why?
```

**Fix Required:**
- ❌ Only request permissions that app actually uses
- ❌ Remove: CAMERA, RECORD_AUDIO, BLUETOOTH if not needed
- ❌ Use scoped storage instead of WRITE/READ_EXTERNAL_STORAGE
- ❌ Provide justification for each permission in store listing

---

### 7. **NO TERMS OF SERVICE LINKED**
**Severity:** MEDIUM ⚠️  
**Impact:** Store Rejection, Legal Risk  

**Current State:**
- App links to terms but backend endpoint used: `ApiUrl.TERMS`

**Required Actions:**
1. Ensure terms of service exists and is comprehensive
2. Include in app settings
3. Link in store listings
4. Cover user conduct, liability, intellectual property

---

## 🟡 MEDIUM PRIORITY ISSUES

### 8. **MISSING APP VERSION IN PRODUCTION**
**Severity:** MEDIUM ⚠️  
**Impact:** Versioning Issues in Store  

**Check Status:**
- Need to verify `pubspec.yaml` has proper version number
- Store listings require version matching

---

### 9. **NO CRASH REPORTING SETUP VISIBLE**
**Severity:** MEDIUM ⚠️  
**Impact:** Unable to Debug Production Issues  

**Recommendation:**
- Implement Firebase Crashlytics
- Or use comparable crash reporting service
- Required for production support

---

## 🟢 COMPLIANCE CHECKLIST

### Before Publishing to Google Play Store:

- [ ] **1. Change BASEURL to HTTPS** - Replace with production URL using HTTPS
  ```dart
  static const String BASEURL = "https://church.innovative.ng/";
  ```

- [ ] **2. Remove API_TOKEN from code** - Use backend session tokens instead
  - Delete hardcoded token
  - Implement JWT/session-based auth
  - Store tokens securely

- [ ] **3. Regenerate and secure Google Maps API key**
  - Delete exposed key from Google Cloud
  - Create new key with app restrictions
  - Move to backend if possible

- [ ] **4. Remove cleartext traffic**
  - Delete `android:usesCleartextTraffic="true"` from AndroidManifest
  - Ensure all endpoints use HTTPS

- [ ] **5. Trim unnecessary permissions**
  - Remove unused permissions (CAMERA, BLUETOOTH, etc.)
  - Migrate to scoped storage for file access

- [ ] **6. Verify privacy policy**
  - Ensure comprehensive privacy policy exists
  - Add to app UI
  - Submit to store

- [ ] **7. Verify terms of service**
  - Ensure terms exist and are complete
  - Link in app and store listings

- [ ] **8. Enable crash reporting**
  - Firebase Crashlytics or similar
  - Required for production monitoring

- [ ] **9. Verify app version** in `pubspec.yaml`
  - Matches store submission version
  - Follows semantic versioning

- [ ] **10. Test on real device**
  - Verify all permissions work correctly
  - No crashes or errors
  - All APIs use HTTPS

---

## 🔧 IMPLEMENTATION STEPS

### Immediate Actions (Before Any Store Submission):

1. **Update ApiUrl.dart for production:**
```dart
class ApiUrl {
  // Use environment variables or build configuration
  static const String BASEURL = String.fromEnvironment(
    'API_URL',
    defaultValue: 'https://church.innovative.ng/',
  );
  
  // Remove hardcoded tokens
  // Remove API_TOKEN usage
}
```

2. **Update StringsUtils.dart:**
```dart
class StringsUtils {
  // REMOVE THIS LINE:
  // static const String API_TOKEN = "4f1a23de-8899-4b22-b111-98db6cc77b11";
  
  // REMOVE THIS LINE:
  // static const String GOOGLE_MAPS_API_KEY = "AIzaSyBfuhQRA34pDiVzu0jYfkTi6Cw72d9vQzY";
}
```

3. **Update AndroidManifest.xml:**
```xml
<!-- Remove or set to false -->
android:usesCleartextTraffic="false"  <!-- ✅ CORRECT -->

<!-- Trim permissions to only what's needed -->
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
<!-- Remove unnecessary ones -->
```

4. **Regenerate API Key:**
   - Go to Google Cloud Console
   - Delete `AIzaSyBfuhQRA34pDiVzu0jYfkTi6Cw72d9vQzY`
   - Create new key with restrictions
   - Keep secret

---

## 📋 Store-Specific Requirements

### Google Play Store:

- ✅ HTTPS for all network traffic (Android 9+)
- ✅ No hardcoded credentials
- ✅ No cleartext traffic
- ✅ Privacy policy required
- ✅ Terms of service recommended
- ✅ Content rating questionnaire

### Apple App Store:

- ✅ Privacy policy required (URL in Info.plist if needed)
- ✅ HTTPS only
- ✅ No hardcoded credentials
- ✅ Proper permissions justification
- ✅ Age rating required
- ✅ Terms of service recommended

---

## 🔐 Security Best Practices

### After Fixing Compliance:

1. **Implement API Key Security:**
   ```dart
   // Use backend proxy for sensitive operations
   final response = await http.get(
     Uri.parse('https://YOUR_API/maps/data'),
     headers: {'Authorization': 'Bearer $sessionToken'},
   );
   ```

2. **Secure Token Storage:**
   ```dart
   // Use flutter_secure_storage
   final storage = const FlutterSecureStorage();
   await storage.write(key: 'auth_token', value: jwtToken);
   ```

3. **HTTPS Certificate Pinning:**
   ```dart
   // Consider for sensitive apps
   // Pin certificates to prevent MITM attacks
   ```

---

## ⏰ Timeline Recommendation

**Week 1:**
- Fix HTTPS/cleartext traffic issues
- Remove hardcoded tokens
- Regenerate API keys

**Week 2:**
- Trim permissions
- Verify privacy policy
- Verify terms of service

**Week 3:**
- Beta testing on real devices
- Final security audit
- Store listing preparation

**Week 4:**
- Submit to Google Play Store
- Submit to Apple App Store

---

## 📞 Support

If you need help with any of these items:
1. Consult store review guidelines
2. Implement suggested fixes
3. Test thoroughly before submission
4. Plan for possible rejection and resubmission

---

**STATUS:** App NOT READY for store submission until critical issues are resolved.

**Last Updated:** December 21, 2025
