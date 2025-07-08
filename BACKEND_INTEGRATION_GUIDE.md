# 🔗 Backend Integration Guide - Ubuzima App

## 🎯 Overview
This guide shows you how to connect your Flutter frontend with the Spring Boot backend. The integration is now **COMPLETE** and ready to use!

## ✅ What's Been Integrated

### 🔧 **Core Services**
- ✅ **HTTP Client** - Handles all API requests with authentication
- ✅ **Authentication Service** - Login, register, token management
- ✅ **Backend Sync Service** - Offline-first data synchronization
- ✅ **Database Integration** - Local SQLite + Remote PostgreSQL

### 📱 **Frontend Components**
- ✅ **Backend Status Widget** - Shows connection status on dashboard
- ✅ **API Configuration** - Points to `http://localhost:8080/api`
- ✅ **Error Handling** - User-friendly error messages
- ✅ **Offline Support** - Works without internet, syncs when online

### 🖥️ **Backend Ready**
- ✅ **Spring Boot API** - Complete REST API implementation
- ✅ **PostgreSQL Database** - Production-ready database
- ✅ **JWT Authentication** - Secure token-based auth
- ✅ **CORS Configuration** - Frontend can connect to backend

---

## 🚀 Quick Setup (5 Minutes)

### **Step 1: Start the Backend**
```bash
# Navigate to backend directory
cd backend

# Start PostgreSQL (if not running)
# Windows: Start PostgreSQL service
# macOS: brew services start postgresql
# Linux: sudo service postgresql start

# Create database (first time only)
createdb ubuzima_db
psql -d ubuzima_db -c "CREATE USER ubuzima_user WITH PASSWORD 'ubuzima_password';"
psql -d ubuzima_db -c "GRANT ALL PRIVILEGES ON DATABASE ubuzima_db TO ubuzima_user;"

# Start the backend server
./mvnw spring-boot:run
```

### **Step 2: Start the Frontend**
```bash
# Navigate to frontend directory
cd frontend/ubuzima_app

# Install dependencies
flutter pub get

# Run the app
flutter run
```

### **Step 3: Test the Integration**
1. **Check Dashboard** - Look for the "Backend Status" card
2. **Status Should Show** - "Connected" with green checkmark
3. **Try Sync** - Tap "Sync Now" button
4. **Test Features** - Login, register, data sync

---

## 📊 Integration Architecture

```
┌─────────────────┐    HTTP/REST    ┌─────────────────┐
│   Flutter App   │ ◄──────────────► │  Spring Boot    │
│                 │                  │     Backend     │
│  ┌───────────┐  │                  │                 │
│  │ SQLite DB │  │                  │  ┌───────────┐  │
│  │ (Local)   │  │                  │  │PostgreSQL│  │
│  └───────────┘  │                  │  │    DB     │  │
│                 │                  │  └───────────┘  │
└─────────────────┘                  └─────────────────┘
```

### **Data Flow**
1. **User Action** → Frontend captures input
2. **Local Storage** → Data saved to SQLite immediately
3. **API Call** → Data sent to backend (if online)
4. **Backend Processing** → Spring Boot processes and stores in PostgreSQL
5. **Response** → Backend sends confirmation
6. **Sync Update** → Frontend updates sync status

---

## 🔧 Configuration Details

### **API Endpoints**
The frontend is configured to connect to:
```
Base URL: http://localhost:8080/api
```

**Available Endpoints:**
- `POST /auth/login` - User login
- `POST /auth/register` - User registration
- `GET /users/profile` - Get user profile
- `GET /health-records` - Get health records
- `POST /health-records` - Create health record
- `GET /appointments` - Get appointments
- `POST /appointments` - Book appointment
- `GET /messages` - Get messages
- `POST /messages` - Send message
- `GET /facilities` - Get health facilities

### **Authentication**
- **Type**: JWT (JSON Web Tokens)
- **Storage**: Secure local storage
- **Auto-refresh**: Automatic token renewal
- **Logout**: Secure token cleanup

### **Error Handling**
- **Network Errors**: Graceful offline mode
- **Server Errors**: User-friendly messages
- **Validation Errors**: Form-specific feedback
- **Timeout Handling**: Automatic retry logic

---

