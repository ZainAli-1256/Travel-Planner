# Smart Travel Planner

Smart Travel Planner is a Flutter app that combines trip planning, itinerary management, real-time group chat, and travel intelligence (places + weather) in one experience. It is built around Firebase Auth + Firestore for multi-user collaboration, and integrates free public APIs for city search, attractions, and weather.

## Why this app

- Plan trips end-to-end: create trips, add dates, and manage daily plans.
- Explore destinations with live data: search cities and nearby places.
- Coordinate with travel partners: one real-time chat per trip.
- Learn core mobile skills: Firebase auth, Firestore streams, and REST APIs.

## Core features (mapped to code)

- **Authentication (Firebase Auth)**: email signup, login, password reset.
- **User profile completion**: rich traveler profile (preferences, docs, emergency contact).
- **Trip planning**: create, edit, and delete trips with dates and notes.
- **Itinerary management**: add, edit, delete daily plans per trip.
- **Explore places**: city search + nearby attractions, food, hotels via OpenStreetMap.
- **Weather**: current conditions + 5-day forecast for the trip destination.
- **Group chat (core)**: real-time chat per trip using Firestore streams.
- **Local notifications**: chat alerts for new messages when not in the chat tab.
- **Trip history and reuse**: duplicate past trips with new dates.

## Tech stack

- Flutter (Material 3)
- Firebase: Auth + Firestore
- APIs: OpenWeatherMap, GeoDB Cities (RapidAPI), OpenStreetMap (Overpass + Nominatim)
- Local notifications: flutter_local_notifications

## App flow (high level)

1. **Splash → Onboarding → Auth**
	 - Onboarding completion is stored in SharedPreferences.
2. **Profile gate**
	 - If profile is incomplete, the user is prompted to finish their profile.
3. **Dashboard**
	 - Lists upcoming and past trips, search, and quick navigation.
4. **Trip detail**
	 - Tabs: Plan (itinerary), Chat, Places, Weather.

## Data model (Firestore)

Firestore collections are structured as follows:

- **users (collection)**
	- doc id: user uid
	- fields: name, email, profileComplete, travel preferences, emergency contact, etc.
- **trips (collection)**
	- doc id: tripId
	- fields: title, destination, startDate, endDate, createdBy, members[], notes
	- subcollection **itinerary**
		- doc id: itemId
		- fields: date, title, category, startTime, description, dayLabel, sortOrder
	- subcollection **messages**
		- doc id: messageId
		- fields: senderId, senderName, text, sentAt, isRead

See the service layer for exact field names and serialization:

- [lib/services/firestore_service.dart](lib/services/firestore_service.dart)
- [lib/models/trip_model.dart](lib/models/trip_model.dart)
- [lib/models/itinerary_item_model.dart](lib/models/itinerary_item_model.dart)
- [lib/models/chat_message_model.dart](lib/models/chat_message_model.dart)
- [lib/models/user_model.dart](lib/models/user_model.dart)

## Key screens

- Auth: login and signup with validation and animations.
- Dashboard: upcoming/past trips, search, and entry to trip detail.
- Create/Edit trip: destination, date range, notes.
- Itinerary: add, edit, and delete daily plans.
- Places: explore attractions/food/hotels by category.
- Weather: current conditions + 5-day forecast.
- Chat: real-time messages inside each trip.

## API integrations

- **GeoDB Cities API (RapidAPI)**
	- Used for city search when planning a trip.
- **OpenStreetMap Overpass API**
	- Used to fetch nearby places and attractions.
- **OpenStreetMap Nominatim**
	- Used for reverse geocoding when a place has no address.
- **OpenWeatherMap API**
	- Used for current weather and forecast.

API keys are configured in [lib/core/constants/api_keys.dart](lib/core/constants/api_keys.dart). Replace the placeholder keys with your own. Consider moving keys to build-time secrets or environment variables for production use.

## Notifications

Local notifications are used for chat messages when the user is not inside the chat tab for that trip. Read state is stored locally using SharedPreferences.

Relevant files:

- [lib/services/chat_notification_service.dart](lib/services/chat_notification_service.dart)
- [lib/services/chat_state_store.dart](lib/services/chat_state_store.dart)
- [lib/services/local_notification_service.dart](lib/services/local_notification_service.dart)

## Project structure

```
lib/
	core/
		constants/
		utils/
		widgets/
	models/
	services/
	views/
```

## Setup

### 1) Install dependencies

```
flutter pub get
```

### 2) Firebase setup

This project uses Firebase Auth + Firestore.

1. Create a Firebase project.
2. Register Android and iOS apps.
3. Run FlutterFire CLI to generate [lib/firebase_options.dart](lib/firebase_options.dart).
4. Enable Email/Password auth in Firebase console.

### 3) API keys

Add your API keys in [lib/core/constants/api_keys.dart](lib/core/constants/api_keys.dart):

- `ApiKeys.openWeather` for OpenWeatherMap
- `ApiKeys.geoDbRapidApi` for GeoDB Cities (RapidAPI)

### 4) Run the app

```
flutter run
```

## How the group chat works

- Each trip has one chat room, stored under `trips/{tripId}/messages`.
- Messages are streamed in real time using Firestore snapshots.
- Local notifications trigger for new messages when the user is not currently in that trip chat.

## Notable design choices

- **Glassmorphism UI** and a consistent navy/amber palette.
- **Single source of truth** for data via Firestore streams.
- **Trip reuse** duplicates itinerary items and shifts dates for a new trip.

## Known limitations

- API keys are stored directly in code for student/demo use.
- Local notification permissions currently target Android.
- Places data quality depends on OpenStreetMap tags and availability.

## Learning outcomes

- Firebase authentication and Firestore data modeling
- Real-time multi-user chat
- API integration and error handling
- Flutter UI theming and animation

## Credits

- Photos: Unsplash (used for aesthetic backgrounds)
- Data: OpenWeatherMap, GeoDB Cities, OpenStreetMap
