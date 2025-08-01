# 🧪 Ubuzima Frontend Testing Guide

## 🚀 Quick Start Testing

### 1. **Start Your Spring Boot Backend**
```bash
cd backend/ubuzima-backend
./mvnw spring-boot:run
```
Make sure your backend is running on `http://localhost:8080`

### 2. **Update Backend URL (if needed)**
Edit `frontend/ubuzima_app/lib/core/config/app_config.dart`:
```dart
static const String baseUrl = 'http://localhost:8080/api/v1';
// Or for Android emulator:
static const String baseUrl = 'http://10.0.2.2:8080/api/v1';
```

### 3. **Run the Flutter App**
```bash
cd frontend/ubuzima_app
flutter pub get
flutter run
```

## 🔐 Test User Accounts

### **Admin User**
- **Email**: `admin@ubuzima.com`
- **Password**: `password123`
- **Role**: Administrator
- **Access**: Full system management

### **Health Worker**
- **Email**: `doctor@ubuzima.com`
- **Password**: `password123`
- **Role**: Health Worker
- **Access**: Patient management, consultations

### **Client User**
- **Email**: `user@ubuzima.com`
- **Password**: `password123`
- **Role**: Client
- **Access**: Personal health tracking

## 📱 Testing Scenarios

### **🔐 Authentication Testing**
1. **Login Flow**
   - Test with valid credentials
   - Test with invalid credentials
   - Test password visibility toggle
   - Test "Remember Me" functionality

2. **Registration Flow**
   - Test user registration
   - Test form validation
   - Test role selection

3. **Role-Based Navigation**
   - Login as Admin → Should see Admin Dashboard
   - Login as Health Worker → Should see Health Worker Dashboard
   - Login as Client → Should see Client Dashboard

### **🩺 Health Records Testing**
1. **CRUD Operations**
   - Create new health record
   - View health record details
   - Edit existing health record
   - Delete health record

2. **Data Validation**
   - Test required fields
   - Test date validation
   - Test form submission

3. **API Integration**
   - Test loading states
   - Test error handling
   - Test refresh functionality

### **🩷 Menstrual Cycle Testing**
1. **Cycle Tracking**
   - Add new cycle entry
   - View cycle history
   - Test predictions

2. **Symptoms & Flow**
   - Record symptoms
   - Track flow intensity
   - Add notes

### **💊 Medications Testing**
1. **Medication Management**
   - Add new medication
   - Set reminders
   - Track side effects
   - Mark as completed

2. **Reminders**
   - Test notification scheduling
   - Test reminder alerts

### **📅 Appointments Testing**
1. **Appointment Booking**
   - Book new appointment
   - Select date and time
   - Choose appointment type

2. **Appointment Management**
   - View upcoming appointments
   - Reschedule appointments
   - Cancel appointments

## 🔧 API Endpoint Testing

### **Authentication Endpoints**
```
POST /api/v1/auth/login
POST /api/v1/auth/register
POST /api/v1/auth/refresh
POST /api/v1/auth/logout
```

### **Health Records Endpoints**
```
GET    /api/v1/health-records
POST   /api/v1/health-records
GET    /api/v1/health-records/{id}
PUT    /api/v1/health-records/{id}
DELETE /api/v1/health-records/{id}
```

### **Menstrual Cycles Endpoints**
```
GET    /api/v1/menstrual-cycles
POST   /api/v1/menstrual-cycles
PUT    /api/v1/menstrual-cycles/{id}
DELETE /api/v1/menstrual-cycles/{id}
```

### **Medications Endpoints**
```
GET    /api/v1/medications
POST   /api/v1/medications
PUT    /api/v1/medications/{id}
DELETE /api/v1/medications/{id}
```

### **Appointments Endpoints**
```
GET    /api/v1/appointments
POST   /api/v1/appointments
PUT    /api/v1/appointments/{id}
DELETE /api/v1/appointments/{id}
```

## 🐛 Common Issues & Solutions

### **1. Connection Issues**
**Problem**: "Connection timeout" or "Network error"
**Solutions**:
- Check if backend is running
- Verify the base URL in `app_config.dart`
- For Android emulator, use `10.0.2.2` instead of `localhost`
- Check firewall settings

### **2. Authentication Issues**
**Problem**: Login fails or token expires
**Solutions**:
- Check user credentials in database
- Verify JWT token configuration
- Check token expiration settings
- Clear app data and try again

### **3. Data Not Loading**
**Problem**: Empty screens or loading forever
**Solutions**:
- Check API endpoints are working
- Verify data models match backend response
- Check for null safety issues
- Review error logs

### **4. UI Issues**
**Problem**: Layout problems or crashes
**Solutions**:
- Check for missing imports
- Verify widget tree structure
- Test on different screen sizes
- Check for null values

## 📊 Testing Checklist

### **✅ Core Functionality**
- [ ] App launches successfully
- [ ] Splash screen displays
- [ ] Login/Registration works
- [ ] Role-based navigation works
- [ ] All dashboards load correctly

### **✅ Health Records**
- [ ] Can create health records
- [ ] Can view health records list
- [ ] Can edit health records
- [ ] Can delete health records
- [ ] Loading states work
- [ ] Error handling works

### **✅ Menstrual Cycles**
- [ ] Can add cycle entries
- [ ] Can view cycle history
- [ ] Predictions display correctly
- [ ] Symptoms tracking works

### **✅ Medications**
- [ ] Can add medications
- [ ] Can set reminders
- [ ] Can track side effects
- [ ] Active/inactive status works

### **✅ Appointments**
- [ ] Can book appointments
- [ ] Can view appointment list
- [ ] Can reschedule/cancel
- [ ] Status updates work

### **✅ UI/UX**
- [ ] Professional design
- [ ] Consistent colors/fonts
- [ ] Responsive layout
- [ ] Smooth animations
- [ ] Loading indicators
- [ ] Error messages

### **✅ Performance**
- [ ] App starts quickly
- [ ] Smooth scrolling
- [ ] No memory leaks
- [ ] Efficient API calls
- [ ] Proper caching

## 🔍 Debug Tools

### **Flutter Inspector**
Use Flutter Inspector to debug widget tree and performance issues.

### **Network Monitoring**
Monitor API calls using:
- Flutter DevTools
- Dio interceptors (already configured)
- Backend logs

### **State Management**
Use Riverpod DevTools to monitor state changes.

## 📝 Test Reports

### **Create Test Reports**
Document your testing results:
1. **Functionality Tests**: Pass/Fail for each feature
2. **API Integration**: Response times and error rates
3. **UI/UX Tests**: Screenshots and user feedback
4. **Performance Tests**: Load times and memory usage

### **Bug Reports**
When reporting bugs, include:
- Steps to reproduce
- Expected vs actual behavior
- Screenshots/videos
- Device/platform information
- Error logs

## 🎯 Next Steps After Testing

1. **Fix Critical Issues**: Address any blocking bugs
2. **Optimize Performance**: Improve slow operations
3. **Enhance UI**: Polish the user interface
4. **Add Missing Features**: Implement remaining functionality
5. **Security Review**: Ensure data protection
6. **User Testing**: Get feedback from real users

## 📞 Support

If you encounter issues during testing:
1. Check this guide first
2. Review error logs
3. Test API endpoints directly
4. Check backend database
5. Ask for help with specific error messages

Happy Testing! 🚀
