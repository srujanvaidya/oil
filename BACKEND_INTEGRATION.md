# FasalMitra - Backend Integration Documentation

This document provides comprehensive information about backend API endpoints required by the FasalMitra Flutter frontend application.

## Table of Contents
- [Overview](#overview)
- [API Configuration](#api-configuration)
- [Authentication Endpoints](#authentication-endpoints)
- [Listing Endpoints](#listing-endpoints)
- [Data Models](#data-models)
- [Error Handling](#error-handling)

---

## Overview

The frontend uses a centralized `ApiService` class located at `lib/services/api.dart` for all HTTP requests. Currently, the app falls back to mock data when API calls fail, allowing development to continue without a backend.

**Base URL Configuration:**
- Set via environment variable: `API_BASE_URL`
- Default: `https://your-backend.com`
- All endpoints are relative to this base URL

---

## API Configuration

### ApiService (`lib/services/api.dart`)

The `ApiService` singleton handles all HTTP requests with the following features:
- Automatic Bearer token authentication
- JSON request/response handling
- Query parameter support
- Error handling with `ApiException`

**Usage Example:**
```dart
final response = await ApiService.instance.get(
  '/api/listings/marketplace',
  token: 'user_jwt_token',
  queryParameters: {'sort': 'distance', 'category': 'Seeds'},
);
```

---

## Authentication Endpoints

### 1. Send OTP
**File:** `lib/services/auth_service.dart` (Line 28)

```
POST /api/auth/send-otp
```

**Request Body:**
```json
{
  "phone": "+919876543210",
  "captchaToken": "recaptcha_token_here"
}
```

**Response:**
```json
{
  "success": true,
  "message": "OTP sent successfully"
}
```

---

### 2. Verify OTP
**File:** `lib/services/auth_service.dart` (Line 42)

```
POST /api/auth/verify-otp
```

**Request Body:**
```json
{
  "phone": "+919876543210",
  "otp": "123456"
}
```

**Response:**
```json
{
  "token": "jwt_token_here",
  "user": {
    "id": "user_id",
    "phone": "+919876543210",
    "name": "Farmer Name",
    "role": "farmer"
  }
}
```

**Notes:**
- JWT token is stored in `SharedPreferences` with key `backend_jwt`
- Token is used for all authenticated requests

---

### 3. Register User
**File:** `lib/services/auth_service.dart` (Line 60)

```
POST /api/auth/register
```

**Request Body:**
```json
{
  "phone": "+919876543210",
  "name": "Farmer Name",
  "role": "farmer"
}
```

**Response:**
```json
{
  "success": true,
  "user": {
    "id": "user_id",
    "phone": "+919876543210",
    "name": "Farmer Name",
    "role": "farmer"
  }
}
```

---

### 4. Get User Profile
**File:** `lib/services/auth_service.dart` (Line 76)

```
GET /api/auth/profile
```

**Headers:**
```
Authorization: Bearer {jwt_token}
```

**Response:**
```json
{
  "id": "user_id",
  "phone": "+919876543210",
  "name": "Farmer Name",
  "role": "farmer",
  "email": "farmer@example.com",
  "address": "Farm Address"
}
```

---

### 5. Get Captcha
**File:** `lib/services/auth_service.dart` (Line 88)

```
GET /api/auth/captcha
```

**Response:**
```json
{
  "captchaId": "unique_captcha_id",
  "captchaImage": "base64_encoded_image_data"
}
```

---

## Listing Endpoints

### 1. Get Marketplace Listings
**File:** `lib/services/listing_service.dart` (Line 147)

```
GET /api/listings/marketplace
```

**Query Parameters:**
- `sort`: `distance` | `price_high` | `price_low` | `date_recent`
- `category`: `Seeds` | `Grains` | `Vegetables` | `Fruits` (optional)
- `date_from`: ISO 8601 date string (optional)
- `date_to`: ISO 8601 date string (optional)

**Example:**
```
GET /api/listings/marketplace?sort=distance&category=Seeds&date_from=2024-01-01T00:00:00Z
```

**Response:**
```json
{
  "listings": [
    {
      "id": "listing_123",
      "title": "Organic Wheat",
      "price": 50.0,
      "priceUnit": "/kg",
      "description": "High quality organic wheat",
      "imageUrls": [
        "https://example.com/image1.jpg",
        "https://example.com/image2.jpg"
      ],
      "sellerName": "Farmer Name",
      "farmerProfileImage": "https://example.com/profile.jpg",
      "category": "Grains",
      "rating": 4.5,
      "certificateGrade": "Grade A",
      "isCertified": true,
      "processingDate": "2024-11-20T10:30:00Z",
      "quantity": 100.0,
      "quantityUnit": "kg",
      "distance": 5.5
    }
  ]
}
```

**Sorting Logic:**
- `distance`: Sort by distance ascending (closest first)
- `price_high`: Sort by price descending (highest first)
- `price_low`: Sort by price ascending (lowest first)
- `date_recent`: Sort by processingDate descending (most recent first)

**Filtering Logic:**
- `category`: Filter listings where category matches exactly
- `date_from`: Filter listings where processingDate >= date_from
- `date_to`: Filter listings where processingDate <= date_to

---

### 2. Get Recent Listings
**File:** `lib/services/listing_service.dart` (Line 72)

```
GET /api/listings/recent?limit=10
```

**Query Parameters:**
- `limit`: Number of listings to return (default: 10)

**Response:**
```json
{
  "listings": [
    {
      "id": "listing_123",
      "title": "Organic Wheat",
      "price": 50.0,
      "priceUnit": "/kg",
      "description": "High quality organic wheat",
      "imageUrls": ["https://example.com/image1.jpg"],
      "sellerName": "Farmer Name",
      "farmerProfileImage": "https://example.com/profile.jpg",
      "category": "Grains",
      "rating": 4.5,
      "certificateGrade": "Grade A",
      "isCertified": true,
      "processingDate": "2024-11-20T10:30:00Z",
      "quantity": 100.0,
      "quantityUnit": "kg",
      "distance": 5.5
    }
  ]
}
```

---

### 3. Get Listings by Category
**File:** `lib/services/listing_service.dart` (Line 100)

```
GET /api/listings/category/{category}
```

**Path Parameters:**
- `category`: Category name (e.g., "Seeds", "Grains")

**Example:**
```
GET /api/listings/category/Seeds
```

**Response:** Same as marketplace listings response

---

### 4. Create Listing
**File:** `lib/services/listing_service.dart` (Line 234)

```
POST /api/listings/
```

**Headers:**
```
Authorization: Bearer {jwt_token}
Content-Type: multipart/form-data
```

**Form Data:**
- `title`: string (required)
- `category`: string (required)
- `quantity`: number (required)
- `price`: number (required)
- `processing_date`: ISO 8601 date string (required)
- `location`: string (required, e.g., "12.9716° N, 77.5946° E (Bangalore)")
- `certificate`: file (required, image/pdf)
- `image`: file (required, image)

**Response:**
```json
{
  "success": true,
  "listingId": "listing_123",
  "message": "Listing created successfully"
}
```

**Notes:**
- This is a multipart/form-data request for file uploads
- Frontend currently uses mock file paths; implement actual file upload
- Location is currently a mock string; consider using lat/long coordinates

---

## Data Models

### ListingData Model
**File:** `lib/services/listing_service.dart` (Line 1)

```dart
class ListingData {
  final String id;
  final String title;
  final double price;
  final String priceUnit;
  final String? description;
  final List<String> imageUrls;
  final String? sellerName;
  final String? farmerProfileImage;
  final String? category;
  final double? rating;
  final String? certificateGrade;
  final bool isCertified;
  final DateTime? processingDate;
  final double? quantity;
  final String? quantityUnit;
  final double? distance; // Distance in km from user
}
```

**JSON Parsing:**
The model includes a `fromJson` factory constructor (Line 21) that handles:
- Type conversions (num to double)
- Null safety
- Default values
- Date parsing from ISO 8601 strings

---

## Error Handling

### ApiException
**File:** `lib/services/api.dart` (Line 72)

All API errors throw `ApiException` with:
- `statusCode`: HTTP status code
- `message`: Error message from response body

**Example Error Response:**
```json
{
  "error": "Invalid credentials",
  "statusCode": 401
}
```

**Frontend Handling:**
```dart
try {
  final response = await ApiService.instance.get('/api/endpoint');
} catch (e) {
  if (e is ApiException) {
    print('API Error ${e.statusCode}: ${e.message}');
  }
}
```

**Fallback Behavior:**
- Most services fall back to mock data on API failure
- This allows frontend development without backend
- Check console for "API call failed, using mock data" messages

---

## Testing & Development

### Current Mock Data Behavior

All listing services currently use mock data as fallback:
1. API call is attempted
2. If it fails (network error, 404, etc.), mock data is used
3. Console logs indicate when mock data is being used

### Removing Mock Fallbacks

To make API calls required (fail without backend):
1. Remove try-catch blocks in service methods
2. Remove mock data generation code
3. Let `ApiException` propagate to UI

### Environment Configuration

Set the backend URL before building:
```bash
flutter run --dart-define=API_BASE_URL=https://your-backend.com
```

Or in production build:
```bash
flutter build web --dart-define=API_BASE_URL=https://your-backend.com
```

---

## Authentication Flow

1. **User enters phone number** → `POST /api/auth/send-otp`
2. **User enters OTP** → `POST /api/auth/verify-otp`
3. **JWT token stored** in `SharedPreferences` (key: `backend_jwt`)
4. **Token used** in Authorization header for all authenticated requests
5. **Profile fetched** → `GET /api/auth/profile`
6. **User data cached** in `AuthService._cachedUser`

### Token Storage
- Key: `backend_jwt`
- Storage: `SharedPreferences`
- Location: `lib/services/auth_service.dart` (Line 14)

---

## Key Files Reference

| File | Purpose |
|------|---------|
| `lib/services/api.dart` | HTTP client service |
| `lib/services/auth_service.dart` | Authentication logic |
| `lib/services/listing_service.dart` | Listing CRUD operations |
| `lib/screens/marketplace_screen.dart` | Marketplace UI with filters |
| `lib/screens/create_listing_screen.dart` | Create listing form |
| `lib/screens/phone_login.dart` | Login screen |

---

## Contact & Support

For questions about integration:
1. Check mock data in service files for expected response format
2. Review `fromJson` methods for exact field names
3. Test with mock data first, then integrate real endpoints
4. Ensure CORS is configured for web deployment

---

**Last Updated:** November 2024
**Frontend Version:** Flutter 3.x
**Minimum Backend API Version:** v1.0
