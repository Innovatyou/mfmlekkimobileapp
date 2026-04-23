# Login Authentication Troubleshooting Guide

## Problem Summary
- ✅ User registration works (no errors returned)
- ❌ User login fails with error: **"email or password does not exist"** even with correct credentials
- Registration claims success but login says credentials don't exist → likely data not being saved to database or saved in wrong table

## Root Cause Analysis

### Hypothesis 1: Email Verification Required (Most Likely)
**Issue**: Backend may require email verification before login is allowed.

**Evidence**: 
- Registration doesn't show "verify your email" message in the app
- But backend may enforce email verification before login

**Test**:
1. Check the registration response for `statuscode == 1` (line 113 in AuthPage.dart):
```dart
if (res["statuscode"] == 1) {
  registerSuccessMessage(t.resendverifylink);
}
```
2. If registration response includes `statuscode: 1`, user needs email verification before login.

**Solution**:
- Have the user verify their email via the link sent to their email address
- Or bypass email verification on the server (development only)

---

### Hypothesis 2: User Data Not Being Saved to Database
**Issue**: Registration returns success but doesn't actually insert the user into the database.

**Evidence**:
- Registration API response shows `"status": "ok"` but no user object returned
- Login query can't find the user

**Test**: Check the backend logs:
```bash
# SSH into server
tail -f /home/innovat8/public_html/church.innovative.ng/writable/logs/log-*.php

# Or check database directly (requires MySQL access)
mysql -u username -p churchdb
SELECT * FROM users WHERE email = 'registeredemail@example.com';
```

**Solution**:
- Check if `CREATE_ACCOUNT` endpoint actually inserts into the users table
- Verify database permissions
- Check for SQL errors in the backend logs

---

### Hypothesis 3: Field Name Mismatch (Email vs Username)
**Issue**: Backend expects different field names for login.

**Evidence**:
- Client sends: `{"email": "...", "password": "..."}`
- Backend might expect: `{"username": "...", "password": "..."}`

**Test**: 
- Read backend code in `app/Controllers/Api.php` method `loginapp()`
- Check parameter names: `$this->request->getJSON('email')` vs `$this->request->getJSON('username')`

**Solution**:
- If backend uses `username`, update `AuthPage.dart` line 99-101 to send username instead of email

---

### Hypothesis 4: Case Sensitivity or Whitespace Issues
**Issue**: Email comparison is case-sensitive or has leading/trailing whitespace.

**Evidence**:
- User registered as `User@Example.com` but tries to login as `user@example.com`
- Database stored email with whitespace: `" user@example.com "`

**Test**:
```bash
# Check database for exact email stored
SELECT email, CHAR_LENGTH(email), HEX(email) FROM users WHERE email LIKE '%user%';
```

**Solution**:
- Trim and lowercase email in both registration and login
- Check backend code does: `$email = strtolower(trim($email));`

---

## Client-Side Diagnostic Steps

### 1. Enable Enhanced Logging
Add logging to `AuthPage.dart` `_authUser()` method to see exact request/response:

```dart
Future<String?> _authUser(LoginData _data) async {
  email = _data.name;
  try {
    var data = {
      "email": _data.name,
      "password": _data.password,
    };
    
    print("[LOGIN] Sending credentials:");
    print("[LOGIN] Email: ${_data.name}");
    print("[LOGIN] Password length: ${_data.password.length}");
    
    final response = await Utility.getDio()
        .post(ApiUrl.LOGIN_APP, data: jsonEncode({"data": data}));
    
    print("[LOGIN] Response status: ${response.statusCode}");
    print("[LOGIN] Response body: ${response.data}");
    
    if (response.statusCode == 200) {
      Map<String, dynamic> res = json.decode(response.data);
      print("[LOGIN] Parsed response: $res");
      print("[LOGIN] Status: ${res["status"]}");
      print("[LOGIN] Message: ${res["message"]}");
      print("[LOGIN] StatusCode: ${res["statuscode"]}");
      
      if (res["status"] == "error") {
        // ... rest of logic
      }
    }
  } catch (exception) {
    print("[LOGIN] Exception: $exception");
    return exception.toString();
  }
}
```

### 2. Monitor Flutter Logs
Run the app with verbose logging:
```bash
flutter run -v 2>&1 | grep -i "login\|email\|password"
```

### 3. Test Registration → Login Flow Step-by-Step
Register a new user via the app:
1. Open app
2. Go to Sign Up
3. Enter: `testlogin@example.com` / `TestPass123!`
4. Tap "Create Account"
5. Note any success/error message
6. Check if an email verification prompt appears
7. If verification required: check email inbox for verification link
8. Click verification link (if present)
9. Return to app and try to login with same credentials

---

