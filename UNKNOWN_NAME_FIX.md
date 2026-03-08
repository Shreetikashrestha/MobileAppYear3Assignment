# Fix for "Unknown" Names in Find Influencer

## Problem
Influencer names are showing as "Unknown" in the Find Influencer list, but bios and other data are displaying correctly.

## Root Cause
The backend's `getAllInfluencers` endpoint populates the `userId` field but the `fullName` is not being included in the populated data or is null in the database.

## Solutions Applied

### 1. Backend: Enhanced Population
**File**: `re-webapibackend/src/controllers/profile.controller.ts`

Added `_id` to the populate select to ensure all user fields are returned:
```typescript
const influencers = await InfluencerProfileModel.find(query)
    .populate('userId', 'fullName profilePicture email _id')  // Added _id
    .sort({ createdAt: -1 });
```

### 2. Backend: Better Error Handling for Profile Endpoint
**File**: `re-webapibackend/src/controllers/profile.controller.ts`

Enhanced `getProfileByUserId` to:
- Return user data even if profile doesn't exist
- Add comprehensive logging
- Handle missing profiles gracefully

### 3. Flutter: Fallback for Missing Names
**File**: `lib/features/influencer/data/datasources/influencer_remote_datasource.dart`

Added fallback values:
```dart
final mergedData = <String, dynamic>{
  'id': user['_id'],
  '_id': user['_id'],
  'fullName': user['fullName'] ?? 'Unknown User',  // Fallback
  'email': user['email'] ?? '',
  // ...
};
```

## Steps to Fix

### Step 1: Restart Backend
```bash
cd re-webapibackend
# Kill existing process
lsof -ti:5050 | xargs kill -9
# Start fresh
npm run dev
```

### Step 2: Check Database
The issue might be that existing users don't have `fullName` set. Check:

```bash
mongosh
use influcollb
db.users.find({ isInfluencer: true }, { fullName: 1, email: 1 })
```

If `fullName` is null or missing, update them:

```javascript
// Update users without fullName
db.users.updateMany(
  { isInfluencer: true, fullName: { $exists: false } },
  { $set: { fullName: "Influencer User" } }
)

// Or update specific users
db.users.updateOne(
  { email: "mike.chen@example.com" },
  { $set: { fullName: "Mike Chen" } }
)
```

### Step 3: Re-seed Database (Recommended)
The cleanest solution is to delete existing influencers and re-seed:

```bash
# Connect to MongoDB
mongosh
use influcollb

# Delete existing influencer users and profiles
db.users.deleteMany({ isInfluencer: true })
db.influencerprofiles.deleteMany({})

# Exit mongosh
exit

# Re-run seeder
cd re-webapibackend
npm run seed:influencers
```

Expected output:
```
✅ Created user: Sarah Johnson (sarah.johnson@example.com)
✅ Created profile for: Sarah Johnson
✅ Created user: Mike Chen (mike.chen@example.com)
✅ Created profile for: Mike Chen
...
🎉 Seeding completed successfully!
📊 Total influencer profiles in database: 5
```

### Step 4: Hot Restart Flutter App
```bash
# In Flutter app
# Press 'R' in terminal or
flutter run
```

### Step 5: Test
1. Login as Brand user
2. Go to Find Influencers tab
3. Should now see:
   - ✅ Real names (Sarah Johnson, Mike Chen, etc.)
   - ✅ Profile pictures or initials
   - ✅ Bios
   - ✅ Niches
   - ✅ Follower counts
   - ✅ Engagement rates

4. Click on an influencer
5. Should see full profile with all details

## Verification

### Check Backend Logs
```
🔍 [ProfileController] getAllInfluencers called
📊 [ProfileController] Found influencers count: 5
📊 [ProfileController] First influencer: {
  id: ...,
  userId: {
    _id: ...,
    fullName: 'Mike Chen',
    email: 'mike.chen@example.com'
  },
  username: 'mikechen'
}
```

### Check Flutter Logs
```
✅ [InfluencerDataSource] User fullName: Mike Chen
✅ [InfluencerDataSource] Successfully parsed: Mike Chen
🎨 [InfluencerCard] Rendering card for: Mike Chen
```

## If Still Showing "Unknown"

### Debug Step 1: Check API Response
Add this to see raw response:
```dart
print('RAW RESPONSE: ${response.data}');
```

### Debug Step 2: Check User Object
```dart
print('USER OBJECT: $user');
print('USER FULLNAME: ${user['fullName']}');
print('USER FULLNAME TYPE: ${user['fullName'].runtimeType}');
```

### Debug Step 3: Verify Database
```bash
mongosh
use influcollb

# Check if users have fullName
db.users.find({ isInfluencer: true }).forEach(function(doc) {
  print("Email: " + doc.email + ", FullName: " + (doc.fullName || "NULL"));
});

# Check if profiles are linked correctly
db.influencerprofiles.aggregate([
  {
    $lookup: {
      from: "users",
      localField: "userId",
      foreignField: "_id",
      as: "user"
    }
  },
  {
    $project: {
      username: 1,
      "user.fullName": 1,
      "user.email": 1
    }
  }
]).pretty()
```

## Expected Final Result

### Find Influencer List
```
Sarah Johnson
Fashion & Lifestyle influencer | NYC 🗽
👥 125K  📈 4.5%

Mike Chen  
Tech reviewer & gadget enthusiast
👥 250K  📈 5.8%

Emma Rodriguez
Fitness coach & wellness advocate
👥 180K  📈 7.1%
```

### Profile Screen
```
[Large Profile Picture]

Sarah Johnson
Fashion

Followers: 125K
Engagement: 4.5%
Platforms: 2

[Send Message Button]

About
Fashion & Lifestyle influencer | NYC 🗽 | Sharing my daily style

Platforms
Instagram  TikTok

Social Links
INSTAGRAM
@sarahjohnson

TIKTOK
@sarahjohnson
```

## Files Modified
1. `re-webapibackend/src/controllers/profile.controller.ts`
2. `MobileAppYear3Assignment/lib/features/influencer/data/datasources/influencer_remote_datasource.dart`
