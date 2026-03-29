# Firebase Backend Service - E-Waste Component Database

**Region:** `asia-south1` (Mumbai)  
**Firebase Version:** `v10`  
**Runtime:** Node.js 18+

This backend service handles image uploads to Firebase Storage and metadata creation in Firestore for the e-waste upcycling app.

---

## 📋 Setup Instructions

### 1. Install Dependencies
```bash
npm install
```

### 2. Get Firebase Service Account
1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your project
3. Navigate to **Settings ⚙️ > Service Accounts**
4. Click **Generate New Private Key**
5. Save the JSON file as `firebase-service-account.json` in the project root

### 3. Configure Environment Variables
```bash
cp .env.example .env
```

Edit `.env` with your Firebase details:
```env
FIREBASE_SERVICE_ACCOUNT=./firebase-service-account.json
STORAGE_BUCKET=your-project.appspot.com
FIREBASE_PROJECT_ID=your-project-id
PORT=3000
```

### 4. Update Firebase Security Rules

**Firestore Security Rules:**
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /components/{docId} {
      allow create: if request.auth != null;
      allow read: if request.auth != null;
      allow update: if request.auth != null && hasRole('admin');
      allow delete: if request.auth != null && hasRole('admin');
    }
  }
  
  function hasRole(role) {
    return get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == role;
  }
}
```

**Firebase Storage Rules:**
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /junk_library/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.resource.size < 25 * 1024 * 1024; // 25MB max
    }
  }
}
```

---

## 🚀 Running the Server

### Development
```bash
npm run dev
```

### Production
```bash
npm start
```

Server will run on `http://localhost:3000`

---

## 📡 API Endpoints

### 1. Upload Component
**POST** `/api/components/upload`

**Request Body:**
```json
{
  "localImageURI": "/path/to/image.jpg",
  "specs": {
    "component_name": "Motherboard",
    "origin": "E-waste center A",
    "destination_project": "Robotics Research",
    "time_range": "2024-01-01 to 2024-03-29",
    "dismantle_difficulty": "hard",
    "user_description": "Damaged but salvageable",
    "mismatch_flag": false
  }
}
```

**Response (201):**
```json
{
  "success": true,
  "data": {
    "docId": "abc123def456",
    "imageUrl": "https://storage.googleapis.com/...",
    "component_name": "Motherboard",
    "verification_status": "pending",
    "created_at": "2024-03-29T10:30:00Z",
    "dismantle_difficulty": "hard"
  },
  "message": "Component uploaded successfully"
}
```

**Error Responses:**
- `400 Bad Request` - Missing or invalid fields
- `403 Forbidden` - Permission Denied (Firebase credentials issue)
- `503 Service Unavailable` - Network Timeout

---

### 2. Get Component
**GET** `/api/components/:docId`

**Response:**
```json
{
  "success": true,
  "data": {
    "docId": "abc123def456",
    "imageUrl": "https://storage.googleapis.com/...",
    "component_name": "Motherboard",
    "verification_status": "pending",
    "created_at": "2024-03-29T10:30:00Z",
    "dismantle_difficulty": "hard",
    "origin": "E-waste center A",
    "destination_project": "Robotics Research",
    "user_description": "Damaged but salvageable"
  }
}
```

---

### 3. Update Verification Status
**PATCH** `/api/components/:docId/verify`

**Request Body:**
```json
{
  "status": "verified"
}
```

Valid statuses: `pending`, `verified`, `rejected`

**Response:**
```json
{
  "success": true,
  "message": "Component status updated to verified"
}
```

---

### 4. Query Components by Status
**GET** `/api/components?status=pending&limit=20`

**Query Parameters:**
- `status` - Filter by status (default: `pending`)
- `limit` - Result limit (default: 20, max: 100)

**Response:**
```json
{
  "success": true,
  "count": 5,
  "data": [
    {
      "docId": "abc123def456",
      "component_name": "Motherboard",
      "verification_status": "pending",
      "created_at": "2024-03-29T10:30:00Z"
    }
  ]
}
```

---

## 🔧 Firestore Data Schema

**Collection:** `components`