## Server-Side Diagnostic Steps (If You Have Backend Access)

### 1. Check Backend Logs
```bash
# SSH into church.innovative.ng server
tail -f /home/innovat8/public_html/church.innovative.ng/writable/logs/log-*.php

# Look for errors during registration and login attempts
# Should show SQL errors, validation errors, or successful operations
```

### 2. Check Database Records
```sql
-- Connect to MySQL
mysql -u churchuser -p churchdb

-- List all users
SELECT id, email, password_hash, is_verified, created_at FROM users;

-- Check specific email
SELECT * FROM users WHERE email = 'testlogin@example.com';

-- If user exists but password is wrong, check if password hashing matches
SELECT id, email, LENGTH(password_hash) as hash_length FROM users;
```

### 3. Verify Backend Logic (app/Controllers/Api.php)
Check the `loginapp()` method:
```php
// Should look something like:
public function loginapp() {
    $data = $this->request->getJSON('data', true);
    $email = $data['email'] ?? '';
    $password = $data['password'] ?? '';
    
    // Trim and lowercase for consistency
    $email = strtolower(trim($email));
    
    // Find user by email
    $user = $this->db->table('users')
        ->where('email', $email)
        ->first();
    
    // Check if user exists and password matches
    if (!$user || !password_verify($password, $user->password_hash)) {
        return response()->setJSON([
            'status' => 'error',
            'message' => 'email or password does not exist',
            'statuscode' => 0
        ]);
    }
    
    // Check if user is verified (if required)
    if (!$user->is_verified) {
        return response()->setJSON([
            'status' => 'error',
            'message' => 'Please verify your email before logging in',
            'statuscode' => 1
        ]);
    }
    
    // Login successful
    return response()->setJSON([
        'status' => 'ok',
        'message' => 'Login successful',
        'user' => [
            'id' => $user->id,
            'email' => $user->email,
            'firstname' => $user->first_name,
            'lastname' => $user->last_name,
            // ... other fields
        ]
    ]);
}
```

### 4. Test Backend Directly with curl
```bash
# Test registration
curl -X POST "https://church.innovative.ng/createaccount" \
  -H "Authorization: Bearer 4f1a23de-8899-4b22-b111-98db6cc77b11" \
  -H "Content-Type: application/json" \
  -d '{"data":{"email":"curltester@example.com","password":"CurlTest123!"}}'

# Test login with same credentials
curl -X POST "https://church.innovative.ng/loginapp" \
  -H "Authorization: Bearer 4f1a23de-8899-4b22-b111-98db6cc77b11" \
  -H "Content-Type: application/json" \
  -d '{"data":{"email":"curltester@example.com","password":"CurlTest123!"}}'
```

---

## Quick Fix Checklist

- [ ] **Test email verification**: After registration, check if you received a verification email. If yes, click the verification link and try logging in again.
  
- [ ] **Try different credentials**: Register a brand new email (e.g., `test.unique.123@example.com`) and immediately try to login with that account.
  
- [ ] **Check backend logs**: SSH to server and tail the CI4 error logs to see if there are SQL/validation errors during registration.
  
- [ ] **Verify database**: Run MySQL query to confirm the user was actually inserted into the users table.
  
- [ ] **Check password hashing**: Ensure the backend is hashing passwords with `password_hash()` on registration and comparing with `password_verify()` on login.
  
- [ ] **Check email case/whitespace**: Verify the backend trims and lowercases emails before comparison.

---

## Next Steps

1. **Run one of the diagnostic tests above** (client-side logging or server-side query).
2. **Paste the results here** (logs, database output, or curl response).
3. **I'll identify the exact issue** and provide the specific fix (client code change or backend patch).

---

## Expected Behavior (Once Fixed)

**Registration Flow** (Should See):
```
✅ User enters email & password
✅ Tap "Create Account"
✅ "Success!" message or "Verify your email" prompt
✅ Check email for verification link (if required)
✅ Click verification link
```

**Login Flow** (Should See):
```
✅ User enters email & password (same as registration)
✅ Tap "Login"
✅ User navigated to UpdateProfile (if name missing) or HomePage
✅ Can see dashboard and app features
```

---

## Common Error Messages & Meanings

| Error Message | Likely Cause | Fix |
|---|---|---|
| "email or password does not exist" | User not in database OR credentials wrong | Verify email, check if user was saved, re-register |
| "Please verify your email before logging in" | Email verification required but not done | Click verification link in email |
| "A network error occurred" | Backend unreachable or timeout | Check internet, check if backend is online |
| "Invalid email format" | Backend email validation strict | Use valid email format (user@domain.com) |
| "Password does not meet requirements" | Backend password rules | Use stronger password (min 8 chars, uppercase, number, symbol) |

