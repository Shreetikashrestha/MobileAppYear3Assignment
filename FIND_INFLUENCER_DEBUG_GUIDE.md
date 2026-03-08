# Find Influencer Feature - Debugging Guide

## Issue Description
When opening the Find Influencer screen or clicking on an influencer profile, data is not displaying correctly. Only the "Send Message" button is visible.

## Root Cause Analysis

The issue is likely one of the following:

### 1. Data Not Being Fetched from Backend
- Backend might not be running
- Database might be empty
- API endpoint might be incorrect

### 2. Data Parsing Issues
- Backend response format doesn't match expected format
- Fields are null or missing
- Type conversion errors

### 3. UI Rendering Issues
- Conditional rendering hiding content
- Layout issues
- Widget not rebuilding

## Debugging Steps

### Step 1: Verify Backend is Running

```bash
cd re-webapibackend
npm run dev
```

Expected output:
```
Server running on port 5050
MongoDB connected successfully
```

### Step 2: Verify Database Has Data

```bash
cd re-webapibackend
npm run seed:influencers
```

Expected output:
```
🌱 Starting influencer seeding...
✅ Connected to MongoDB
🌱 Seeding 5 influencers...
✅ Created user: Mike Chen (mike.chen@example.com)
✅ Created profile for: Mike Chen
...
🎉 Seeding completed successfully!
📊 Total influencer profiles in database: 7
```

### Step 3: Test API Endpoint Directly

Use curl or Postman to test the endpoint:

```bash
# First, login to get a token
curl -X POST http://127.0.0.1:5050/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"shreevasini","password":"123456"}'

# Copy the token from response, then:
curl -X GET http://127.0.0.1:5050/api/profiles/influencers \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

Expected response:
```json
{
  "success": true,
  "count": 7,
  "data": [
    {
      "_id": "...",
      "userId": {
        "_id": "...",
        "fullName": "Mike Chen",
        "email": "mike.chen@example.com",
        "profilePicture": null
      },
      "username": "mikechen",
      "bio": "Tech reviewer & gadget enthusiast...",
      "niches": ["Technology", "Reviews"],
      "socialAccounts": [
        {
          "platform": "youtube",
          "handle": "@MikeChenTech",
          "followers": 250000,
          "engagementRate": 5.8
        }
      ],
      "isVerified": false
    }
  ]
}
```

### Step 4: Check Flutter Console Logs

When you open the Find Influencer screen, you should see:

```
🔄 [InfluencerViewModel] Starting to load influencers
🔍 [InfluencerDataSource] Fetching from /api/profiles/influencers
🌐 [ApiClient] Request: GET http://127.0.0.1:5050/api/profiles/influencers
✅ [ApiClient] Response: 200 http://127.0.0.1:5050/api/profiles/influencers
📊 [InfluencerDataSource] Response status: 200
📊 [InfluencerDataSource] Found 7 influencers in response
🔄 [InfluencerDataSource] Parsing influencer: ...
✅ [InfluencerDataSource] User data: {fullName: Mike Chen, ...}
✅ [InfluencerDataSource] Successfully parsed: Mike Chen
✅ [InfluencerViewModel] Successfully loaded 7 influencers
```

### Step 5: Check Backend Console Logs

```
🔍 [ProfileController] getAllInfluencers called
🔍 [ProfileController] Query params: {}
🔍 [ProfileController] Query filter: {}
📊 [ProfileController] Found influencers count: 7
📊 [ProfileController] First influencer: {
  id: ...,
  userId: ...,
  username: 'mikechen'
}
```

## Common Issues and Solutions

### Issue 1: Empty Response (count: 0)

**Symptom**: API returns `{"success": true, "count": 0, "data": []}`

**Solution**:
```bash
# Run the seeder to populate database
cd re-webapibackend
npm run seed:influencers
```

### Issue 2: 401 Unauthorized

**Symptom**: API returns 401 error

**Solution**:
- Ensure you're logged in
- Check if auth token is being sent
- Token might be expired - login again

### Issue 3: Connection Refused

**Symptom**: `Connection refused` or `Network error`

**Solution**:
- Verify backend is running on port 5050
- Check if baseUrl in Flutter app matches backend URL
- For iOS Simulator: use `http://127.0.0.1:5050`
- For Android Emulator: use `http://10.0.2.2:5050`