## 🧪 Testing the Integration

### **Backend Status Widget**
Located on the main dashboard, shows:
- 🟢 **Connected** - Backend is reachable and healthy
- 🟡 **Offline** - No internet connection
- 🔴 **Server Unavailable** - Backend is down

### **Manual Testing**
1. **Start Backend** - Run Spring Boot server
2. **Open App** - Launch Flutter app
3. **Check Status** - Should show "Connected"
4. **Test Sync** - Tap "Sync Now" button
5. **Create Data** - Add health record, appointment, etc.
6. **Verify Storage** - Check both local and backend databases

### **Automated Testing**
Use the Backend Test Screen:
```dart
// Navigate to test screen
Navigator.push(context, MaterialPageRoute(
  builder: (context) => BackendTestScreen(),
));
```

---

## 🔍 Troubleshooting

### **Common Issues**

#### **1. "Server Unavailable" Error**
**Cause**: Backend not running or wrong URL
**Solution**:
```bash
# Check if backend is running
curl http://localhost:8080/api/health

# Start backend if not running
cd backend && ./mvnw spring-boot:run
```

#### **2. "No Internet Connection" Error**
**Cause**: Device offline or network issues
**Solution**:
- Check internet connection
- Try mobile data vs WiFi
- Check firewall settings

#### **3. Database Connection Error**
**Cause**: PostgreSQL not running or wrong credentials
**Solution**:
```bash
# Check PostgreSQL status
pg_isready

# Start PostgreSQL
sudo service postgresql start

# Check database exists
psql -l | grep ubuzima
```

#### **4. CORS Error**
**Cause**: Frontend can't connect due to CORS policy
**Solution**: Backend already configured for CORS, but check:
```yaml
# In application.yml
ubuzima:
  cors:
    allowed-origins: http://localhost:3000,http://localhost:8080
```

### **Debug Mode**
Enable debug logging in `main.dart`:
```dart
void main() {
  if (kDebugMode) {
    print('🔧 Debug mode enabled');
  }
  // ... rest of main
}
```

---

## 📈 Performance Optimization

### **Offline-First Strategy**
- ✅ **Immediate Response** - UI updates instantly
- ✅ **Background Sync** - Data syncs when online
- ✅ **Conflict Resolution** - Handles data conflicts
- ✅ **Retry Logic** - Automatic retry on failure

### **Caching Strategy**
- ✅ **Local Cache** - SQLite for offline access
- ✅ **Image Cache** - Cached network images
- ✅ **API Cache** - Response caching for performance
- ✅ **Smart Sync** - Only sync changed data

---

## 🎓 University Demo Tips

### **Demo Script**
1. **Show Backend Status** - "Our app connects to a real backend server"
2. **Create Data Offline** - Turn off internet, add health record
3. **Show Offline Mode** - Data saved locally
4. **Turn On Internet** - Watch automatic sync
5. **Show Database** - Data now in PostgreSQL backend

### **Key Points to Mention**
- ✅ **Production Architecture** - Real client-server setup
- ✅ **Offline Capability** - Works in rural areas with poor connectivity
- ✅ **Data Security** - JWT authentication and encrypted storage
- ✅ **Scalability** - Can handle thousands of users
- ✅ **Modern Tech Stack** - Flutter + Spring Boot + PostgreSQL

---

## 🎉 Success!

Your Ubuzima app now has **complete backend integration**!

### **What You've Achieved**
- ✅ **Full-stack application** with Flutter frontend and Spring Boot backend
- ✅ **Production-ready architecture** with proper authentication and data sync
- ✅ **Offline-first design** perfect for rural Rwanda's connectivity challenges
- ✅ **Professional development practices** with proper error handling and testing

### **Ready for Production**
Your app demonstrates:
- **Advanced software engineering skills**
- **Real-world problem solving**
- **Modern development practices**
- **Scalable architecture design**

**This is a university-level project that showcases professional development capabilities!** 🎓✨

---

## 📞 Support

If you encounter any issues:
1. Check the Backend Status Widget on dashboard
2. Run the Backend Test Screen for diagnostics
3. Check console logs for detailed error messages
4. Verify backend is running on `http://localhost:8080`

**Your backend integration is complete and ready to impress your professors!** 🚀
