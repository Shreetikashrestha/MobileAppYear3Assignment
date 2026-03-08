# Real Influencer Data - Complete Guide

## Current Status: ✅ FULLY DYNAMIC

The Find Influencer feature now shows ONLY real influencers who have registered and created profiles. All seeded/static data has been removed.

---

## What Was Done

### 1. Removed Static Seeded Influencers
Deleted these fake accounts from database:
- ❌ Sarah Johnson
- ❌ Mike Chen
- ❌ Emma Rodriguez
- ❌ David Kim
- ❌ Lisa Anderson

### 2. Kept Real Influencers
These are actual registered users:
- ✅ shreetika (shreetika@gmail.com)
- ✅ influencer (influencer@gmail.com)
- ✅ influ (influ@gmail.com)
- ✅ New Test User (newtest@test.com)
- ✅ Test User (newtest2@test.com)
- ✅ Test Influencer (influencer@test.com)

---

## How Real Data is Loaded

### When Brand Opens Find Influencer Screen

**Step 1: List View**
```
Brand clicks "Find Influencers" tab
    ↓
Flutter calls: loadInfluencers()
    ↓
API Request: GET /api/profiles/influencers
    ↓
Backend queries MongoDB for ALL influencer profiles
    ↓
Returns: List of influencers with their data
    ↓
Flutter displays: Cards with name, bio, followers, etc.
```

**Data Shown in List:**
- Profile picture (or initials if none)
- Full name
- Bio (if filled)
- Niche/Category (if filled)
- Follower count (if added)
- Engagement rate (if added)

### When Brand Clicks on an Influencer

**Step 2: Profile View**
```
Brand clicks on influencer card
    ↓
Flutter calls: loadInfluencerProfile(userId)
    ↓
API Request: GET /api/profiles/{userId}
    ↓
Backend fetches:
  - User data (name, email, profile picture)
  - Profile data (bio, niches, social accounts)
    ↓
Returns: Complete influencer profile
    ↓
Flutter displays: Full profile screen
```

**Data Shown in Profile:**
- Large profile picture
- Full name
- Verified badge (if verified)
- Niche tags
- Statistics:
  - Follower count
  - Engagement rate
  - Number of platforms
- "Send Message" button (functional)
- About section (full bio)
- Platforms (Instagram, TikTok, YouTube, etc.)
- Social links with handles

---

## What Influencers Need to Fill

For their data to show up properly, influencers should complete their profile with:

### Required Fields (Always Show)
- ✅ Full Name (from registration)
- ✅ Email (from registration)

### Optional Fields (Show if Filled)
- Bio/About
- Niche/Category
- Social Media Accounts:
  - Platform (Instagram, TikTok, YouTube, etc.)
  - Handle (@username)
  - Follower count
  - Engagement rate
- Profile picture
- Location
- Languages

---

## Example: Shreetika's Profile

### If Shreetika Fills Her Profile:

**Profile Data:**
```json
{
  "userId": "...",
  "username": "shreetika",
  "bio": "Fashion & Lifestyle content creator | Sharing daily inspiration ✨",
  "niches": ["Fashion", "Lifestyle"],
  "socialAccounts": [
    {
      "platform": "instagram",
      "handle": "@shreetika",
      "followers": 50000,
      "engagementRate": 5.2
    },
    {
      "platform": "tiktok",
      "handle": "@shreetika",
      "followers": 35000,
      "engagementRate": 7.8
    }
  ],
  "location": {
    "city": "Kathmandu",
    "country": "Nepal"
  }
}
```

### What Brand Sees:

**In List View:**
```
Shreetika
Fashion & Lifestyle content creator | Sharing daily inspiration ✨
👥 50K  📈 5.2%
```

**In Profile View:**
```
[Profile Picture]

Shreetika
Fashion | Lifestyle

Followers: 50K
Engagement: 5.2%
Platforms: 2

[Send Message Button]

About
Fashion & Lifestyle content creator | Sharing daily inspiration ✨

Platforms
Instagram  TikTok

Social Links
INSTAGRAM
@shreetika

TIKTOK
@shreetika

Location
Kathmandu, Nepal
```

---

## Message Functionality

### How It Works

1. **Brand clicks "Send Message"** on influencer profile
2. **System creates/finds conversation** between brand and influencer
3. **Opens chat screen** with real-time messaging
4. **Messages are stored** in database
5. **Both parties can chat** in real-time

### Technical Flow:
```
Brand clicks "Send Message"
    ↓
Create virtual conversation object
    ↓
Navigate to ChatScreen
    ↓
ChatScreen loads/creates conversation
    ↓
Real-time messaging enabled
    ↓
Messages sync via polling (every 3 seconds)
```