### Issue 4: Data Parsing Errors

**Symptom**: Logs show parsing errors

**Solution**:
- Check backend response format
- Verify all required fields are present
- Check for null values in critical fields

### Issue 5: UI Not Updating

**Symptom**: Data loads but UI doesn't show it

**Solution**:
- Hot restart the app (not just hot reload)
- Check if state is being updated correctly
- Verify widget is watching the correct provider

## Manual Testing Checklist

### Test 1: List View
- [ ] Open Find Influencer screen
- [ ] See loading indicator
- [ ] See list of influencers with:
  - [ ] Profile pictures or initials
  - [ ] Full names
  - [ ] Niches (tags)
  - [ ] Follower counts
  - [ ] Engagement rates
  - [ ] Bios (truncated)

### Test 2: Pull to Refresh
- [ ] Swipe down on the list
- [ ] See refresh indicator
- [ ] List updates with latest data

### Test 3: Search
- [ ] Type in search bar
- [ ] Results filter in real-time
- [ ] Clear search shows all results

### Test 4: Profile View
- [ ] Click on an influencer card
- [ ] See loading indicator
- [ ] Profile screen shows:
  - [ ] Large profile picture
  - [ ] Full name
  - [ ] Niche tag
  - [ ] Stats (Followers, Engagement, Platforms)
  - [ ] "Send Message" button
  - [ ] Bio section
  - [ ] Platforms chips
  - [ ] Social links

## Quick Fix Commands

### Reset Everything
```bash
# Stop backend
# Kill any process on port 5050
lsof -ti:5050 | xargs kill -9

# Start fresh
cd re-webapibackend
npm run dev

# In another terminal, seed data
cd re-webapibackend
npm run seed:influencers

# Restart Flutter app
cd MobileAppYear3Assignment
flutter clean
flutter pub get
flutter run
```

### Check Database Directly
```bash
# Connect to MongoDB
mongosh

# Switch to your database
use influcollb

# Count influencer profiles
db.influencerprofiles.countDocuments()

# View all influencer profiles
db.influencerprofiles.find().pretty()

# Check if profiles have userId populated
db.influencerprofiles.aggregate([
  {
    $lookup: {
      from: "users",
      localField: "userId",
      foreignField: "_id",
      as: "user"
    }
  },
  { $limit: 1 }
])
```

## Expected Behavior

### Find Influencer Screen
1. Opens with loading indicator
2. Fetches influencers from API
3. Displays list of influencer cards
4. Each card shows:
   - Avatar (image or initial)
   - Full name
   - Niche tag (if available)
   - Follower count (if available)
   - Engagement rate (if available)
   - Bio preview (if available)
   - Chevron icon

### Influencer Profile Screen
1. Opens with loading indicator
2. Fetches individual profile from API
3. Displays:
   - Header with gradient background
   - Large profile picture
   - Verified badge (if verified)
   - Full name
   - Niche tag
   - Stats row (Followers, Engagement, Platforms)
   - "Send Message" button
   - About section with full bio
   - Platforms section with chips
   - Social Links section with platform cards

## Files to Check

### Flutter App
1. `lib/features/influencer/presentation/pages/find_influencer_screen.dart`
2. `lib/features/influencer/presentation/pages/influencer_profile_screen.dart`
3. `lib/features/influencer/presentation/widgets/influencer_card.dart`
4. `lib/features/influencer/presentation/view_model/influencer_view_model.dart`
5. `lib/features/influencer/data/datasources/influencer_remote_datasource.dart`
6. `lib/features/influencer/data/models/influencer_model.dart`

### Backend
1. `src/controllers/profile.controller.ts`
2. `src/models/influencer_profile.model.ts`
3. `src/routes/profile.route.ts`

## Next Steps

1. Run through all debugging steps above
2. Check console logs for errors
3. Verify data is in database
4. Test API endpoints directly
5. Hot restart Flutter app
6. If still not working, share the console logs for further analysis
