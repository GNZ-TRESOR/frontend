# 🐘 PostgreSQL Database Setup for Ubuzima App

## 📋 **Quick Setup Guide**

Your Ubuzima app now supports real PostgreSQL database connectivity! Follow these steps to connect your app to a real database.

---

## 🛠️ **Option 1: Local PostgreSQL Setup**

### **Step 1: Install PostgreSQL**
1. **Download PostgreSQL**: https://www.postgresql.org/download/
2. **Install with default settings**
3. **Remember your password** for the `postgres` user

### **Step 2: Create Database**
```sql
-- Connect to PostgreSQL as postgres user
CREATE DATABASE ubuzima_db;
CREATE USER ubuzima_user WITH PASSWORD 'your_password';
GRANT ALL PRIVILEGES ON DATABASE ubuzima_db TO ubuzima_user;
```

### **Step 3: Configure in App**
1. **Open Ubuzima app**
2. **Go to Settings → Advanced Settings → Database Configuration**
3. **Enter your details**:
   - **Host**: `localhost`
   - **Port**: `5432`
   - **Database**: `ubuzima_db`
   - **Username**: `ubuzima_user`
   - **Password**: `your_password`
4. **Test Connection** and **Save**

---

## ☁️ **Option 2: Cloud PostgreSQL (Recommended)**

### **Free Cloud Options:**

#### **A. Supabase (Recommended)**
1. **Sign up**: https://supabase.com
2. **Create new project**
3. **Get connection details** from Settings → Database
4. **Use in app**:
   - **Host**: `db.xxx.supabase.co`
   - **Port**: `5432`
   - **Database**: `postgres`
   - **Username**: `postgres`
   - **Password**: `your_project_password`

#### **B. ElephantSQL**
1. **Sign up**: https://www.elephantsql.com
2. **Create free instance**
3. **Copy connection URL**
4. **Parse URL** for app configuration

#### **C. Railway**
1. **Sign up**: https://railway.app
2. **Deploy PostgreSQL**
3. **Get connection details**

---

## 🔧 **App Configuration**

### **In-App Setup:**
1. **Launch Ubuzima app**
2. **Navigate**: Settings → Advanced Settings → Database Configuration
3. **Enter your PostgreSQL details**
4. **Test connection** (green checkmark = success)
5. **Save & Connect**

### **What Happens Next:**
- ✅ **Tables auto-created**: Users, health_records, appointments, messages, education_progress
- ✅ **Real data storage**: All your health data goes to PostgreSQL
- ✅ **Data persistence**: Data survives app restarts
- ✅ **Multi-device sync**: Access same data from different devices
- ✅ **Backup & recovery**: Professional database backup options

---

## 📊 **Database Schema**

The app automatically creates these tables:

### **Users Table**
```sql
CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  uuid VARCHAR(36) UNIQUE NOT NULL,
  name VARCHAR(255) NOT NULL,
  email VARCHAR(255) UNIQUE,
  phone VARCHAR(20),
  role VARCHAR(50) NOT NULL,
  date_of_birth DATE,
  gender VARCHAR(10),
  location VARCHAR(255),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### **Health Records Table**
```sql
CREATE TABLE health_records (
  id SERIAL PRIMARY KEY,
  user_id INTEGER REFERENCES users(id),
  record_type VARCHAR(50) NOT NULL,
  date TIMESTAMP NOT NULL,
  weight DECIMAL(5,2),
  blood_pressure_systolic INTEGER,
  blood_pressure_diastolic INTEGER,
  temperature DECIMAL(4,2),
  notes TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### **Appointments Table**
```sql
CREATE TABLE appointments (
  id SERIAL PRIMARY KEY,
  client_id INTEGER REFERENCES users(id),
  health_worker_id INTEGER REFERENCES users(id),
  appointment_date TIMESTAMP NOT NULL,
  type VARCHAR(100) NOT NULL,
  status VARCHAR(50) DEFAULT 'scheduled',
  notes TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

---

## 🧪 **Testing Your Connection**

### **In-App Testing:**
1. **Go to**: Settings → Advanced Settings → Backend Test
2. **Run all tests**
3. **Check**: Database connection, table creation, data operations

### **Manual Testing:**
```sql
-- Check if tables exist
\dt

-- Check users table
SELECT * FROM users;

-- Check health records
SELECT * FROM health_records;

-- Check appointments
SELECT * FROM appointments;
```

---

## 🔄 **Data Migration**

### **From Local to Cloud:**
1. **Export local data** (if any)
2. **Set up cloud database**
3. **Configure app** with cloud credentials
4. **Import data** (if needed)

### **Backup Strategy:**
```bash
# Backup database
pg_dump -h hostname -U username -d database_name > backup.sql

# Restore database
psql -h hostname -U username -d database_name < backup.sql
```

---

## 🚀 **Production Deployment**

### **For University Demo:**
- ✅ **Use Supabase free tier** (perfect for demos)
- ✅ **Show real data persistence**
- ✅ **Demonstrate multi-user functionality**
- ✅ **Professional database integration**

### **For Real Deployment:**
- 🔒 **Enable SSL** in production
- 🔐 **Use environment variables** for credentials
- 📊 **Set up monitoring** and backups
- 🔄 **Configure connection pooling**

---

## 🆘 **Troubleshooting**

### **Common Issues:**

#### **Connection Failed**
- ✅ Check host/port/credentials
- ✅ Ensure database is running
- ✅ Check firewall settings
- ✅ Verify network connectivity

#### **Permission Denied**
- ✅ Check user permissions
- ✅ Verify password
- ✅ Ensure user has database access

#### **Tables Not Created**
- ✅ Check user has CREATE privileges
- ✅ Verify database exists
- ✅ Check app logs for errors

### **Getting Help:**
- 📖 **PostgreSQL docs**: https://www.postgresql.org/docs/
- 💬 **Supabase docs**: https://supabase.com/docs
- 🔧 **App logs**: Check Flutter console for detailed errors

---

## 🎉 **Success!**

Once connected, your Ubuzima app will:
- 💾 **Store real health data** in PostgreSQL
- 🔄 **Sync across devices** (when using cloud database)
- 📊 **Enable advanced analytics** and reporting
- 🏥 **Support multi-user scenarios** (clients, health workers, admins)
- 🎓 **Impress your professors** with professional database integration!

**Your app is now production-ready with real database connectivity!** 🚀✨
