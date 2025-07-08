import 'package:flutter/material.dart';

abstract class AppLocalizations {
  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  // App Info
  String get appName;
  String get appTagline;
  String get version;

  // Navigation & Common
  String get home;
  String get back;
  String get next;
  String get previous;
  String get save;
  String get cancel;
  String get delete;
  String get edit;
  String get add;
  String get search;
  String get filter;
  String get settings;
  String get help;
  String get profile;
  String get logout;
  String get login;
  String get register;
  String get skip;
  String get continue_;
  String get done;
  String get loading;
  String get error;
  String get success;
  String get warning;
  String get info;

  // Authentication
  String get email;
  String get password;
  String get confirmPassword;
  String get forgotPassword;
  String get createAccount;
  String get alreadyHaveAccount;
  String get dontHaveAccount;
  String get signInWithGoogle;
  String get signInWithFacebook;
  String get or;
  String get fullName;
  String get phoneNumber;
  String get dateOfBirth;
  String get gender;
  String get male;
  String get female;
  String get other;
  String get location;
  String get district;
  String get sector;
  String get cell;
  String get village;

  // Dashboard
  String get dashboard;
  String get welcome;
  String get welcomeBack;
  String get quickActions;
  String get recentActivity;
  String get healthOverview;
  String get upcomingAppointments;
  String get messages;
  String get notifications;

  // Health Tracking
  String get healthTracking;
  String get menstrualCycle;
  String get cycleTracking;
  String get periodTracker;
  String get ovulation;
  String get fertility;
  String get symptoms;
  String get mood;
  String get flow;
  String get pain;
  String get notes;
  String get addSymptom;
  String get editSymptom;
  String get deleteSymptom;
  String get cycleLength;
  String get periodLength;
  String get lastPeriod;
  String get nextPeriod;
  String get daysUntilPeriod;
  String get daysUntilOvulation;
  String get fertile;
  String get notFertile;
  String get highFertility;
  String get lowFertility;

  // Contraception
  String get contraception;
  String get birthControl;
  String get contraceptiveMethod;
  String get pill;
  String get condom;
  String get iud;
  String get implant;
  String get injection;
  String get patch;
  String get ring;
  String get naturalMethods;
  String get emergency;
  String get effectiveness;
  String get sideEffects;
  String get howToUse;
  String get reminders;
  String get setReminder;
  String get dailyReminder;
  String get weeklyReminder;
  String get monthlyReminder;

  // Education
  String get education;
  String get lessons;
  String get courses;
  String get topics;
  String get familyPlanning;
  String get reproductiveHealth;
  String get sexualHealth;
  String get pregnancy;
  String get prenatalCare;
  String get postnatalCare;
  String get breastfeeding;
  String get childcare;
  String get nutrition;
  String get exercise;
  String get mentalHealth;
  String get relationships;
  String get communication;
  String get consent;
  String get safety;

  // Communication
  String get messaging;
  String get chat;
  String get call;
  String get videoCall;
  String get sendMessage;
  String get typeMessage;
  String get voiceMessage;
  String get attachment;
  String get photo;
  String get document;
  String get healthWorker;
  String get doctor;
  String get nurse;
  String get midwife;
  String get counselor;
  String get online;
  String get offline;
  String get lastSeen;
  String get typing;

  // Appointments
  String get appointments;
  String get bookAppointment;
  String get rescheduleAppointment;
  String get cancelAppointment;
  String get upcomingAppointment;
  String get pastAppointments;
  String get appointmentConfirmed;
  String get appointmentCancelled;
  String get appointmentRescheduled;
  String get selectDate;
  String get selectTime;
  String get selectHealthWorker;
  String get selectService;
  String get appointmentType;
  String get consultation;
  String get checkup;
  String get followUp;
  String get routine;

  // Clinics & Locations
  String get clinics;
  String get healthFacilities;
  String get nearbyFacilities;
  String get findClinic;
  String get directions;
  String get distance;
  String get openingHours;
  String get services;
  String get contactInfo;
  String get address;
  String get mapView;
  String get listView;
  String get currentLocation;
  String get searchLocation;

  // Voice Commands
  String get useVoice;
  String get voiceCommand;
  String get listening;
  String get speakNow;
  String get voiceNotRecognized;
  String get tryAgain;
  String get voiceHelp;

  // Settings
  String get language;
  String get changeLanguage;
  String get privacy;
  String get security;
  String get account;
  String get about;
  String get termsOfService;
  String get privacyPolicy;
  String get contactSupport;
  String get reportBug;
  String get rateApp;
  String get shareApp;

  // Errors & Messages
  String get errorOccurred;
  String get networkError;
  String get serverError;
  String get validationError;
  String get fieldRequired;
  String get invalidEmail;
  String get invalidPhone;
  String get passwordTooShort;
  String get passwordsDoNotMatch;
  String get loginFailed;
  String get registrationFailed;
  String get dataLoadFailed;
  String get dataSaveFailed;
  String get permissionDenied;
  String get locationPermissionDenied;
  String get cameraPermissionDenied;
  String get microphonePermissionDenied;

  // Success Messages
  String get loginSuccessful;
  String get registrationSuccessful;
  String get dataSaved;
  String get appointmentBooked;
  String get messagesSent;
  String get profileUpdated;
  String get settingsUpdated;

  // Time & Dates
  String get today;
  String get yesterday;
  String get tomorrow;
  String get thisWeek;
  String get thisMonth;
  String get lastWeek;
  String get lastMonth;
  String get nextWeek;
  String get nextMonth;
  String get morning;
  String get afternoon;
  String get evening;
  String get night;

  // Days of Week
  String get monday;
  String get tuesday;
  String get wednesday;
  String get thursday;
  String get friday;
  String get saturday;
  String get sunday;

  // Months
  String get january;
  String get february;
  String get march;
  String get april;
  String get may;
  String get june;
  String get july;
  String get august;
  String get september;
  String get october;
  String get november;
  String get december;
}
