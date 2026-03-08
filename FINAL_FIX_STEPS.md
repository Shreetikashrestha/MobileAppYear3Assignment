# Final Fix Steps for "Unknown" Names Issue

## Current Situation
- ✅ Backend is returning data (200 response)
- ✅ Bios are displaying correctly
- ❌ Names showing as "Unknown"
- ❌ Profile pictures showing as "file:///"

## Root Causes Identified

### 1. Flutter App Not Using Latest Code
The detailed logging we added is not showing in the console, which means the app needs to be rebuilt.

### 2. Profile Pictures Invalid
The `file:///` error indicates profile pictures are set to empty strings or invalid paths in the database.

## Complete Fix Steps

### Step 1: Clean and Rebuild Flutter App
```bash
cd MobileAppYear3Assignment

# Stop the app
# Press 'q' in terminal or Ctrl+C

# Clean build
flutter clean

# Get dependencies
flutter pub get

# Rebuild and run
flutter run
```

### Step 2: Restart Backend with Latest Code
```bash
cd re-webapibackend

# Kill existing process
lsof -ti:5050 | xargs kill -9

# Start fresh
npm run dev
```

### Step 3: Test the Flow
1. Login as Brand user (brand@gmail.com / 123456)
2. Navigate to "Find Influencers" tab (second tab)
3. You should now see detailed logs like:
```
🔍 [InfluencerDataSource] Fetching influencers from /api/profiles/influencers
📊 [InfluencerDataSource] Found 7 influencers in response
🔄 [InfluencerDataSource] Parsing influencer: ...
✅ [InfluencerDataSource] User fullName: Mike Chen
✅ [InfluencerDataSource] Successfully parsed: Mike Chen
```

### Step 4: If Still Showing "Unknown"

The issue is that the backend response doesn't include `fullName` in the populated `userId`. Let me verify the backend is populating correctly.

Run this test:
```bash
# Get auth token first
curl -X POST http://127.0.0.1:5050/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"brand@gmail.com","password":"123456"}' \
  | jq '.data.token'

# Use the token to test the endpoint
curl -X GET http://127.0.0.1:5050/api/profiles/influencers \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  | jq '.data[0].userId'
```

Expected output should include:
```json
{
  "_id": "...",
  "fullName": "Mike Chen",
  "email": "mike.chen@example.com",
  "profilePicture": null
}
```

If `fullName` is missing or null, the issue is in the backend population.

### Step 5: Fix Backend Population (If Needed)

The backend controller already has the correct populate:
```typescript
.populate('userId', 'fullName profilePicture email _id')
```

But Mongoose might not be finding the field. Check the User model:

```bash
mongosh
use influcollb

# Check if users have fullName
db.users.find({ isInfluencer: true }, { fullName: 1, email: 1 }).pretty()
```

If fullName is missing, run:
```bash
cd re-webapibackend
npm run fix:names
```

### Step 6: Alternative - Use Username as Fallback

If fullName is consistently null, we can modify the backend to use username as fallback:

**File**: `re-webapibackend/src/controllers/profile.controller.ts`

```typescript
const influencers = await InfluencerProfileModel.find(query)
    .populate('userId', 'fullName profilePicture email _id')
    .sort({ createdAt: -1 });

// Add fallback for missing fullName
const influencersWithNames = influencers.map(inf => {
    const profile = inf.toObject();
    if (profile.userId && !profile.userId.fullName) {
        profile.userId.fullName = profile.username || 'Influencer User';
    }
    return profile;
});

res.status(200).json({ 
    success: true, 
    count: influencersWithNames.length, 
    data: influencersWithNames 
});
```

## Expected Final Result

After all fixes, you should see:

```
Mike Chen
Tech reviewer & gadget enthusiast | Unboxing the latest tech
👥 250K  📈 5.8%

Sarah Johnson
Fashion & Lifestyle influencer | NYC 🗽 | Sharing my daily style
👥 125K  📈 4.5%

Emma Rodriguez
Fitness coach & wellness advocate | Helping you live your best life 💪
👥 180K  📈 7.1%
```

## Quick Debug Checklist

- [ ] Backend is running on port 5050
- [ ] Flutter app is rebuilt (flutter clean + flutter run)
- [ ] Logged in as Brand user
- [ ] On "Find Influencers" tab (second tab in bottom nav)
- [ ] Console shows detailed parsing logs
- [ ] API returns 200 with data
- [ ] Database has users with fullName field
- [ ] Backend populate includes fullName

## If All Else Fails

Delete and re-seed the database:

```bash
mongosh
use influcollb

# Delete all influencer data
db.users.deleteMany({ isInfluencer: true })
db.influencerprofiles.deleteMany({})

exit

# Re-seed
cd re-webapibackend
npm run seed:influencers

# Restart backend
npm run dev

# Rebuild Flutter app
cd ../MobileAppYear3Assignment
flutter clean
flutter pub get
flutter run
```

This will give you a fresh start with known good data.
