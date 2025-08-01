# 🚀 Ubuzima Quick Start Guide

## ⚡ 5-Minute Setup

### 1. **Start Backend** (Terminal 1)
```bash
cd backend/ubuzima-backend
./mvnw spring-boot:run
```
Wait for: `Started UbuzimaApplication in X.XXX seconds`

### 2. **Start Frontend** (Terminal 2)
```bash
cd frontend/ubuzima_app
flutter pub get
flutter run
```

### 3. **Test Login**
Use these accounts:
- **Admin**: `admin@ubuzima.com` / `password123`
- **Health Worker**: `doctor@ubuzima.com` / `password123`
- **Client**: `user@ubuzima.com` / `password123`

---

## 🎯 Quick Feature Test

### ✅ **Authentication**
1. Open app → Login screen appears
2. Enter credentials → Dashboard loads
3. Different roles → Different dashboards

### ✅ **Health Records**
1. Navigate to Health Records
2. Tap "+" to add record
3. View, edit, delete records
4. Pull to refresh

### ✅ **API Integration**
1. Check network requests in logs
2. Test offline behavior
3. Verify error handling

---

## 🔧 Configuration

### **Backend URL** (if needed)
Edit `lib/core/config/app_config.dart`:
```dart
// For local development
static const String baseUrl = 'http://localhost:8080/api/v1';

// For Android emulator
static const String baseUrl = 'http://10.0.2.2:8080/api/v1';

// For physical device (replace with your IP)
static const String baseUrl = 'http://192.168.1.100:8080/api/v1';
```

### **Database Connection**
Your backend should connect to PostgreSQL:
- **Database**: `ubuzima_db`
- **Username**: `postgres`
- **Password**: `AUCA@2024`

---

## 🎨 **New Branding Features**

### **Enhanced Color Scheme**
- **Primary**: Warm Orange (#FF6B35) - welcoming and energetic
- **Secondary**: Modern Purple (#6C5CE7) - trust and wisdom  
- **Tertiary**: Bright Cyan (#00D2FF) - health and vitality

### **Professional Design**
- Smooth animations and transitions
- Loading states for all operations
- Error handling with retry options
- Pull-to-refresh functionality
- Role-based navigation

---

## 🧪 **Testing Checklist**

### **Core Functionality**
- [ ] App launches successfully
- [ ] Login/logout works
- [ ] Role-based dashboards load
- [ ] Navigation works smoothly

### **Health Records**
- [ ] Create new records
- [ ] View records list
- [ ] Edit existing records
- [ ] Delete records
- [ ] Refresh data

### **API Integration**
- [ ] Data loads from backend
- [ ] CRUD operations work
- [ ] Error messages appear
- [ ] Loading states show

### **UI/UX**
- [ ] Professional appearance
- [ ] Consistent colors
- [ ] Smooth animations
- [ ] Responsive layout

---

## 🐛 **Common Issues**

### **"Connection Error"**
- ✅ Check backend is running
- ✅ Verify URL in `app_config.dart`
- ✅ For Android emulator, use `10.0.2.2`

### **"Login Failed"**
- ✅ Check user exists in database
- ✅ Verify credentials are correct
- ✅ Check backend logs

### **"Empty Screens"**
- ✅ Check API endpoints return data
- ✅ Verify data models match backend
- ✅ Check for null safety issues

---

## 📱 **Run Commands**

### **Development**
```bash
flutter run                    # Default device
flutter run -d chrome         # Web browser
flutter run -d android        # Android emulator
flutter run --hot             # Hot reload enabled
```

### **Build**
```bash
flutter build apk --debug     # Debug APK
flutter build apk --release   # Release APK
flutter build web             # Web build
```

### **Testing**
```bash
flutter test                  # Run tests
flutter analyze              # Code analysis
dart test_integration.dart   # Integration tests
```

---

## 🎯 **Success Indicators**

### **✅ Integration Working**
- App builds without errors
- Login redirects to correct dashboard
- Health records load from database
- CRUD operations update backend
- Error messages are user-friendly

### **✅ Professional Quality**
- Smooth animations
- Consistent branding
- Loading indicators
- Error handling
- Responsive design

---

## 📞 **Need Help?**

### **Check Logs**
- Flutter: Check console output
- Backend: Check Spring Boot logs
- Network: Use Flutter DevTools

### **Debug Steps**
1. Verify backend is running
2. Check database connection
3. Test API endpoints directly
4. Review error messages
5. Check network connectivity

---

## 🎉 **You're Ready!**

Your Ubuzima app now has:
- ✅ **Professional Design** - Modern, welcoming interface
- ✅ **Full Backend Integration** - Real API connections
- ✅ **Complete CRUD** - All data operations working
- ✅ **Role-Based Access** - Admin, Health Worker, Client dashboards
- ✅ **Error Handling** - User-friendly error messages
- ✅ **Loading States** - Professional loading indicators

**Happy Testing!** 🚀
