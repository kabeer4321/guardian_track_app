
# 📍 Guardian Route App

Guardian Route is a high-reliability background location tracking application built using Flutter.
The app continuously tracks user movement in the background, stores data locally, and allows route visualization using Google Maps.

---

# 🏗 Architecture

This project follows **Clean Architecture** with **BLoC** for state management.

```
lib/
 ├── core/
 ├── data/
 ├── domain/
 ├── presentation/
```

* **Presentation Layer** → UI + BLoC
* **Domain Layer** → Entities + Repository Contracts + UseCases
* **Data Layer** → Local Data Source + Repository Implementation
* **Core** → Services & Utilities

---

# 📦 Packages Used & Why

---

## 🔹 1. flutter_background_service

**Purpose:**
Runs the location tracking service even when the app is minimized or killed.

**Why Used:**

* Required for continuous background tracking.
* Runs as a foreground service on Android.
* Keeps tracking active even if user closes the app.
* Allows communication between UI and background isolate using `service.invoke()`.

**Used For:**

* Starting/stopping tracking
* Running periodic location capture every 10 seconds
* Maintaining persistent foreground notification

---

## 🔹 2. flutter_local_notifications

**Purpose:**
Creates foreground service notification.

**Why Used:**

* Android requires a visible notification when running a foreground service.
* Shows “Live Tracking Active” notification.
* Ensures compliance with Android background execution policies.

---

## 🔹 3. geolocator

**Purpose:**
Fetches device GPS location.

**Why Used:**

* Retrieves real-time latitude & longitude.
* Checks if location services are enabled.
* Handles high accuracy location updates.

**Used For:**

* Capturing live location every 10 seconds.
* Handling location errors & disabled states.

---

## 🔹 4. sqflite

**Purpose:**
Local SQLite database storage.

**Why Used:**

* Stores all location logs persistently.
* Works offline.
* Ensures no data loss even if app crashes.

**Database Table:**

```
locations(
  id INTEGER PRIMARY KEY,
  lat TEXT,
  lng TEXT,
  time TEXT,
  sessionId TEXT,
  status TEXT
)
```

---

## 🔹 5. flutter_bloc

**Purpose:**
State management.

**Why Used:**

* Separates UI from business logic.
* Controls tracking state.
* Reloads data when background service updates.
* Manages StartTracking / StopTracking events cleanly.

---

## 🔹 6. google_maps_flutter

**Purpose:**
Displays map inside app.

**Why Used:**

* Shows current user position.
* Centers map on last recorded location.
* Visual representation of live tracking.

---

## 🔹 7. url_launcher

**Purpose:**
Launches external Google Maps.

**Why Used:**

* Opens single location marker.
* Opens full session route with waypoints.
* Uses Google Maps Directions API format.

Example:

```
https://www.google.com/maps/dir/?api=1
```

---

## 🔹 8. expandable

**Purpose:**
Expandable session UI in History screen.

**Why Used:**

* Groups locations by sessionId.
* Allows collapsing/expanding sessions.
* Keeps UI clean and readable.

---

## 🔹 9. path + sqflite integration

Used to:

* Get database path
* Create persistent local storage file

---

# 🔐 Permissions Used

```xml
ACCESS_FINE_LOCATION
ACCESS_BACKGROUND_LOCATION
FOREGROUND_SERVICE
FOREGROUND_SERVICE_LOCATION
POST_NOTIFICATIONS
```

These ensure:

* Foreground + background tracking
* Android 13+ notification compliance
* Foreground service location access

---

# 🔄 How Tracking Works

1. User taps **Start Tracking**
2. Background service starts as Foreground Service
3. Session ID is generated
4. Every 10 seconds:

    * Location is fetched
    * Saved to SQLite
    * UI is updated via service.invoke("update")
5. User taps **Stop Tracking**
6. Timer cancels
7. Service stops

---

# 🧠 Key Features

✅ Background tracking even if app is killed
✅ Persistent local storage
✅ Session-based tracking
✅ Route visualization in Google Maps
✅ Clean Architecture
✅ BLoC state management
✅ Offline data reliability

---


