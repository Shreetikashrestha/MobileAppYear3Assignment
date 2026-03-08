# User Routing Issue - Fix Guide

## Problem
Users who sign up as "Influencer" are being routed to the Brand Dashboard after login.

## Root Cause
The backend API determines the user's role (`isInfluencer` field), not the UI selection. When a user signs up, the backend might be saving them with the wrong role.

## How Routing Works

### 1. Signup Flow
```
User selects role → Signup → Backend saves user → Returns user with isInfluencer flag
```

### 2. Login Flow
```
User logs in → Backend returns user with isInfluencer flag → Save to SharedPreferences → Route to dashboard
```

### 3. App Start Flow (Splash Screen)
```
Check SharedPreferences → Read isInfluencer flag → Route to correct dashboard
```

## The Issue

The `_selectedRole` variable in login/signup screens is just for UI display. The actual role comes from the backend API response.

**In signup_screen.dart (line 36)**:
```dart
final user = AuthApiModel(
  fullName: fullNameController.text.trim(),
  email: emailController.text.trim(),
  password: passwordController.text,
  isInfluencer: _selectedRole == 0,  // ✅ This IS sent to backend
);
```

**In auth_remote_datasource.dart (line 73-77)**:
```dart
// Save user session with isInfluencer flag
await _userSessionService.saveUserSession(
  userId: userId,
  email: user.email,
  fullName: user.fullName,
  profilePicture: user.profilePicture,
  isInfluencer: user.isInfluencer,  // ✅ This comes from API response
);
```

## Solution

The code is actually correct! The issue is likely one of these:

### Option 1: Backend Issue
The backend might not be respecting the `isInfluencer` field sent during registration.

**Check**: Look at the backend registration endpoint to ensure it saves the `isInfluencer` field correctly.

### Option 2: Login Screen Role Selector
The login screen has a role selector, but it doesn't affect login. It's just for UI.

**Fix**: Remove the role selector from login screen since the backend determines the role.

### Option 3: Add Role Verification
Add a check after login to show the user which role they have.

## Recommended Fixes

### Fix 1: Remove Role Selector from Login Screen
The login screen shouldn't have a role selector because the backend already knows the user's role.

### Fix 2: Add Role Display After Login
Show the user which role they have after successful login.

### Fix 3: Add Debug Logging
The code already has extensive logging. Check the console output to see what `isInfluencer` value is being returned.

## Testing Steps

1. **Create a new account as Influencer**
   - Select "Influencer" in signup
   - Complete registration
   - Check console logs for `isInfluencer: true`

2. **Login with that account**
   - Check console logs for `isInfluencer` value
   - Should route to InfluencerBottomNav

3. **Create a new account as Brand**
   - Select "Brand" in signup
   - Complete registration
   - Check console logs for `isInfluencer: false`

4. **Login with brand account**
   - Check console logs for `isInfluencer` value
   - Should route to BrandBottomNav

## Console Logs to Check

When you login, you should see:
```
🔐 Login Response - User Data: {...}
🔐 Is Influencer: true/false
💾 Saving user session with ID: ...
✅ Verified saved user ID: ...
```

When you register, you should see:
```
📝 Register Response - User Data: {...}
📝 Parsed User ID: ...
💾 Saving user session with ID: ...
✅ Verified saved user ID: ...
```

## Quick Fix Implementation

I'll implement a fix that:
1. Removes the confusing role selector from login screen
2. Adds better user feedback about their role
3. Ensures proper routing based on backend response