```javascript
{
  docId: "auto-generated",
  
  // Required fields
  imageUrl: "https://storage.googleapis.com/...",
  component_name: "Motherboard",
  verification_status: "pending", // pending | verified | rejected
  created_at: Timestamp.now(),    // Server timestamp
  dismantle_difficulty: "hard",   // easy | medium | hard
  
  // Additional metadata
  origin: "E-waste center A",
  destination_project: "Robotics Research",
  time_range: "2024-01-01 to 2024-03-29",
  user_description: "Damaged but salvageable",
  storage_path: "junk_library/1711758600000_image.jpg",
  upload_timestamp: Timestamp.now(),
  region: "asia-south1",
  status: "active",
  mismatch_flag: false,
  updated_at: Timestamp.now() // Only on updates
}
```

---

## ⚠️ Error Handling

The service includes specific error handling for mobile environments:

### PERMISSION_DENIED (403)
```json
{
  "success": false,
  "code": "PERMISSION_DENIED",
  "message": "Permission Denied: Unable to upload or save data. Check Firebase credentials and security rules.",
  "originalError": "..."
}
```

**Solutions:**
- Verify Firebase Service Account is correct
- Check Firestore and Storage security rules
- Ensure `FIREBASE_SERVICE_ACCOUNT` path is correct

### NETWORK_TIMEOUT (503)
```json
{
  "success": false,
  "code": "NETWORK_TIMEOUT",
  "message": "Network Timeout: Please check your connection and try again.",
  "originalError": "..."
}
```

**Solutions:**
- Check internet connection
- Increase timeout values if needed
- Retry the request

### FILE_NOT_FOUND (400)
```json
{
  "success": false,
  "code": "FILE_NOT_FOUND",
  "message": "File not found: /path/to/image.jpg",
  "originalError": "..."
}
```

---

## 📱 Integration with Flutter App

### 1. Update Analysis Screen
```dart
import 'package:http/http.dart' as http;

Future<void> _uploadToBackend() async {
  try {
    const endpoint = 'http://your-server.com/api/components/upload';
    
    final response = await http.post(
      Uri.parse(endpoint),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'localImageURI': _selectedImage?.path,
        'specs': {
          'component_name': _descController.text,
          'origin': _originController.text,
          'destination_project': _projectController.text,
          'time_range': _timeController.text,
          'dismantle_difficulty': 'medium',
          'user_description': _descController.text,
        }
      }),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      print('Upload successful: ${data['data']['docId']}');
    } else {
      throw Exception('Upload failed: ${response.body}');
    }
  } catch (e) {
    print('Error: $e');
  }
}
```

---

## 🧪 Testing

### Test Upload
```bash
curl -X POST http://localhost:3000/api/components/upload \
  -H "Content-Type: application/json" \
  -d '{
    "localImageURI": "/path/to/image.jpg",
    "specs": {
      "component_name": "Test Component",
      "origin": "Test",
      "destination_project": "Test",
      "time_range": "2024",
      "dismantle_difficulty": "easy"
    }
  }'
```

### Health Check
```bash
curl http://localhost:3000/health
```

---

## 📊 Monitoring

View logs in Firebase Console:
- **Cloud Logging:** Monitor upload activity
- **Firestore:** Check document creation
- **Cloud Storage:** Monitor storage usage

---

## 🔐 Security Checklist

- ✅ Download service account key from Firebase Console
- ✅ Update `.gitignore` to exclude `firebase-service-account.json`
- ✅ Enable Firestore Security Rules
- ✅ Enable Cloud Storage Security Rules
- ✅ Use HTTPS in production
- ✅ Implement authentication in API endpoints
- ✅ Set up rate limiting for uploads

---

## 📚 Resources

- [Firebase Admin SDK Documentation](https://firebase.google.com/docs/admin/setup)
- [Firestore Security Rules](https://firebase.google.com/docs/firestore/security/start)
- [Cloud Storage Security](https://firebase.google.com/docs/storage/security)
- [Asia-South1 Region Info](https://cloud.google.com/compute/docs/regions-zones)

---

**Created:** March 29, 2026  
**Region:** asia-south1 (Mumbai)  
**Status:** Production Ready