---

## How Influencers Update Their Profiles

### Option 1: Through Profile Screen
1. Influencer logs in
2. Goes to Profile tab
3. Clicks "Edit Profile"
4. Fills in:
   - Bio
   - Niches
   - Social accounts
   - Location
5. Saves changes
6. Data immediately available to brands

### Option 2: Through API
Influencers can update via:
```
PUT /api/profiles/me
Authorization: Bearer {token}

{
  "bio": "New bio text",
  "niches": ["Fashion", "Lifestyle"],
  "socialAccounts": [
    {
      "platform": "instagram",
      "handle": "@username",
      "followers": 50000,
      "engagementRate": 5.2
    }
  ]
}
```

---

## Testing Real Data

### Test 1: View Shreetika's Profile
1. Login as Brand (brand@gmail.com / 123456)
2. Go to "Find Influencers" tab
3. See shreetika in the list
4. Click on her card
5. View her complete profile
6. All data comes from database

### Test 2: Send Message to Shreetika
1. On shreetika's profile
2. Click "Send Message"
3. Chat screen opens
4. Type and send a message
5. Message is saved to database
6. Shreetika can see it when she logs in

### Test 3: Update Profile as Shreetika
1. Login as Shreetika (shreetika@gmail.com / password)
2. Go to Profile tab
3. Click "Edit Profile"
4. Update bio, add social accounts
5. Save changes
6. Logout and login as Brand
7. View shreetika's profile
8. See updated data

---

## Verification Checklist

### For Brands:
- [ ] Can see list of real influencers
- [ ] Can see influencer names
- [ ] Can see bios (if filled)
- [ ] Can see follower counts (if added)
- [ ] Can click on influencer card
- [ ] Can view full profile
- [ ] Can see all profile data
- [ ] Can click "Send Message"
- [ ] Can send and receive messages

### For Influencers:
- [ ] Can register as influencer
- [ ] Can login successfully
- [ ] Can edit profile
- [ ] Can add bio
- [ ] Can add social accounts
- [ ] Can add niches
- [ ] Can upload profile picture
- [ ] Changes reflect immediately
- [ ] Can receive messages from brands

---

## Database Structure

### Users Collection
```javascript
{
  _id: ObjectId,
  fullName: "Shreetika",
  email: "shreetika@gmail.com",
  password: "hashed",
  isInfluencer: true,
  profilePicture: "url or null",
  createdAt: Date,
  updatedAt: Date
}
```

### InfluencerProfiles Collection
```javascript
{
  _id: ObjectId,
  userId: ObjectId (ref: User),
  username: "shreetika",
  bio: "Fashion & Lifestyle content creator...",
  niches: ["Fashion", "Lifestyle"],
  socialAccounts: [
    {
      platform: "instagram",
      handle: "@shreetika",
      followers: 50000,
      engagementRate: 5.2
    }
  ],
  location: {
    city: "Kathmandu",
    country: "Nepal"
  },
  isVerified: false,
  createdAt: Date,
  updatedAt: Date
}
```

---

## API Endpoints Used

### 1. Get All Influencers
```
GET /api/profiles/influencers
Authorization: Bearer {token}

Response:
{
  "success": true,
  "count": 6,
  "data": [
    {
      "_id": "...",
      "userId": {
        "_id": "...",
        "fullName": "Shreetika",
        "email": "shreetika@gmail.com",
        "profilePicture": null
      },
      "username": "shreetika",
      "bio": "...",
      "niches": ["Fashion"],
      "socialAccounts": [...]
    }
  ]
}
```

### 2. Get Influencer Profile
```
GET /api/profiles/{userId}
Authorization: Bearer {token}

Response:
{
  "success": true,
  "user": {
    "_id": "...",
    "fullName": "Shreetika",
    "email": "shreetika@gmail.com"
  },
  "profile": {
    "bio": "...",
    "niches": [...],
    "socialAccounts": [...]
  }
}
```

### 3. Update Profile (Influencer)
```
PUT /api/profiles/me
Authorization: Bearer {token}

Body:
{
  "bio": "New bio",
  "niches": ["Fashion", "Lifestyle"],
  "socialAccounts": [...]
}
```

---

## Summary

✅ **Only real influencers** are shown (no static data)
✅ **All data is dynamic** from MongoDB database
✅ **Profiles load in real-time** when clicked
✅ **Message functionality works** between brands and influencers
✅ **Influencers can update** their profiles anytime
✅ **Changes reflect immediately** for brands

The system is now fully dynamic with real user data!
