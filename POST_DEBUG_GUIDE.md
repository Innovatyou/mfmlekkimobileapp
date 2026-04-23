# Post Publishing - HTTP 500 Error Fix Guide

## Issue Summary
Users encounter HTTP 500 Server Error when trying to publish posts with writeup content.

## Root Causes & Solutions

### 1. **Enhanced Error Logging** ✅ APPLIED
- Added comprehensive logging to `MakePostScreen.dart`
- Captures request payload, response status, headers, and error details
- Check the Flutter console logs when error occurs

**Key logs to look for:**
```
=== POST REQUEST DEBUG ===
Endpoint: https://church.innovative.ng/make_post
Email: user@example.com
Files Count: X
Content Length: Y
FormData fields: {...}
FormData files count: Z
========================
```

### 2. **Potential Backend Issues to Verify**

#### Check these field names match backend expectations:
- `email` - User email address ✓
- `visibility` - Set to "public" ✓
- `content` - Base64 encoded writeup ✓
- `files_0`, `files_1`, etc. - Multipart files ✓

#### Common backend issues:
- Missing or incorrect email field
- Content field expects plain text instead of base64
- File upload size limits exceeded
- Database connection/transaction errors
- Missing required fields

### 3. **Content Encoding Issue (Most Likely)**
The content is being Base64 encoded. If the backend expects plain text:

**Solution:** Modify `lib/socials/MakePostScreen.dart` line 127:
```dart
// BEFORE:
"content": Utility.getBase64EncodedString(content),

// AFTER (if backend expects plain text):
"content": content,
```

### 4. **Request Validation**
The logging will show:
- Exact endpoint being called
- All form fields being sent
- Number of files and file paths
- Upload progress

### 5. **Steps to Debug**

1. **Check console logs** when posting fails
2. **Look at the "Response Data"** line - it will show server error details
3. **Common fixes**:
   - If error mentions "content format", remove Base64 encoding
   - If error mentions "missing field", check which field is missing
   - If error mentions "file size", reduce file sizes
   - If error mentions "email not found", verify user is logged in

### 6. **Testing with Updated Code**

The enhanced `MakePostScreen.dart` now shows:
- ✅ Full request payload before sending
- ✅ Response status codes
- ✅ Server error messages
- ✅ Connection errors with details
- ✅ Upload progress percentage

### 7. **Next Steps**

1. Rebuild and test the post feature
2. Check the console output when 500 error occurs
3. Share the console logs to identify the exact issue
4. Modify request format based on server response

### 8. **Alternative: Test with Simple Text Post**

Try posting **without any files** first to narrow down the issue:
- Is 500 error with files only? → File upload issue
- Is 500 error with text only? → Content/field format issue
- Is 500 error always? → Backend connection/auth issue

## Files Modified
- `lib/socials/MakePostScreen.dart` - Enhanced error handling and logging

## References
- Endpoint: `https://church.innovative.ng/make_post`
- Request Type: POST (multipart/form-data)
- Payload includes: email, visibility, content, files
