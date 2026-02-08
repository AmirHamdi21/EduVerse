import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated_l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'EduVerse'**
  String get appTitle;

  /// No description provided for @hello.
  ///
  /// In en, this message translates to:
  /// **'Hello'**
  String get hello;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome to EduVerse'**
  String get welcome;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue learning'**
  String get loginSubtitle;

  /// No description provided for @signupTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get signupTitle;

  /// No description provided for @signupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Join our learning community'**
  String get signupSubtitle;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @enterEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get enterEmail;

  /// No description provided for @enterPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get enterPassword;

  /// No description provided for @enterConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm your password'**
  String get enterConfirmPassword;

  /// No description provided for @enterFullName.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name'**
  String get enterFullName;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginButton;

  /// No description provided for @signupButton.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signupButton;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get arabic;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @lightMode.
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get lightMode;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @networkError.
  ///
  /// In en, this message translates to:
  /// **'Please check your internet connection'**
  String get networkError;

  /// No description provided for @errorOccurred.
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get errorOccurred;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get noData;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @warning.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get warning;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Invalid email address'**
  String get invalidEmail;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordTooShort;

  /// No description provided for @passwordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordMismatch;

  /// No description provided for @fieldRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get fieldRequired;

  /// No description provided for @homeTitle.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeTitle;

  /// No description provided for @coursesTitle.
  ///
  /// In en, this message translates to:
  /// **'Courses'**
  String get coursesTitle;

  /// No description provided for @searchTitle.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchTitle;

  /// No description provided for @myCoursesTitle.
  ///
  /// In en, this message translates to:
  /// **'My Courses'**
  String get myCoursesTitle;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get profileTitle;

  /// No description provided for @aboutUs.
  ///
  /// In en, this message translates to:
  /// **'About Us'**
  String get aboutUs;

  /// No description provided for @contactUs.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get contactUs;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @helpCenter.
  ///
  /// In en, this message translates to:
  /// **'Help Center'**
  String get helpCenter;

  /// No description provided for @logout_confirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get logout_confirmation;

  /// No description provided for @agree.
  ///
  /// In en, this message translates to:
  /// **'I agree to the'**
  String get agree;

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get firstName;

  /// No description provided for @lastName.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get lastName;

  /// No description provided for @enterFirstName.
  ///
  /// In en, this message translates to:
  /// **'Enter your first name'**
  String get enterFirstName;

  /// No description provided for @enterLastName.
  ///
  /// In en, this message translates to:
  /// **'Enter your last name'**
  String get enterLastName;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @enterPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number'**
  String get enterPhoneNumber;

  /// No description provided for @selectRole.
  ///
  /// In en, this message translates to:
  /// **'Select Role'**
  String get selectRole;

  /// No description provided for @student.
  ///
  /// In en, this message translates to:
  /// **'Student'**
  String get student;

  /// No description provided for @instructor.
  ///
  /// In en, this message translates to:
  /// **'Instructor'**
  String get instructor;

  /// No description provided for @ta.
  ///
  /// In en, this message translates to:
  /// **'Teaching Assistant'**
  String get ta;

  /// No description provided for @admin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get admin;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPasswordTitle;

  /// No description provided for @forgotPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your email to receive a password reset link'**
  String get forgotPasswordSubtitle;

  /// No description provided for @resetPasswordButton.
  ///
  /// In en, this message translates to:
  /// **'Send Reset Link'**
  String get resetPasswordButton;

  /// No description provided for @backToLogin.
  ///
  /// In en, this message translates to:
  /// **'Back to Login'**
  String get backToLogin;

  /// No description provided for @passwordResetSent.
  ///
  /// In en, this message translates to:
  /// **'Password reset link sent to your email'**
  String get passwordResetSent;

  /// No description provided for @enterVerificationCode.
  ///
  /// In en, this message translates to:
  /// **'Enter the verification code'**
  String get enterVerificationCode;

  /// No description provided for @verificationCodeHint.
  ///
  /// In en, this message translates to:
  /// **'Enter verification code'**
  String get verificationCodeHint;

  /// No description provided for @verifyButton.
  ///
  /// In en, this message translates to:
  /// **'Verify Email'**
  String get verifyButton;

  /// No description provided for @resendCodeButton.
  ///
  /// In en, this message translates to:
  /// **'Resend Code'**
  String get resendCodeButton;

  /// No description provided for @verifyEmailTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify Your Email'**
  String get verifyEmailTitle;

  /// No description provided for @verifyEmailSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We sent a verification code to your email'**
  String get verifyEmailSubtitle;

  /// No description provided for @emailVerifiedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Email verified successfully!'**
  String get emailVerifiedSuccessfully;

  /// No description provided for @verificationCodeRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter the verification code'**
  String get verificationCodeRequired;

  /// No description provided for @emailNotFound.
  ///
  /// In en, this message translates to:
  /// **'Email address not found. Please check and try again.'**
  String get emailNotFound;

  /// No description provided for @resendingCode.
  ///
  /// In en, this message translates to:
  /// **'Resending code...'**
  String get resendingCode;

  /// No description provided for @onboarding1Title.
  ///
  /// In en, this message translates to:
  /// **'Personalized Learning'**
  String get onboarding1Title;

  /// No description provided for @onboarding1Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Get AI-powered study plans tailored just for you'**
  String get onboarding1Subtitle;

  /// No description provided for @onboarding2Title.
  ///
  /// In en, this message translates to:
  /// **'Role-Based Features'**
  String get onboarding2Title;

  /// No description provided for @onboarding2Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your role to unlock powerful tools'**
  String get onboarding2Subtitle;

  /// No description provided for @onboarding2InfoText.
  ///
  /// In en, this message translates to:
  /// **'Your role has been detected automatically based on your verified email — EduVerse will personalize your dashboard accordingly.'**
  String get onboarding2InfoText;

  /// No description provided for @studentRole.
  ///
  /// In en, this message translates to:
  /// **'Student'**
  String get studentRole;

  /// No description provided for @studentFeature1.
  ///
  /// In en, this message translates to:
  /// **'Personalized Learning & Flashcards'**
  String get studentFeature1;

  /// No description provided for @studentFeature2.
  ///
  /// In en, this message translates to:
  /// **'Smart Analytics & Grades Tracking'**
  String get studentFeature2;

  /// No description provided for @studentFeature3.
  ///
  /// In en, this message translates to:
  /// **'AI Summaries & Study Plans'**
  String get studentFeature3;

  /// No description provided for @studentTagline.
  ///
  /// In en, this message translates to:
  /// **'Learn smarter with EduVerse AI.'**
  String get studentTagline;

  /// No description provided for @instructorRole.
  ///
  /// In en, this message translates to:
  /// **'Instructor'**
  String get instructorRole;

  /// No description provided for @instructorFeature1.
  ///
  /// In en, this message translates to:
  /// **'AI-Generated Feedback & Grading'**
  String get instructorFeature1;

  /// No description provided for @instructorFeature2.
  ///
  /// In en, this message translates to:
  /// **'Lab & Assignment Management'**
  String get instructorFeature2;

  /// No description provided for @instructorFeature3.
  ///
  /// In en, this message translates to:
  /// **'Course Discussions & Insights'**
  String get instructorFeature3;

  /// No description provided for @instructorTagline.
  ///
  /// In en, this message translates to:
  /// **'Teach efficiently with intelligent support.'**
  String get instructorTagline;

  /// No description provided for @adminRole.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get adminRole;

  /// No description provided for @adminFeature1.
  ///
  /// In en, this message translates to:
  /// **'EduVerse-Wide Analytics & Reporting'**
  String get adminFeature1;

  /// No description provided for @adminFeature2.
  ///
  /// In en, this message translates to:
  /// **'Access & User Management'**
  String get adminFeature2;

  /// No description provided for @adminFeature3.
  ///
  /// In en, this message translates to:
  /// **'Attendance & System Oversight'**
  String get adminFeature3;

  /// No description provided for @adminTagline.
  ///
  /// In en, this message translates to:
  /// **'Manage effortlessly through data intelligence.'**
  String get adminTagline;

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'EduVerse'**
  String get appName;

  /// No description provided for @poweredByAI.
  ///
  /// In en, this message translates to:
  /// **'Powered by AI. Designed for growth.'**
  String get poweredByAI;

  /// No description provided for @onboarding1MainTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to\nEduVerse — The Future of Intelligent Learning.'**
  String get onboarding1MainTitle;

  /// No description provided for @onboarding1Description.
  ///
  /// In en, this message translates to:
  /// **'An all-in-one AI-driven education platform built for Students, Instructors, and Institutions. Learn smarter, teach better, and manage seamlessly — all in one connected ecosystem.'**
  String get onboarding1Description;

  /// No description provided for @onboarding3Title.
  ///
  /// In en, this message translates to:
  /// **'AI-Powered Learning'**
  String get onboarding3Title;

  /// No description provided for @onboarding3Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Experience intelligent learning tailored to your role'**
  String get onboarding3Subtitle;

  /// No description provided for @aiForStudents.
  ///
  /// In en, this message translates to:
  /// **'AI for Students'**
  String get aiForStudents;

  /// No description provided for @studentSummaries.
  ///
  /// In en, this message translates to:
  /// **'Smart Summaries of lectures and PDFs'**
  String get studentSummaries;

  /// No description provided for @studentAnalytics.
  ///
  /// In en, this message translates to:
  /// **'AI-based Performance Analytics'**
  String get studentAnalytics;

  /// No description provided for @studentPlans.
  ///
  /// In en, this message translates to:
  /// **'Personalized Study Plans & Flashcards'**
  String get studentPlans;

  /// No description provided for @studentAssistant.
  ///
  /// In en, this message translates to:
  /// **'Your 24/7 personal learning assistant.'**
  String get studentAssistant;

  /// No description provided for @aiForInstructors.
  ///
  /// In en, this message translates to:
  /// **'AI for Instructors'**
  String get aiForInstructors;

  /// No description provided for @instructorAssignment.
  ///
  /// In en, this message translates to:
  /// **'AI-Assisted Assignment Evaluation'**
  String get instructorAssignment;

  /// No description provided for @instructorInsights.
  ///
  /// In en, this message translates to:
  /// **'Student Progress Insights & Alerts'**
  String get instructorInsights;

  /// No description provided for @instructorRecommendations.
  ///
  /// In en, this message translates to:
  /// **'Auto-Generated Teaching Recommendations'**
  String get instructorRecommendations;

  /// No description provided for @instructorGrading.
  ///
  /// In en, this message translates to:
  /// **'Grading'**
  String get instructorGrading;

  /// No description provided for @aiForAdmins.
  ///
  /// In en, this message translates to:
  /// **'AI for Admins'**
  String get aiForAdmins;

  /// No description provided for @adminAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Real-Time Institution Analytics'**
  String get adminAnalytics;

  /// No description provided for @adminAttendance.
  ///
  /// In en, this message translates to:
  /// **'Automated Attendance & Report Generation'**
  String get adminAttendance;

  /// No description provided for @adminMonitoring.
  ///
  /// In en, this message translates to:
  /// **'AI-Based Performance Monitoring & Insights'**
  String get adminMonitoring;

  /// No description provided for @adminManagement.
  ///
  /// In en, this message translates to:
  /// **'Streamline EduVerse management with real-time intelligence.'**
  String get adminManagement;

  /// No description provided for @poweredByIntelligence.
  ///
  /// In en, this message translates to:
  /// **'Powered by Intelligence.\nDesigned for Education.'**
  String get poweredByIntelligence;

  /// No description provided for @poweredByIntelligence2.
  ///
  /// In en, this message translates to:
  /// **'Powered by Intelligence'**
  String get poweredByIntelligence2;

  /// No description provided for @aiDescription.
  ///
  /// In en, this message translates to:
  /// **'EduVerse\'s AI engine transforms learning, teaching, and management through automation, insights, and personalization.'**
  String get aiDescription;

  /// No description provided for @eduverseAi.
  ///
  /// In en, this message translates to:
  /// **'EduVerse AI'**
  String get eduverseAi;

  /// No description provided for @connectAllRolesThroughOneIntelligentSystem.
  ///
  /// In en, this message translates to:
  /// **' connects all roles through one intelligent system — ensuring '**
  String get connectAllRolesThroughOneIntelligentSystem;

  /// No description provided for @personalizedExperiences.
  ///
  /// In en, this message translates to:
  /// **'personalized experiences'**
  String get personalizedExperiences;

  /// No description provided for @forEveryone.
  ///
  /// In en, this message translates to:
  /// **' for everyone.'**
  String get forEveryone;

  /// No description provided for @splashTitle.
  ///
  /// In en, this message translates to:
  /// **'EduVerse Platform'**
  String get splashTitle;

  /// No description provided for @splashSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Learning Management System'**
  String get splashSubtitle;

  /// No description provided for @noInternetConnection.
  ///
  /// In en, this message translates to:
  /// **'No internet connection. Please check your network and try again.'**
  String get noInternetConnection;

  /// No description provided for @emailNotVerified.
  ///
  /// In en, this message translates to:
  /// **'Your email has not been verified yet. Please verify your email to continue.'**
  String get emailNotVerified;

  /// No description provided for @emailAlreadyRegistered.
  ///
  /// In en, this message translates to:
  /// **'This email is already registered. Please use a different email or try logging in.'**
  String get emailAlreadyRegistered;

  /// No description provided for @operationFailed.
  ///
  /// In en, this message translates to:
  /// **'Operation failed. Please try again later.'**
  String get operationFailed;

  /// No description provided for @goodEvening.
  ///
  /// In en, this message translates to:
  /// **'Good Evening'**
  String get goodEvening;

  /// No description provided for @gpa.
  ///
  /// In en, this message translates to:
  /// **'GPA'**
  String get gpa;

  /// No description provided for @semesterProgress.
  ///
  /// In en, this message translates to:
  /// **'Semester Progress'**
  String get semesterProgress;

  /// No description provided for @upcomingDeadline.
  ///
  /// In en, this message translates to:
  /// **'Upcoming Deadline'**
  String get upcomingDeadline;

  /// No description provided for @attendance.
  ///
  /// In en, this message translates to:
  /// **'Attendance'**
  String get attendance;

  /// No description provided for @myCoursesSection.
  ///
  /// In en, this message translates to:
  /// **'My Courses'**
  String get myCoursesSection;

  /// No description provided for @toDoSmartReminders.
  ///
  /// In en, this message translates to:
  /// **'To-Do / Smart Reminders'**
  String get toDoSmartReminders;

  /// No description provided for @performanceInsights.
  ///
  /// In en, this message translates to:
  /// **'Performance Insights'**
  String get performanceInsights;

  /// No description provided for @courses.
  ///
  /// In en, this message translates to:
  /// **'Courses'**
  String get courses;

  /// No description provided for @aiQuiz.
  ///
  /// In en, this message translates to:
  /// **'AI Quiz'**
  String get aiQuiz;

  /// No description provided for @flashcards.
  ///
  /// In en, this message translates to:
  /// **'Flashcards'**
  String get flashcards;

  /// No description provided for @tasks.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get tasks;

  /// No description provided for @leaderboard.
  ///
  /// In en, this message translates to:
  /// **'Leaderboard'**
  String get leaderboard;

  /// No description provided for @messages.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get messages;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @materials.
  ///
  /// In en, this message translates to:
  /// **'Materials'**
  String get materials;

  /// No description provided for @complete.
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get complete;

  /// No description provided for @weakTopic.
  ///
  /// In en, this message translates to:
  /// **'Weak Topic'**
  String get weakTopic;

  /// No description provided for @studySuggestion.
  ///
  /// In en, this message translates to:
  /// **'Study Suggestion'**
  String get studySuggestion;

  /// No description provided for @tryReviewing.
  ///
  /// In en, this message translates to:
  /// **'Try reviewing'**
  String get tryReviewing;

  /// No description provided for @chapter.
  ///
  /// In en, this message translates to:
  /// **'Chapter'**
  String get chapter;

  /// No description provided for @problems.
  ///
  /// In en, this message translates to:
  /// **'problems'**
  String get problems;

  /// No description provided for @peakLearningTime.
  ///
  /// In en, this message translates to:
  /// **'Peak Learning Time'**
  String get peakLearningTime;

  /// No description provided for @youPerform.
  ///
  /// In en, this message translates to:
  /// **'You perform best when'**
  String get youPerform;

  /// No description provided for @studying.
  ///
  /// In en, this message translates to:
  /// **'studying'**
  String get studying;

  /// No description provided for @inTheMorning.
  ///
  /// In en, this message translates to:
  /// **'in the morning. Try scheduling more study sessions.'**
  String get inTheMorning;

  /// No description provided for @getPersonalizedStudyHelp.
  ///
  /// In en, this message translates to:
  /// **'Get personalized study help'**
  String get getPersonalizedStudyHelp;

  /// No description provided for @askAI.
  ///
  /// In en, this message translates to:
  /// **'Ask AI'**
  String get askAI;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @algorithmAssignment.
  ///
  /// In en, this message translates to:
  /// **'Algorithm Assignment'**
  String get algorithmAssignment;

  /// No description provided for @aiEthicsPaperOutline.
  ///
  /// In en, this message translates to:
  /// **'AI Ethics Paper Outline'**
  String get aiEthicsPaperOutline;

  /// No description provided for @prepareDataStructuresQuiz.
  ///
  /// In en, this message translates to:
  /// **'Prepare for Data Structures Quiz'**
  String get prepareDataStructuresQuiz;

  /// No description provided for @due.
  ///
  /// In en, this message translates to:
  /// **'Due'**
  String get due;

  /// No description provided for @introductionToAI.
  ///
  /// In en, this message translates to:
  /// **'Introduction to AI'**
  String get introductionToAI;

  /// No description provided for @dataStructures.
  ///
  /// In en, this message translates to:
  /// **'Data Structures'**
  String get dataStructures;

  /// No description provided for @calculusII.
  ///
  /// In en, this message translates to:
  /// **'Calculus II'**
  String get calculusII;

  /// No description provided for @drSarahFarley.
  ///
  /// In en, this message translates to:
  /// **'Dr. Sarah Farley'**
  String get drSarahFarley;

  /// No description provided for @drMarkGoldberg.
  ///
  /// In en, this message translates to:
  /// **'Dr. Mark Goldberg'**
  String get drMarkGoldberg;

  /// No description provided for @drJessicaPeterson.
  ///
  /// In en, this message translates to:
  /// **'Dr. Jessica Peterson'**
  String get drJessicaPeterson;

  /// No description provided for @recursion.
  ///
  /// In en, this message translates to:
  /// **'Recursion'**
  String get recursion;

  /// No description provided for @grades.
  ///
  /// In en, this message translates to:
  /// **'Grades'**
  String get grades;

  /// No description provided for @calendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendar;

  /// No description provided for @exam.
  ///
  /// In en, this message translates to:
  /// **'Exam'**
  String get exam;

  /// No description provided for @aiAssistant.
  ///
  /// In en, this message translates to:
  /// **'AI Assistant'**
  String get aiAssistant;

  /// No description provided for @myCoursesHeader.
  ///
  /// In en, this message translates to:
  /// **'My Courses'**
  String get myCoursesHeader;

  /// No description provided for @allEnrolledCoursesThisSemester.
  ///
  /// In en, this message translates to:
  /// **'All enrolled courses this semester'**
  String get allEnrolledCoursesThisSemester;

  /// No description provided for @searchCourseNameOrInstructor.
  ///
  /// In en, this message translates to:
  /// **'Search course name or instructor'**
  String get searchCourseNameOrInstructor;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @sort.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get sort;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @lectures.
  ///
  /// In en, this message translates to:
  /// **'Lectures'**
  String get lectures;

  /// No description provided for @labs.
  ///
  /// In en, this message translates to:
  /// **'Labs'**
  String get labs;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @missed.
  ///
  /// In en, this message translates to:
  /// **'Missed'**
  String get missed;

  /// No description provided for @joinCourse.
  ///
  /// In en, this message translates to:
  /// **'Join Course'**
  String get joinCourse;

  /// No description provided for @nextLecture.
  ///
  /// In en, this message translates to:
  /// **'Next Lecture'**
  String get nextLecture;

  /// No description provided for @aiLab.
  ///
  /// In en, this message translates to:
  /// **'AI Lab'**
  String get aiLab;

  /// No description provided for @nextAssignment.
  ///
  /// In en, this message translates to:
  /// **'Next Assignment'**
  String get nextAssignment;

  /// No description provided for @finalExam.
  ///
  /// In en, this message translates to:
  /// **'Final Exam'**
  String get finalExam;

  /// No description provided for @projectDue.
  ///
  /// In en, this message translates to:
  /// **'Project Due'**
  String get projectDue;

  /// No description provided for @nextLab.
  ///
  /// In en, this message translates to:
  /// **'Next Lab'**
  String get nextLab;

  /// No description provided for @review.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get review;

  /// No description provided for @introductionToAIDesc.
  ///
  /// In en, this message translates to:
  /// **'Introduction to AI'**
  String get introductionToAIDesc;

  /// No description provided for @drAlanTuring.
  ///
  /// In en, this message translates to:
  /// **'Dr. Alan Turing'**
  String get drAlanTuring;

  /// No description provided for @drGraceHopper.
  ///
  /// In en, this message translates to:
  /// **'Dr. Grace Hopper'**
  String get drGraceHopper;

  /// No description provided for @drYannLeCun.
  ///
  /// In en, this message translates to:
  /// **'Dr. Yann LeCun'**
  String get drYannLeCun;

  /// No description provided for @drAdaLovelace.
  ///
  /// In en, this message translates to:
  /// **'Dr. Ada Lovelace'**
  String get drAdaLovelace;

  /// No description provided for @drAndrewNg.
  ///
  /// In en, this message translates to:
  /// **'Dr. Andrew Ng'**
  String get drAndrewNg;

  /// No description provided for @drTimBernersLee.
  ///
  /// In en, this message translates to:
  /// **'Dr. Tim Berners-Lee'**
  String get drTimBernersLee;

  /// No description provided for @dataStructuresTitle.
  ///
  /// In en, this message translates to:
  /// **'Data Structures'**
  String get dataStructuresTitle;

  /// No description provided for @neuralNetworksTitle.
  ///
  /// In en, this message translates to:
  /// **'Neural Networks'**
  String get neuralNetworksTitle;

  /// No description provided for @cybersecurityEthicsTitle.
  ///
  /// In en, this message translates to:
  /// **'Cybersecurity Ethics'**
  String get cybersecurityEthicsTitle;

  /// No description provided for @machineLearningFundamentalsTitle.
  ///
  /// In en, this message translates to:
  /// **'Machine Learning Fundamentals'**
  String get machineLearningFundamentalsTitle;

  /// No description provided for @webDevelopmentTitle.
  ///
  /// In en, this message translates to:
  /// **'Web Development'**
  String get webDevelopmentTitle;

  /// No description provided for @aiQuizGenerator.
  ///
  /// In en, this message translates to:
  /// **'AI Quiz Generator'**
  String get aiQuizGenerator;

  /// No description provided for @createPersonalizedQuizzes.
  ///
  /// In en, this message translates to:
  /// **'Create personalized quizzes from your study materials.'**
  String get createPersonalizedQuizzes;

  /// No description provided for @selectCourse.
  ///
  /// In en, this message translates to:
  /// **'Select Course'**
  String get selectCourse;

  /// No description provided for @quizType.
  ///
  /// In en, this message translates to:
  /// **'Quiz'**
  String get quizType;

  /// No description provided for @mcq.
  ///
  /// In en, this message translates to:
  /// **'MCQ'**
  String get mcq;

  /// No description provided for @trueFalse.
  ///
  /// In en, this message translates to:
  /// **'True/False'**
  String get trueFalse;

  /// No description provided for @shortAnswer.
  ///
  /// In en, this message translates to:
  /// **'Short Answer'**
  String get shortAnswer;

  /// No description provided for @difficultyLevel.
  ///
  /// In en, this message translates to:
  /// **'Difficulty Level'**
  String get difficultyLevel;

  /// No description provided for @easy.
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get easy;

  /// No description provided for @medium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get medium;

  /// No description provided for @hard.
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get hard;

  /// No description provided for @numberOfQuestions.
  ///
  /// In en, this message translates to:
  /// **'Number of Questions:'**
  String get numberOfQuestions;

  /// No description provided for @includeWeakTopics.
  ///
  /// In en, this message translates to:
  /// **'Include weak topics (recommended by AI)'**
  String get includeWeakTopics;

  /// No description provided for @generateQuiz.
  ///
  /// In en, this message translates to:
  /// **'Generate Quiz'**
  String get generateQuiz;

  /// No description provided for @quiz.
  ///
  /// In en, this message translates to:
  /// **'Quiz'**
  String get quiz;

  /// No description provided for @question.
  ///
  /// In en, this message translates to:
  /// **'Question'**
  String get question;

  /// No description provided for @selectAnswer.
  ///
  /// In en, this message translates to:
  /// **'Select an answer'**
  String get selectAnswer;

  /// No description provided for @selectAnswers.
  ///
  /// In en, this message translates to:
  /// **'Select answers'**
  String get selectAnswers;

  /// No description provided for @submitQuiz.
  ///
  /// In en, this message translates to:
  /// **'Submit Quiz'**
  String get submitQuiz;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @correct.
  ///
  /// In en, this message translates to:
  /// **'Correct!'**
  String get correct;

  /// No description provided for @incorrect.
  ///
  /// In en, this message translates to:
  /// **'Incorrect!'**
  String get incorrect;

  /// No description provided for @score.
  ///
  /// In en, this message translates to:
  /// **'Score'**
  String get score;

  /// No description provided for @quizCompleted.
  ///
  /// In en, this message translates to:
  /// **'Quiz Completed'**
  String get quizCompleted;

  /// No description provided for @yourScore.
  ///
  /// In en, this message translates to:
  /// **'Your Score'**
  String get yourScore;

  /// No description provided for @youAnswered.
  ///
  /// In en, this message translates to:
  /// **'You answered'**
  String get youAnswered;

  /// No description provided for @correctAnswers.
  ///
  /// In en, this message translates to:
  /// **'correct answers'**
  String get correctAnswers;

  /// No description provided for @retakeQuiz.
  ///
  /// In en, this message translates to:
  /// **'Retake Quiz'**
  String get retakeQuiz;

  /// No description provided for @backToQuizScreen.
  ///
  /// In en, this message translates to:
  /// **'Back to Quiz Screen'**
  String get backToQuizScreen;

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No description provided for @notificationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Stay updated with your courses, deadlines, and AI alerts'**
  String get notificationSubtitle;

  /// No description provided for @notificationSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search announcements by keyword or course'**
  String get notificationSearchHint;

  /// No description provided for @notificationDeadlines.
  ///
  /// In en, this message translates to:
  /// **'Deadlines'**
  String get notificationDeadlines;

  /// No description provided for @notificationAIInsights.
  ///
  /// In en, this message translates to:
  /// **'AI Insights'**
  String get notificationAIInsights;

  /// No description provided for @notificationSmartAIInsights.
  ///
  /// In en, this message translates to:
  /// **'Smart AI Insights'**
  String get notificationSmartAIInsights;

  /// No description provided for @notificationSystemAlerts.
  ///
  /// In en, this message translates to:
  /// **'System Alerts'**
  String get notificationSystemAlerts;

  /// No description provided for @notificationRecentNotifications.
  ///
  /// In en, this message translates to:
  /// **'Recent Notifications'**
  String get notificationRecentNotifications;

  /// No description provided for @notificationItems.
  ///
  /// In en, this message translates to:
  /// **'notifications'**
  String get notificationItems;

  /// No description provided for @notificationToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get notificationToday;

  /// No description provided for @notificationThisWeek.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get notificationThisWeek;

  /// No description provided for @notificationEarlier.
  ///
  /// In en, this message translates to:
  /// **'Earlier'**
  String get notificationEarlier;

  /// No description provided for @notificationNoNotifications.
  ///
  /// In en, this message translates to:
  /// **'No Notifications'**
  String get notificationNoNotifications;

  /// No description provided for @notificationNoNotificationsDesc.
  ///
  /// In en, this message translates to:
  /// **'You\'re all caught up! Check back later for updates.'**
  String get notificationNoNotificationsDesc;

  /// No description provided for @notificationNoFiltered.
  ///
  /// In en, this message translates to:
  /// **'No Matching Notifications'**
  String get notificationNoFiltered;

  /// No description provided for @notificationNoFilteredDesc.
  ///
  /// In en, this message translates to:
  /// **'Try adjusting your filters or search query.'**
  String get notificationNoFilteredDesc;

  /// No description provided for @notificationClearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear Filters'**
  String get notificationClearFilters;

  /// No description provided for @notificationMarkRead.
  ///
  /// In en, this message translates to:
  /// **'Mark as Read'**
  String get notificationMarkRead;

  /// No description provided for @notificationMarkUnread.
  ///
  /// In en, this message translates to:
  /// **'Mark as Unread'**
  String get notificationMarkUnread;

  /// No description provided for @notificationMarkAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark All as Read'**
  String get notificationMarkAllRead;

  /// No description provided for @notificationMarkedAllRead.
  ///
  /// In en, this message translates to:
  /// **'All notifications marked as read'**
  String get notificationMarkedAllRead;

  /// No description provided for @notificationMarkedRead.
  ///
  /// In en, this message translates to:
  /// **'Marked as read'**
  String get notificationMarkedRead;

  /// No description provided for @notificationMarkedUnread.
  ///
  /// In en, this message translates to:
  /// **'Marked as unread'**
  String get notificationMarkedUnread;

  /// No description provided for @notificationClearRead.
  ///
  /// In en, this message translates to:
  /// **'Clear Read Notifications'**
  String get notificationClearRead;

  /// No description provided for @notificationClearReadConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to clear all read notifications?'**
  String get notificationClearReadConfirm;

  /// No description provided for @notificationReadCleared.
  ///
  /// In en, this message translates to:
  /// **'Read notifications cleared'**
  String get notificationReadCleared;

  /// No description provided for @notificationClearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear All Notifications'**
  String get notificationClearAll;

  /// No description provided for @notificationClearAllConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to clear all notifications? This action cannot be undone.'**
  String get notificationClearAllConfirm;

  /// No description provided for @notificationAllCleared.
  ///
  /// In en, this message translates to:
  /// **'All notifications cleared'**
  String get notificationAllCleared;

  /// No description provided for @notificationDeleted.
  ///
  /// In en, this message translates to:
  /// **'Notification deleted'**
  String get notificationDeleted;

  /// No description provided for @notificationConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get notificationConfirm;

  /// No description provided for @notificationPerformanceAlert.
  ///
  /// In en, this message translates to:
  /// **'Performance Alert'**
  String get notificationPerformanceAlert;

  /// No description provided for @notificationAIRecommendation.
  ///
  /// In en, this message translates to:
  /// **'AI Recommendation'**
  String get notificationAIRecommendation;

  /// No description provided for @notificationStudyTip.
  ///
  /// In en, this message translates to:
  /// **'Study Tip'**
  String get notificationStudyTip;

  /// No description provided for @notificationReminder.
  ///
  /// In en, this message translates to:
  /// **'Reminder'**
  String get notificationReminder;

  /// No description provided for @notificationJustNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get notificationJustNow;

  /// No description provided for @notificationMinutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 minute ago} other{{count} minutes ago}}'**
  String notificationMinutesAgo(int count);

  /// No description provided for @notificationHoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 hour ago} other{{count} hours ago}}'**
  String notificationHoursAgo(int count);

  /// No description provided for @notificationDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day ago} other{{count} days ago}}'**
  String notificationDaysAgo(int count);

  /// No description provided for @notificationYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get notificationYesterday;

  /// No description provided for @swipeActions.
  ///
  /// In en, this message translates to:
  /// **'Swipe Actions'**
  String get swipeActions;

  /// No description provided for @customizeSwipeGestures.
  ///
  /// In en, this message translates to:
  /// **'Customize notification swipe gestures'**
  String get customizeSwipeGestures;

  /// No description provided for @preview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get preview;

  /// No description provided for @swipeLeftAction.
  ///
  /// In en, this message translates to:
  /// **'Swipe Left Action'**
  String get swipeLeftAction;

  /// No description provided for @swipeRightAction.
  ///
  /// In en, this message translates to:
  /// **'Swipe Right Action'**
  String get swipeRightAction;

  /// No description provided for @additionalSettings.
  ///
  /// In en, this message translates to:
  /// **'Additional Settings'**
  String get additionalSettings;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @markAsRead.
  ///
  /// In en, this message translates to:
  /// **'Mark as Read'**
  String get markAsRead;

  /// No description provided for @markAsUnread.
  ///
  /// In en, this message translates to:
  /// **'Mark as Unread'**
  String get markAsUnread;

  /// No description provided for @archive.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get archive;

  /// No description provided for @bookmark.
  ///
  /// In en, this message translates to:
  /// **'Bookmark'**
  String get bookmark;

  /// No description provided for @noAction.
  ///
  /// In en, this message translates to:
  /// **'No Action'**
  String get noAction;

  /// No description provided for @deleteActionDesc.
  ///
  /// In en, this message translates to:
  /// **'Permanently remove the notification'**
  String get deleteActionDesc;

  /// No description provided for @markReadActionDesc.
  ///
  /// In en, this message translates to:
  /// **'Mark the notification as read'**
  String get markReadActionDesc;

  /// No description provided for @markUnreadActionDesc.
  ///
  /// In en, this message translates to:
  /// **'Mark the notification as unread'**
  String get markUnreadActionDesc;

  /// No description provided for @archiveActionDesc.
  ///
  /// In en, this message translates to:
  /// **'Archive the notification for later'**
  String get archiveActionDesc;

  /// No description provided for @bookmarkActionDesc.
  ///
  /// In en, this message translates to:
  /// **'Save notification for quick access'**
  String get bookmarkActionDesc;

  /// No description provided for @noActionDesc.
  ///
  /// In en, this message translates to:
  /// **'Disable this swipe direction'**
  String get noActionDesc;

  /// No description provided for @confirmBeforeAction.
  ///
  /// In en, this message translates to:
  /// **'Confirm Before Action'**
  String get confirmBeforeAction;

  /// No description provided for @confirmBeforeActionDesc.
  ///
  /// In en, this message translates to:
  /// **'Show confirmation for destructive actions'**
  String get confirmBeforeActionDesc;

  /// No description provided for @swipeSensitivity.
  ///
  /// In en, this message translates to:
  /// **'Swipe Sensitivity'**
  String get swipeSensitivity;

  /// No description provided for @swipeSensitivityDesc.
  ///
  /// In en, this message translates to:
  /// **'Adjust how far you need to swipe'**
  String get swipeSensitivityDesc;

  /// No description provided for @low.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get low;

  /// No description provided for @high.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get high;

  /// No description provided for @sampleNotificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Sample Notification'**
  String get sampleNotificationTitle;

  /// No description provided for @sampleNotificationBody.
  ///
  /// In en, this message translates to:
  /// **'Swipe left or right to see actions'**
  String get sampleNotificationBody;

  /// No description provided for @swipeToPreview.
  ///
  /// In en, this message translates to:
  /// **'Swipe on notifications to test'**
  String get swipeToPreview;

  /// No description provided for @searchTasks.
  ///
  /// In en, this message translates to:
  /// **'Search tasks...'**
  String get searchTasks;

  /// No description provided for @addTask.
  ///
  /// In en, this message translates to:
  /// **'Add Task'**
  String get addTask;

  /// No description provided for @editTask.
  ///
  /// In en, this message translates to:
  /// **'Edit Task'**
  String get editTask;

  /// No description provided for @deleteTask.
  ///
  /// In en, this message translates to:
  /// **'Delete Task'**
  String get deleteTask;

  /// No description provided for @deleteTaskConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this task?'**
  String get deleteTaskConfirmation;

  /// No description provided for @taskDeleted.
  ///
  /// In en, this message translates to:
  /// **'Task deleted'**
  String get taskDeleted;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @todayTasks.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get todayTasks;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @overdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get overdue;

  /// No description provided for @completedTasks.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completedTasks;

  /// No description provided for @inProgress.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get inProgress;

  /// No description provided for @upcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get upcoming;

  /// No description provided for @allTasks.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allTasks;

  /// No description provided for @noTasksFound.
  ///
  /// In en, this message translates to:
  /// **'No Tasks Found'**
  String get noTasksFound;

  /// No description provided for @noTasksDescription.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have any tasks yet. Add a new task to get started!'**
  String get noTasksDescription;

  /// No description provided for @sortBy.
  ///
  /// In en, this message translates to:
  /// **'Sort By'**
  String get sortBy;

  /// No description provided for @viewMode.
  ///
  /// In en, this message translates to:
  /// **'View Mode'**
  String get viewMode;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @dueDate.
  ///
  /// In en, this message translates to:
  /// **'Due Date'**
  String get dueDate;

  /// No description provided for @priority.
  ///
  /// In en, this message translates to:
  /// **'Priority'**
  String get priority;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @createdAt.
  ///
  /// In en, this message translates to:
  /// **'Created At'**
  String get createdAt;

  /// No description provided for @listView.
  ///
  /// In en, this message translates to:
  /// **'List'**
  String get listView;

  /// No description provided for @calendarView.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendarView;

  /// No description provided for @kanbanView.
  ///
  /// In en, this message translates to:
  /// **'Kanban'**
  String get kanbanView;

  /// No description provided for @clearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get clearAll;

  /// No description provided for @applyFilters.
  ///
  /// In en, this message translates to:
  /// **'Apply Filters'**
  String get applyFilters;

  /// No description provided for @bookmarked.
  ///
  /// In en, this message translates to:
  /// **'Bookmarked'**
  String get bookmarked;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @subtasks.
  ///
  /// In en, this message translates to:
  /// **'Subtasks'**
  String get subtasks;

  /// No description provided for @taskTitle.
  ///
  /// In en, this message translates to:
  /// **'Task Title'**
  String get taskTitle;

  /// No description provided for @enterTaskTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter task title'**
  String get enterTaskTitle;

  /// No description provided for @enterDescription.
  ///
  /// In en, this message translates to:
  /// **'Enter description'**
  String get enterDescription;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @pleaseEnterTaskTitle.
  ///
  /// In en, this message translates to:
  /// **'Please enter a task title'**
  String get pleaseEnterTaskTitle;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @tomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get tomorrow;

  /// No description provided for @daysAgo.
  ///
  /// In en, this message translates to:
  /// **'{count}d ago'**
  String daysAgo(int count);

  /// No description provided for @labsToday.
  ///
  /// In en, this message translates to:
  /// **'labs scheduled today'**
  String get labsToday;

  /// No description provided for @labsScheduled.
  ///
  /// In en, this message translates to:
  /// **'labs scheduled'**
  String get labsScheduled;

  /// No description provided for @searchLabs.
  ///
  /// In en, this message translates to:
  /// **'Search labs by title, course...'**
  String get searchLabs;

  /// No description provided for @noLabsFound.
  ///
  /// In en, this message translates to:
  /// **'No Labs Found'**
  String get noLabsFound;

  /// No description provided for @noLabsDescription.
  ///
  /// In en, this message translates to:
  /// **'There are no labs matching your criteria.'**
  String get noLabsDescription;

  /// No description provided for @labType.
  ///
  /// In en, this message translates to:
  /// **'Lab'**
  String get labType;

  /// No description provided for @virtual.
  ///
  /// In en, this message translates to:
  /// **'Virtual'**
  String get virtual;

  /// No description provided for @physical.
  ///
  /// In en, this message translates to:
  /// **'Physical'**
  String get physical;

  /// No description provided for @hybrid.
  ///
  /// In en, this message translates to:
  /// **'Hybrid'**
  String get hybrid;

  /// No description provided for @assignments.
  ///
  /// In en, this message translates to:
  /// **'Assignments'**
  String get assignments;

  /// No description provided for @assignmentsDue.
  ///
  /// In en, this message translates to:
  /// **'assignments due'**
  String get assignmentsDue;

  /// No description provided for @thisWeek.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get thisWeek;

  /// No description provided for @searchAssignments.
  ///
  /// In en, this message translates to:
  /// **'Search assignments by title, course...'**
  String get searchAssignments;

  /// No description provided for @noAssignmentsFound.
  ///
  /// In en, this message translates to:
  /// **'No Assignments Found'**
  String get noAssignmentsFound;

  /// No description provided for @noAssignmentsDescription.
  ///
  /// In en, this message translates to:
  /// **'There are no assignments matching your criteria.'**
  String get noAssignmentsDescription;

  /// No description provided for @dueToday.
  ///
  /// In en, this message translates to:
  /// **'due today'**
  String get dueToday;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @clearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear Filters'**
  String get clearFilters;

  /// No description provided for @submitted.
  ///
  /// In en, this message translates to:
  /// **'Submitted'**
  String get submitted;

  /// No description provided for @graded.
  ///
  /// In en, this message translates to:
  /// **'Graded'**
  String get graded;

  /// No description provided for @gradedAssignments.
  ///
  /// In en, this message translates to:
  /// **'graded assignments'**
  String get gradedAssignments;

  /// No description provided for @late.
  ///
  /// In en, this message translates to:
  /// **'Late'**
  String get late;

  /// No description provided for @assignmentType.
  ///
  /// In en, this message translates to:
  /// **'Assignment'**
  String get assignmentType;

  /// No description provided for @document.
  ///
  /// In en, this message translates to:
  /// **'Document'**
  String get document;

  /// No description provided for @code.
  ///
  /// In en, this message translates to:
  /// **'Code'**
  String get code;

  /// No description provided for @presentation.
  ///
  /// In en, this message translates to:
  /// **'Presentation'**
  String get presentation;

  /// No description provided for @project.
  ///
  /// In en, this message translates to:
  /// **'Project'**
  String get project;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @academicPerformance.
  ///
  /// In en, this message translates to:
  /// **'Academic Performance'**
  String get academicPerformance;

  /// No description provided for @cumulativeGPA.
  ///
  /// In en, this message translates to:
  /// **'Cumulative GPA'**
  String get cumulativeGPA;

  /// No description provided for @semesterGPA.
  ///
  /// In en, this message translates to:
  /// **'Semester GPA'**
  String get semesterGPA;

  /// No description provided for @credits.
  ///
  /// In en, this message translates to:
  /// **'Credits'**
  String get credits;

  /// No description provided for @searchCourses.
  ///
  /// In en, this message translates to:
  /// **'Search courses...'**
  String get searchCourses;

  /// No description provided for @allSemesters.
  ///
  /// In en, this message translates to:
  /// **'All Semesters'**
  String get allSemesters;

  /// No description provided for @current.
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get current;

  /// No description provided for @needsAttention.
  ///
  /// In en, this message translates to:
  /// **'Attention'**
  String get needsAttention;

  /// No description provided for @noCoursesFound.
  ///
  /// In en, this message translates to:
  /// **'No Courses Found'**
  String get noCoursesFound;

  /// No description provided for @tryAdjustingFilters.
  ///
  /// In en, this message translates to:
  /// **'Try adjusting your filters or search terms'**
  String get tryAdjustingFilters;

  /// No description provided for @filterByGrade.
  ///
  /// In en, this message translates to:
  /// **'Filter by Grade'**
  String get filterByGrade;

  /// No description provided for @filterAndSort.
  ///
  /// In en, this message translates to:
  /// **'Filter & Sort'**
  String get filterAndSort;

  /// No description provided for @gradeReport.
  ///
  /// In en, this message translates to:
  /// **'Grade Report'**
  String get gradeReport;

  /// No description provided for @generatingReport.
  ///
  /// In en, this message translates to:
  /// **'Generating report...'**
  String get generatingReport;

  /// No description provided for @reportGenerated.
  ///
  /// In en, this message translates to:
  /// **'Report generated successfully'**
  String get reportGenerated;

  /// No description provided for @assessments.
  ///
  /// In en, this message translates to:
  /// **'Assessments'**
  String get assessments;

  /// No description provided for @breakdown.
  ///
  /// In en, this message translates to:
  /// **'Breakdown'**
  String get breakdown;

  /// No description provided for @analysis.
  ///
  /// In en, this message translates to:
  /// **'Analysis'**
  String get analysis;

  /// No description provided for @byCategory.
  ///
  /// In en, this message translates to:
  /// **'By Category'**
  String get byCategory;

  /// No description provided for @weightDistribution.
  ///
  /// In en, this message translates to:
  /// **'Weight Distribution'**
  String get weightDistribution;

  /// No description provided for @performanceTrend.
  ///
  /// In en, this message translates to:
  /// **'Performance Trend'**
  String get performanceTrend;

  /// No description provided for @strengths.
  ///
  /// In en, this message translates to:
  /// **'Strengths'**
  String get strengths;

  /// No description provided for @areasForImprovement.
  ///
  /// In en, this message translates to:
  /// **'Areas for Improvement'**
  String get areasForImprovement;

  /// No description provided for @gradeProjections.
  ///
  /// In en, this message translates to:
  /// **'Grade Projections'**
  String get gradeProjections;

  /// No description provided for @gradeAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Grade Analysis'**
  String get gradeAnalysis;

  /// No description provided for @detailedPerformanceInsights.
  ///
  /// In en, this message translates to:
  /// **'Detailed Performance Insights'**
  String get detailedPerformanceInsights;

  /// No description provided for @overview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get overview;

  /// No description provided for @trends.
  ///
  /// In en, this message translates to:
  /// **'Trends'**
  String get trends;

  /// No description provided for @comparison.
  ///
  /// In en, this message translates to:
  /// **'Comparison'**
  String get comparison;

  /// No description provided for @insights.
  ///
  /// In en, this message translates to:
  /// **'Insights'**
  String get insights;

  /// No description provided for @academicStanding.
  ///
  /// In en, this message translates to:
  /// **'Academic Standing'**
  String get academicStanding;

  /// No description provided for @passRate.
  ///
  /// In en, this message translates to:
  /// **'Pass Rate'**
  String get passRate;

  /// No description provided for @highestGrade.
  ///
  /// In en, this message translates to:
  /// **'Highest Grade'**
  String get highestGrade;

  /// No description provided for @avgPercentage.
  ///
  /// In en, this message translates to:
  /// **'Avg Percentage'**
  String get avgPercentage;

  /// No description provided for @gradeDistribution.
  ///
  /// In en, this message translates to:
  /// **'Grade Distribution'**
  String get gradeDistribution;

  /// No description provided for @performanceMetrics.
  ///
  /// In en, this message translates to:
  /// **'Performance Metrics'**
  String get performanceMetrics;

  /// No description provided for @totalCourses.
  ///
  /// In en, this message translates to:
  /// **'Total Courses'**
  String get totalCourses;

  /// No description provided for @passed.
  ///
  /// In en, this message translates to:
  /// **'Passed'**
  String get passed;

  /// No description provided for @highest.
  ///
  /// In en, this message translates to:
  /// **'Highest'**
  String get highest;

  /// No description provided for @lowest.
  ///
  /// In en, this message translates to:
  /// **'Lowest'**
  String get lowest;

  /// No description provided for @creditProgress.
  ///
  /// In en, this message translates to:
  /// **'Credit Progress'**
  String get creditProgress;

  /// No description provided for @gpaTrend.
  ///
  /// In en, this message translates to:
  /// **'GPA Trend'**
  String get gpaTrend;

  /// No description provided for @semesterComparison.
  ///
  /// In en, this message translates to:
  /// **'Semester Comparison'**
  String get semesterComparison;

  /// No description provided for @courseRanking.
  ///
  /// In en, this message translates to:
  /// **'Course Ranking'**
  String get courseRanking;

  /// No description provided for @topPerformers.
  ///
  /// In en, this message translates to:
  /// **'Top Performers'**
  String get topPerformers;

  /// No description provided for @needsFocus.
  ///
  /// In en, this message translates to:
  /// **'Needs Focus'**
  String get needsFocus;

  /// No description provided for @aiInsights.
  ///
  /// In en, this message translates to:
  /// **'AI Insights'**
  String get aiInsights;

  /// No description provided for @personalizedRecommendations.
  ///
  /// In en, this message translates to:
  /// **'Personalized recommendations'**
  String get personalizedRecommendations;

  /// No description provided for @studyRecommendations.
  ///
  /// In en, this message translates to:
  /// **'Study Recommendations'**
  String get studyRecommendations;

  /// No description provided for @greatJob.
  ///
  /// In en, this message translates to:
  /// **'Great Job!'**
  String get greatJob;

  /// No description provided for @keepUpTheGoodWork.
  ///
  /// In en, this message translates to:
  /// **'Keep up the good work!'**
  String get keepUpTheGoodWork;

  /// No description provided for @academicGoals.
  ///
  /// In en, this message translates to:
  /// **'Academic Goals'**
  String get academicGoals;

  /// No description provided for @targetGPA.
  ///
  /// In en, this message translates to:
  /// **'Target GPA'**
  String get targetGPA;

  /// No description provided for @creditGoal.
  ///
  /// In en, this message translates to:
  /// **'Credit Goal'**
  String get creditGoal;

  /// No description provided for @setNewGoals.
  ///
  /// In en, this message translates to:
  /// **'Set New Goals'**
  String get setNewGoals;

  /// No description provided for @voiceToTextTitle.
  ///
  /// In en, this message translates to:
  /// **'Voice to Text'**
  String get voiceToTextTitle;

  /// No description provided for @voiceToTextSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Speak freely — EduVerse AI will turn your voice into structured notes'**
  String get voiceToTextSubtitle;

  /// No description provided for @voiceToTextTranscription.
  ///
  /// In en, this message translates to:
  /// **'Transcription'**
  String get voiceToTextTranscription;

  /// No description provided for @voiceToTextRecentRecordings.
  ///
  /// In en, this message translates to:
  /// **'Recent Recordings'**
  String get voiceToTextRecentRecordings;

  /// No description provided for @voiceToTextNoRecordings.
  ///
  /// In en, this message translates to:
  /// **'No Recordings Yet'**
  String get voiceToTextNoRecordings;

  /// No description provided for @voiceToTextNoRecordingsDesc.
  ///
  /// In en, this message translates to:
  /// **'Start recording to capture your voice and convert it to text.'**
  String get voiceToTextNoRecordingsDesc;

  /// No description provided for @voiceToTextListening.
  ///
  /// In en, this message translates to:
  /// **'Listening...'**
  String get voiceToTextListening;

  /// No description provided for @voiceToTextStartSpeaking.
  ///
  /// In en, this message translates to:
  /// **'Start speaking...'**
  String get voiceToTextStartSpeaking;

  /// No description provided for @voiceToTextWords.
  ///
  /// In en, this message translates to:
  /// **'words'**
  String get voiceToTextWords;

  /// No description provided for @voiceToTextCharacters.
  ///
  /// In en, this message translates to:
  /// **'characters'**
  String get voiceToTextCharacters;

  /// No description provided for @voiceToTextSaveRecording.
  ///
  /// In en, this message translates to:
  /// **'Save Recording'**
  String get voiceToTextSaveRecording;

  /// No description provided for @voiceToTextEnterTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter a title for this recording'**
  String get voiceToTextEnterTitle;

  /// No description provided for @voiceToTextDiscard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get voiceToTextDiscard;

  /// No description provided for @voiceToTextSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get voiceToTextSave;

  /// No description provided for @voiceToTextSaving.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get voiceToTextSaving;

  /// No description provided for @voiceToTextCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get voiceToTextCopy;

  /// No description provided for @voiceToTextSummarize.
  ///
  /// In en, this message translates to:
  /// **'Summarize'**
  String get voiceToTextSummarize;

  /// No description provided for @voiceToTextSummarizeComingSoon.
  ///
  /// In en, this message translates to:
  /// **'AI Summarization coming soon!'**
  String get voiceToTextSummarizeComingSoon;

  /// No description provided for @voiceToTextFavorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get voiceToTextFavorites;

  /// No description provided for @voiceToTextThisMonth.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get voiceToTextThisMonth;

  /// No description provided for @voiceToTextNewest.
  ///
  /// In en, this message translates to:
  /// **'Newest First'**
  String get voiceToTextNewest;

  /// No description provided for @voiceToTextOldest.
  ///
  /// In en, this message translates to:
  /// **'Oldest First'**
  String get voiceToTextOldest;

  /// No description provided for @voiceToTextLongest.
  ///
  /// In en, this message translates to:
  /// **'Longest First'**
  String get voiceToTextLongest;

  /// No description provided for @voiceToTextShortest.
  ///
  /// In en, this message translates to:
  /// **'Shortest First'**
  String get voiceToTextShortest;

  /// No description provided for @voiceToTextAlphabetical.
  ///
  /// In en, this message translates to:
  /// **'Alphabetical'**
  String get voiceToTextAlphabetical;

  /// No description provided for @voiceToTextAddFavorite.
  ///
  /// In en, this message translates to:
  /// **'Add to Favorites'**
  String get voiceToTextAddFavorite;

  /// No description provided for @voiceToTextRemoveFavorite.
  ///
  /// In en, this message translates to:
  /// **'Remove from Favorites'**
  String get voiceToTextRemoveFavorite;

  /// No description provided for @voiceToTextDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this recording? This action cannot be undone.'**
  String get voiceToTextDeleteConfirm;

  /// No description provided for @voiceToTextSettings.
  ///
  /// In en, this message translates to:
  /// **'Voice to Text Settings'**
  String get voiceToTextSettings;

  /// No description provided for @voiceToTextLanguage.
  ///
  /// In en, this message translates to:
  /// **'Recognition Language'**
  String get voiceToTextLanguage;

  /// No description provided for @voiceToTextLanguageDesc.
  ///
  /// In en, this message translates to:
  /// **'Language for speech recognition'**
  String get voiceToTextLanguageDesc;

  /// No description provided for @voiceToTextAutoPunctuation.
  ///
  /// In en, this message translates to:
  /// **'Auto-Punctuation'**
  String get voiceToTextAutoPunctuation;

  /// No description provided for @voiceToTextAutoPunctuationDesc.
  ///
  /// In en, this message translates to:
  /// **'Automatically add punctuation marks'**
  String get voiceToTextAutoPunctuationDesc;

  /// No description provided for @voiceToTextContinuousRecording.
  ///
  /// In en, this message translates to:
  /// **'Continuous Recording'**
  String get voiceToTextContinuousRecording;

  /// No description provided for @voiceToTextContinuousRecordingDesc.
  ///
  /// In en, this message translates to:
  /// **'Keep recording until manually stopped'**
  String get voiceToTextContinuousRecordingDesc;

  /// No description provided for @trackYourAttendance.
  ///
  /// In en, this message translates to:
  /// **'Track your class attendance'**
  String get trackYourAttendance;

  /// No description provided for @attendanceOverview.
  ///
  /// In en, this message translates to:
  /// **'Attendance Overview'**
  String get attendanceOverview;

  /// No description provided for @totalClasses.
  ///
  /// In en, this message translates to:
  /// **'Total Classes'**
  String get totalClasses;

  /// No description provided for @present.
  ///
  /// In en, this message translates to:
  /// **'Present'**
  String get present;

  /// No description provided for @absent.
  ///
  /// In en, this message translates to:
  /// **'Absent'**
  String get absent;

  /// No description provided for @excused.
  ///
  /// In en, this message translates to:
  /// **'Excused'**
  String get excused;

  /// No description provided for @distribution.
  ///
  /// In en, this message translates to:
  /// **'Distribution'**
  String get distribution;

  /// No description provided for @courseAttendance.
  ///
  /// In en, this message translates to:
  /// **'Course Attendance'**
  String get courseAttendance;

  /// No description provided for @noClassesOnThisDay.
  ///
  /// In en, this message translates to:
  /// **'No classes on this day'**
  String get noClassesOnThisDay;

  /// No description provided for @classesOnThisDay.
  ///
  /// In en, this message translates to:
  /// **'Classes on this day'**
  String get classesOnThisDay;

  /// No description provided for @noRecordsFound.
  ///
  /// In en, this message translates to:
  /// **'No Records Found'**
  String get noRecordsFound;

  /// No description provided for @noRecordsDescription.
  ///
  /// In en, this message translates to:
  /// **'No attendance records match your current filters.'**
  String get noRecordsDescription;

  /// No description provided for @records.
  ///
  /// In en, this message translates to:
  /// **'Records'**
  String get records;

  /// No description provided for @january.
  ///
  /// In en, this message translates to:
  /// **'January'**
  String get january;

  /// No description provided for @february.
  ///
  /// In en, this message translates to:
  /// **'February'**
  String get february;

  /// No description provided for @march.
  ///
  /// In en, this message translates to:
  /// **'March'**
  String get march;

  /// No description provided for @april.
  ///
  /// In en, this message translates to:
  /// **'April'**
  String get april;

  /// No description provided for @may.
  ///
  /// In en, this message translates to:
  /// **'May'**
  String get may;

  /// No description provided for @june.
  ///
  /// In en, this message translates to:
  /// **'June'**
  String get june;

  /// No description provided for @july.
  ///
  /// In en, this message translates to:
  /// **'July'**
  String get july;

  /// No description provided for @august.
  ///
  /// In en, this message translates to:
  /// **'August'**
  String get august;

  /// No description provided for @september.
  ///
  /// In en, this message translates to:
  /// **'September'**
  String get september;

  /// No description provided for @october.
  ///
  /// In en, this message translates to:
  /// **'October'**
  String get october;

  /// No description provided for @november.
  ///
  /// In en, this message translates to:
  /// **'November'**
  String get november;

  /// No description provided for @december.
  ///
  /// In en, this message translates to:
  /// **'December'**
  String get december;

  /// No description provided for @sun.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get sun;

  /// No description provided for @mon.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get mon;

  /// No description provided for @tue.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get tue;

  /// No description provided for @wed.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get wed;

  /// No description provided for @thu.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get thu;

  /// No description provided for @fri.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get fri;

  /// No description provided for @sat.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get sat;

  /// No description provided for @weeklyTrend.
  ///
  /// In en, this message translates to:
  /// **'Weekly Trend'**
  String get weeklyTrend;

  /// No description provided for @attendanceRate.
  ///
  /// In en, this message translates to:
  /// **'Attendance Rate'**
  String get attendanceRate;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @myFiles.
  ///
  /// In en, this message translates to:
  /// **'My Files'**
  String get myFiles;

  /// No description provided for @files.
  ///
  /// In en, this message translates to:
  /// **'files'**
  String get files;

  /// No description provided for @storage.
  ///
  /// In en, this message translates to:
  /// **'Storage'**
  String get storage;

  /// No description provided for @used.
  ///
  /// In en, this message translates to:
  /// **'used'**
  String get used;

  /// No description provided for @upload.
  ///
  /// In en, this message translates to:
  /// **'Upload'**
  String get upload;

  /// No description provided for @uploading.
  ///
  /// In en, this message translates to:
  /// **'Uploading'**
  String get uploading;

  /// No description provided for @uploadComplete.
  ///
  /// In en, this message translates to:
  /// **'Upload Complete'**
  String get uploadComplete;

  /// No description provided for @uploadFailed.
  ///
  /// In en, this message translates to:
  /// **'Upload Failed'**
  String get uploadFailed;

  /// No description provided for @selectingFiles.
  ///
  /// In en, this message translates to:
  /// **'Selecting files...'**
  String get selectingFiles;

  /// No description provided for @searchFiles.
  ///
  /// In en, this message translates to:
  /// **'Search files...'**
  String get searchFiles;

  /// No description provided for @selectFiles.
  ///
  /// In en, this message translates to:
  /// **'Select Files'**
  String get selectFiles;

  /// No description provided for @nameAZ.
  ///
  /// In en, this message translates to:
  /// **'Name (A-Z)'**
  String get nameAZ;

  /// No description provided for @nameZA.
  ///
  /// In en, this message translates to:
  /// **'Name (Z-A)'**
  String get nameZA;

  /// No description provided for @dateNewest.
  ///
  /// In en, this message translates to:
  /// **'Date (Newest)'**
  String get dateNewest;

  /// No description provided for @dateOldest.
  ///
  /// In en, this message translates to:
  /// **'Date (Oldest)'**
  String get dateOldest;

  /// No description provided for @sizeSmallest.
  ///
  /// In en, this message translates to:
  /// **'Size (Smallest)'**
  String get sizeSmallest;

  /// No description provided for @sizeLargest.
  ///
  /// In en, this message translates to:
  /// **'Size (Largest)'**
  String get sizeLargest;

  /// No description provided for @recent.
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get recent;

  /// No description provided for @favorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorites;

  /// No description provided for @documents.
  ///
  /// In en, this message translates to:
  /// **'Documents'**
  String get documents;

  /// No description provided for @images.
  ///
  /// In en, this message translates to:
  /// **'Images'**
  String get images;

  /// No description provided for @videos.
  ///
  /// In en, this message translates to:
  /// **'Videos'**
  String get videos;

  /// No description provided for @audio.
  ///
  /// In en, this message translates to:
  /// **'Audio'**
  String get audio;

  /// No description provided for @noFilesYet.
  ///
  /// In en, this message translates to:
  /// **'No Files Yet'**
  String get noFilesYet;

  /// No description provided for @uploadFilesDescription.
  ///
  /// In en, this message translates to:
  /// **'Upload your documents, images, videos and more. They\'ll be stored securely for easy access.'**
  String get uploadFilesDescription;

  /// No description provided for @uploadFirstFile.
  ///
  /// In en, this message translates to:
  /// **'Upload Your First File'**
  String get uploadFirstFile;

  /// No description provided for @supportedFormats.
  ///
  /// In en, this message translates to:
  /// **'Supported formats:'**
  String get supportedFormats;

  /// No description provided for @open.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get open;

  /// No description provided for @favorite.
  ///
  /// In en, this message translates to:
  /// **'Favorite'**
  String get favorite;

  /// No description provided for @unfavorite.
  ///
  /// In en, this message translates to:
  /// **'Unfavorite'**
  String get unfavorite;

  /// No description provided for @fileDetails.
  ///
  /// In en, this message translates to:
  /// **'File Details'**
  String get fileDetails;

  /// No description provided for @fileType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get fileType;

  /// No description provided for @size.
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get size;

  /// No description provided for @created.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get created;

  /// No description provided for @modified.
  ///
  /// In en, this message translates to:
  /// **'Modified'**
  String get modified;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @deleteFile.
  ///
  /// In en, this message translates to:
  /// **'Delete File'**
  String get deleteFile;

  /// No description provided for @deleteFiles.
  ///
  /// In en, this message translates to:
  /// **'Delete Files'**
  String get deleteFiles;

  /// No description provided for @deleteFileConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete'**
  String get deleteFileConfirmation;

  /// No description provided for @deleteFilesConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete the selected files?'**
  String get deleteFilesConfirmation;

  /// No description provided for @filesSelected.
  ///
  /// In en, this message translates to:
  /// **'files selected'**
  String get filesSelected;

  /// No description provided for @fileSelected.
  ///
  /// In en, this message translates to:
  /// **'file selected'**
  String get fileSelected;

  /// No description provided for @image.
  ///
  /// In en, this message translates to:
  /// **'Image'**
  String get image;

  /// No description provided for @video.
  ///
  /// In en, this message translates to:
  /// **'Video'**
  String get video;

  /// No description provided for @audioFile.
  ///
  /// In en, this message translates to:
  /// **'Audio File'**
  String get audioFile;

  /// No description provided for @spreadsheet.
  ///
  /// In en, this message translates to:
  /// **'Spreadsheet'**
  String get spreadsheet;

  /// No description provided for @codeFile.
  ///
  /// In en, this message translates to:
  /// **'Code File'**
  String get codeFile;

  /// No description provided for @file.
  ///
  /// In en, this message translates to:
  /// **'File'**
  String get file;

  /// No description provided for @summarizerTitle.
  ///
  /// In en, this message translates to:
  /// **'AI Lecture Summarizer'**
  String get summarizerTitle;

  /// No description provided for @summarizerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Generate short summaries from your uploaded materials or notes.'**
  String get summarizerSubtitle;

  /// No description provided for @summarizerUploadFile.
  ///
  /// In en, this message translates to:
  /// **'Upload File'**
  String get summarizerUploadFile;

  /// No description provided for @summarizerPasteText.
  ///
  /// In en, this message translates to:
  /// **'Paste Text'**
  String get summarizerPasteText;

  /// No description provided for @summarizerUploadTitle.
  ///
  /// In en, this message translates to:
  /// **'Upload lecture PDF or notes'**
  String get summarizerUploadTitle;

  /// No description provided for @summarizerDragDrop.
  ///
  /// In en, this message translates to:
  /// **'or drag and drop here'**
  String get summarizerDragDrop;

  /// No description provided for @summarizerBrowseFiles.
  ///
  /// In en, this message translates to:
  /// **'Browse files'**
  String get summarizerBrowseFiles;

  /// No description provided for @summarizerSupportedFormats.
  ///
  /// In en, this message translates to:
  /// **'PDF, DOC, DOCX, TXT, PPT, PPTX'**
  String get summarizerSupportedFormats;

  /// No description provided for @summarizerFileReady.
  ///
  /// In en, this message translates to:
  /// **'Ready to summarize'**
  String get summarizerFileReady;

  /// No description provided for @summarizerPasteHint.
  ///
  /// In en, this message translates to:
  /// **'Paste your notes or content here...'**
  String get summarizerPasteHint;

  /// No description provided for @summarizerCharacters.
  ///
  /// In en, this message translates to:
  /// **'characters'**
  String get summarizerCharacters;

  /// No description provided for @summarizerWords.
  ///
  /// In en, this message translates to:
  /// **'words'**
  String get summarizerWords;

  /// No description provided for @summarizerClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get summarizerClear;

  /// No description provided for @summarizerType.
  ///
  /// In en, this message translates to:
  /// **'Summarization Type'**
  String get summarizerType;

  /// No description provided for @summarizerSelectType.
  ///
  /// In en, this message translates to:
  /// **'Select Summary Type'**
  String get summarizerSelectType;

  /// No description provided for @summarizerKeyPoints.
  ///
  /// In en, this message translates to:
  /// **'Key Points'**
  String get summarizerKeyPoints;

  /// No description provided for @summarizerKeyPointsDesc.
  ///
  /// In en, this message translates to:
  /// **'Extract main ideas and highlights'**
  String get summarizerKeyPointsDesc;

  /// No description provided for @summarizerBrief.
  ///
  /// In en, this message translates to:
  /// **'Brief Summary'**
  String get summarizerBrief;

  /// No description provided for @summarizerBriefDesc.
  ///
  /// In en, this message translates to:
  /// **'Concise overview in a paragraph'**
  String get summarizerBriefDesc;

  /// No description provided for @summarizerDetailed.
  ///
  /// In en, this message translates to:
  /// **'Detailed Summary'**
  String get summarizerDetailed;

  /// No description provided for @summarizerDetailedDesc.
  ///
  /// In en, this message translates to:
  /// **'Comprehensive summary with sections'**
  String get summarizerDetailedDesc;

  /// No description provided for @summarizerBulletPoints.
  ///
  /// In en, this message translates to:
  /// **'Bullet Points'**
  String get summarizerBulletPoints;

  /// No description provided for @summarizerBulletPointsDesc.
  ///
  /// In en, this message translates to:
  /// **'Organized list format'**
  String get summarizerBulletPointsDesc;

  /// No description provided for @summarizerMindMap.
  ///
  /// In en, this message translates to:
  /// **'Mind Map'**
  String get summarizerMindMap;

  /// No description provided for @summarizerMindMapDesc.
  ///
  /// In en, this message translates to:
  /// **'Hierarchical structure format'**
  String get summarizerMindMapDesc;

  /// No description provided for @summarizerGenerate.
  ///
  /// In en, this message translates to:
  /// **'Generate Summary'**
  String get summarizerGenerate;

  /// No description provided for @summarizerGenerating.
  ///
  /// In en, this message translates to:
  /// **'Generating...'**
  String get summarizerGenerating;

  /// No description provided for @summarizerNoSummary.
  ///
  /// In en, this message translates to:
  /// **'No Summary Yet'**
  String get summarizerNoSummary;

  /// No description provided for @summarizerNoSummaryDesc.
  ///
  /// In en, this message translates to:
  /// **'Upload a file or paste your content, then click \"Generate Summary\" to get started.'**
  String get summarizerNoSummaryDesc;

  /// No description provided for @summarizerResult.
  ///
  /// In en, this message translates to:
  /// **'Summary Generated'**
  String get summarizerResult;

  /// No description provided for @summarizerCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get summarizerCopy;

  /// No description provided for @summarizerShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get summarizerShare;

  /// No description provided for @summarizerSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get summarizerSave;

  /// No description provided for @summarizerCopied.
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard'**
  String get summarizerCopied;

  /// No description provided for @summarizerSaved.
  ///
  /// In en, this message translates to:
  /// **'Summary saved successfully'**
  String get summarizerSaved;

  /// No description provided for @summarizerHistory.
  ///
  /// In en, this message translates to:
  /// **'Recent Summaries'**
  String get summarizerHistory;

  /// No description provided for @summarizerItems.
  ///
  /// In en, this message translates to:
  /// **'items'**
  String get summarizerItems;

  /// No description provided for @summarizerViewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get summarizerViewAll;

  /// No description provided for @summarizerAllHistory.
  ///
  /// In en, this message translates to:
  /// **'All Summaries'**
  String get summarizerAllHistory;

  /// No description provided for @summarizerDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete Summary?'**
  String get summarizerDeleteConfirm;

  /// No description provided for @summarizerDeleteConfirmDesc.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone.'**
  String get summarizerDeleteConfirmDesc;

  /// No description provided for @summarizerUploading.
  ///
  /// In en, this message translates to:
  /// **'Uploading...'**
  String get summarizerUploading;

  /// No description provided for @summarizerUploadFailed.
  ///
  /// In en, this message translates to:
  /// **'Upload Failed'**
  String get summarizerUploadFailed;

  /// No description provided for @smartStudyTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Smart Study Plan'**
  String get smartStudyTitle;

  /// No description provided for @smartStudySubtitle.
  ///
  /// In en, this message translates to:
  /// **'AI recommendations to help you focus on what matters most.'**
  String get smartStudySubtitle;

  /// No description provided for @smartStudyTopicsToReview.
  ///
  /// In en, this message translates to:
  /// **'Topics to Review'**
  String get smartStudyTopicsToReview;

  /// No description provided for @smartStudySchedule.
  ///
  /// In en, this message translates to:
  /// **'Study Schedule'**
  String get smartStudySchedule;

  /// No description provided for @smartStudyRegenerate.
  ///
  /// In en, this message translates to:
  /// **'Regenerate'**
  String get smartStudyRegenerate;

  /// No description provided for @smartStudyAllCourses.
  ///
  /// In en, this message translates to:
  /// **'All Courses'**
  String get smartStudyAllCourses;

  /// No description provided for @smartStudyAllDifficulty.
  ///
  /// In en, this message translates to:
  /// **'All Difficulty'**
  String get smartStudyAllDifficulty;

  /// No description provided for @smartStudyAllUrgency.
  ///
  /// In en, this message translates to:
  /// **'All Urgency'**
  String get smartStudyAllUrgency;

  /// No description provided for @smartStudySelectCourse.
  ///
  /// In en, this message translates to:
  /// **'Select Course'**
  String get smartStudySelectCourse;

  /// No description provided for @smartStudySelectDifficulty.
  ///
  /// In en, this message translates to:
  /// **'Select Difficulty'**
  String get smartStudySelectDifficulty;

  /// No description provided for @smartStudySelectUrgency.
  ///
  /// In en, this message translates to:
  /// **'Select Urgency'**
  String get smartStudySelectUrgency;

  /// No description provided for @smartStudyEasy.
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get smartStudyEasy;

  /// No description provided for @smartStudyMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get smartStudyMedium;

  /// No description provided for @smartStudyHard.
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get smartStudyHard;

  /// No description provided for @smartStudyHighUrgency.
  ///
  /// In en, this message translates to:
  /// **'High Urgency'**
  String get smartStudyHighUrgency;

  /// No description provided for @smartStudyMediumUrgency.
  ///
  /// In en, this message translates to:
  /// **'Medium Urgency'**
  String get smartStudyMediumUrgency;

  /// No description provided for @smartStudyLowUrgency.
  ///
  /// In en, this message translates to:
  /// **'Low Urgency'**
  String get smartStudyLowUrgency;

  /// No description provided for @smartStudyNoTopics.
  ///
  /// In en, this message translates to:
  /// **'No Topics Found'**
  String get smartStudyNoTopics;

  /// No description provided for @smartStudyNoTopicsHint.
  ///
  /// In en, this message translates to:
  /// **'Try adjusting your filters or regenerate the plan.'**
  String get smartStudyNoTopicsHint;

  /// No description provided for @smartStudyThisWeek.
  ///
  /// In en, this message translates to:
  /// **'This Week\'s Plan'**
  String get smartStudyThisWeek;

  /// No description provided for @smartStudySyncCalendar.
  ///
  /// In en, this message translates to:
  /// **'Sync Calendar'**
  String get smartStudySyncCalendar;

  /// No description provided for @smartStudyExportPdf.
  ///
  /// In en, this message translates to:
  /// **'Export PDF'**
  String get smartStudyExportPdf;

  /// No description provided for @smartStudyOptimize.
  ///
  /// In en, this message translates to:
  /// **'Optimize Plan'**
  String get smartStudyOptimize;

  /// No description provided for @smartStudyToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get smartStudyToday;

  /// No description provided for @smartStudyNoSchedule.
  ///
  /// In en, this message translates to:
  /// **'No Schedule Yet'**
  String get smartStudyNoSchedule;

  /// No description provided for @smartStudyNoScheduleHint.
  ///
  /// In en, this message translates to:
  /// **'Regenerate your plan to get a personalized schedule.'**
  String get smartStudyNoScheduleHint;

  /// No description provided for @smartStudySyncCalendarDesc.
  ///
  /// In en, this message translates to:
  /// **'Sync your study schedule with your device calendar?'**
  String get smartStudySyncCalendarDesc;

  /// No description provided for @smartStudyExportPdfDesc.
  ///
  /// In en, this message translates to:
  /// **'Export your weekly study plan as a PDF document?'**
  String get smartStudyExportPdfDesc;

  /// No description provided for @smartStudySyncSuccess.
  ///
  /// In en, this message translates to:
  /// **'Calendar synced successfully!'**
  String get smartStudySyncSuccess;

  /// No description provided for @smartStudyExportSuccess.
  ///
  /// In en, this message translates to:
  /// **'PDF exported successfully!'**
  String get smartStudyExportSuccess;

  /// No description provided for @smartStudyAiInsight.
  ///
  /// In en, this message translates to:
  /// **'AI Insight'**
  String get smartStudyAiInsight;

  /// No description provided for @smartStudyApplySuggestion.
  ///
  /// In en, this message translates to:
  /// **'Apply Suggestion'**
  String get smartStudyApplySuggestion;

  /// No description provided for @smartStudyInsightSaved.
  ///
  /// In en, this message translates to:
  /// **'Insight saved to bookmarks'**
  String get smartStudyInsightSaved;

  /// No description provided for @smartStudyQuickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get smartStudyQuickActions;

  /// No description provided for @smartStudyStartSession.
  ///
  /// In en, this message translates to:
  /// **'Start Study Session'**
  String get smartStudyStartSession;

  /// No description provided for @smartStudyStartSessionDesc.
  ///
  /// In en, this message translates to:
  /// **'Begin a focused learning session'**
  String get smartStudyStartSessionDesc;

  /// No description provided for @smartStudyQuickQuiz.
  ///
  /// In en, this message translates to:
  /// **'Quick Quiz'**
  String get smartStudyQuickQuiz;

  /// No description provided for @smartStudyQuickQuizDesc.
  ///
  /// In en, this message translates to:
  /// **'Test your knowledge in 5 minutes'**
  String get smartStudyQuickQuizDesc;

  /// No description provided for @smartStudyFlashcards.
  ///
  /// In en, this message translates to:
  /// **'Flashcards'**
  String get smartStudyFlashcards;

  /// No description provided for @smartStudyFlashcardsDesc.
  ///
  /// In en, this message translates to:
  /// **'Review key concepts quickly'**
  String get smartStudyFlashcardsDesc;

  /// No description provided for @gamificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Gamification & Leaderboard'**
  String get gamificationTitle;

  /// No description provided for @gamificationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Earn points, unlock badges, and climb the ranks with your peers.'**
  String get gamificationSubtitle;

  /// No description provided for @weekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get weekly;

  /// No description provided for @monthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthly;

  /// No description provided for @allTime.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allTime;

  /// No description provided for @level.
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get level;

  /// No description provided for @progressToNextRank.
  ///
  /// In en, this message translates to:
  /// **'Progress to next rank'**
  String get progressToNextRank;

  /// No description provided for @inYourCourse.
  ///
  /// In en, this message translates to:
  /// **'in your course'**
  String get inYourCourse;

  /// No description provided for @achievementsAndBadges.
  ///
  /// In en, this message translates to:
  /// **'Achievements & Badges'**
  String get achievementsAndBadges;

  /// No description provided for @allBadges.
  ///
  /// In en, this message translates to:
  /// **'All Badges'**
  String get allBadges;

  /// No description provided for @badgesDescription.
  ///
  /// In en, this message translates to:
  /// **'Unlock badges by completing achievements'**
  String get badgesDescription;

  /// No description provided for @unlocked.
  ///
  /// In en, this message translates to:
  /// **'Unlocked'**
  String get unlocked;

  /// No description provided for @required.
  ///
  /// In en, this message translates to:
  /// **'required'**
  String get required;

  /// No description provided for @global.
  ///
  /// In en, this message translates to:
  /// **'Global'**
  String get global;

  /// No description provided for @perCourse.
  ///
  /// In en, this message translates to:
  /// **'Per Course'**
  String get perCourse;

  /// No description provided for @friends.
  ///
  /// In en, this message translates to:
  /// **'Friends'**
  String get friends;

  /// No description provided for @findClassmate.
  ///
  /// In en, this message translates to:
  /// **'Find classmate'**
  String get findClassmate;

  /// No description provided for @compareProgress.
  ///
  /// In en, this message translates to:
  /// **'Compare Progress'**
  String get compareProgress;

  /// No description provided for @noResults.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noResults;

  /// No description provided for @compare.
  ///
  /// In en, this message translates to:
  /// **'Compare'**
  String get compare;

  /// No description provided for @users.
  ///
  /// In en, this message translates to:
  /// **'users'**
  String get users;

  /// No description provided for @progressComparison.
  ///
  /// In en, this message translates to:
  /// **'Progress Comparison'**
  String get progressComparison;

  /// No description provided for @keepItUp.
  ///
  /// In en, this message translates to:
  /// **'Keep it up!'**
  String get keepItUp;

  /// No description provided for @youreOnly.
  ///
  /// In en, this message translates to:
  /// **'You\'re only'**
  String get youreOnly;

  /// No description provided for @awayFromSurpassing.
  ///
  /// In en, this message translates to:
  /// **'away from surpassing'**
  String get awayFromSurpassing;

  /// No description provided for @viewRewardsShop.
  ///
  /// In en, this message translates to:
  /// **'View Rewards & Shop'**
  String get viewRewardsShop;

  /// No description provided for @rewardsShop.
  ///
  /// In en, this message translates to:
  /// **'Rewards & Shop'**
  String get rewardsShop;

  /// No description provided for @rewards.
  ///
  /// In en, this message translates to:
  /// **'Rewards'**
  String get rewards;

  /// No description provided for @dailyRewards.
  ///
  /// In en, this message translates to:
  /// **'Daily Rewards'**
  String get dailyRewards;

  /// No description provided for @dailyReward.
  ///
  /// In en, this message translates to:
  /// **'Daily Reward'**
  String get dailyReward;

  /// No description provided for @claimYourDailyReward.
  ///
  /// In en, this message translates to:
  /// **'Claim your daily reward to earn coins and XP!'**
  String get claimYourDailyReward;

  /// No description provided for @coins.
  ///
  /// In en, this message translates to:
  /// **'Coins'**
  String get coins;

  /// No description provided for @claimReward.
  ///
  /// In en, this message translates to:
  /// **'Claim Reward'**
  String get claimReward;

  /// No description provided for @currentStreak.
  ///
  /// In en, this message translates to:
  /// **'Current Streak'**
  String get currentStreak;

  /// No description provided for @days.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get days;

  /// No description provided for @nextBonus.
  ///
  /// In en, this message translates to:
  /// **'Next Bonus'**
  String get nextBonus;

  /// No description provided for @weeklyBonus.
  ///
  /// In en, this message translates to:
  /// **'Weekly Bonus'**
  String get weeklyBonus;

  /// No description provided for @completeWeeklyGoals.
  ///
  /// In en, this message translates to:
  /// **'Complete weekly goals for bonus rewards'**
  String get completeWeeklyGoals;

  /// No description provided for @goalsCompleted.
  ///
  /// In en, this message translates to:
  /// **'goals completed'**
  String get goalsCompleted;

  /// No description provided for @noRewardsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No rewards available'**
  String get noRewardsAvailable;

  /// No description provided for @notEnoughCoins.
  ///
  /// In en, this message translates to:
  /// **'Not enough coins'**
  String get notEnoughCoins;

  /// No description provided for @purchase.
  ///
  /// In en, this message translates to:
  /// **'Purchase'**
  String get purchase;

  /// No description provided for @owned.
  ///
  /// In en, this message translates to:
  /// **'Owned'**
  String get owned;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @privacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get privacy;

  /// No description provided for @help.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get help;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @aiAssistantTitle.
  ///
  /// In en, this message translates to:
  /// **'EduVerse AI Assistant'**
  String get aiAssistantTitle;

  /// No description provided for @aiAssistantSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Ask questions, generate quizzes, or get personalized help anytime.'**
  String get aiAssistantSubtitle;

  /// No description provided for @generalHelp.
  ///
  /// In en, this message translates to:
  /// **'General Help'**
  String get generalHelp;

  /// No description provided for @courseSpecificMode.
  ///
  /// In en, this message translates to:
  /// **'Course-Specific'**
  String get courseSpecificMode;

  /// No description provided for @aiTutorMode.
  ///
  /// In en, this message translates to:
  /// **'AI Tutor'**
  String get aiTutorMode;

  /// No description provided for @clearChat.
  ///
  /// In en, this message translates to:
  /// **'Clear Chat'**
  String get clearChat;

  /// No description provided for @clearChatConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to clear the chat history? This action cannot be undone.'**
  String get clearChatConfirm;

  /// No description provided for @attachFile.
  ///
  /// In en, this message translates to:
  /// **'Attach File'**
  String get attachFile;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @typeMessageHint.
  ///
  /// In en, this message translates to:
  /// **'Type your message...'**
  String get typeMessageHint;

  /// No description provided for @listeningHint.
  ///
  /// In en, this message translates to:
  /// **'Listening...'**
  String get listeningHint;

  /// No description provided for @aiChatWelcome.
  ///
  /// In en, this message translates to:
  /// **'Hello! I\'m your AI Assistant'**
  String get aiChatWelcome;

  /// No description provided for @aiChatWelcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Ask me anything about your courses, generate quizzes, or get help with concepts.'**
  String get aiChatWelcomeSubtitle;

  /// No description provided for @aiSuggestion1.
  ///
  /// In en, this message translates to:
  /// **'Summarize my last lecture'**
  String get aiSuggestion1;

  /// No description provided for @aiSuggestion2.
  ///
  /// In en, this message translates to:
  /// **'Generate practice quiz questions'**
  String get aiSuggestion2;

  /// No description provided for @aiSuggestion3.
  ///
  /// In en, this message translates to:
  /// **'Explain a complex concept simply'**
  String get aiSuggestion3;

  /// No description provided for @calendarTitle.
  ///
  /// In en, this message translates to:
  /// **'Smart Calendar & Schedule'**
  String get calendarTitle;

  /// No description provided for @calendarSubtitle.
  ///
  /// In en, this message translates to:
  /// **'View all your lectures, labs, quizzes, and deadlines in one place.'**
  String get calendarSubtitle;

  /// No description provided for @addEvent.
  ///
  /// In en, this message translates to:
  /// **'Add Event'**
  String get addEvent;

  /// No description provided for @filters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filters;

  /// No description provided for @lecturesFilter.
  ///
  /// In en, this message translates to:
  /// **'Lectures'**
  String get lecturesFilter;

  /// No description provided for @labsFilter.
  ///
  /// In en, this message translates to:
  /// **'Labs'**
  String get labsFilter;

  /// No description provided for @assignmentsFilter.
  ///
  /// In en, this message translates to:
  /// **'Assignments'**
  String get assignmentsFilter;

  /// No description provided for @examsFilter.
  ///
  /// In en, this message translates to:
  /// **'Exams'**
  String get examsFilter;

  /// No description provided for @personalTasksFilter.
  ///
  /// In en, this message translates to:
  /// **'Personal Tasks'**
  String get personalTasksFilter;

  /// No description provided for @monthView.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get monthView;

  /// No description provided for @weekView.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get weekView;

  /// No description provided for @dayView.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get dayView;

  /// No description provided for @upcomingEvents.
  ///
  /// In en, this message translates to:
  /// **'Upcoming Events'**
  String get upcomingEvents;

  /// No description provided for @noUpcomingEvents.
  ///
  /// In en, this message translates to:
  /// **'No upcoming events'**
  String get noUpcomingEvents;

  /// No description provided for @addYourFirstEvent.
  ///
  /// In en, this message translates to:
  /// **'Add Your First Event'**
  String get addYourFirstEvent;

  /// No description provided for @addNewEvent.
  ///
  /// In en, this message translates to:
  /// **'Add New Event'**
  String get addNewEvent;

  /// No description provided for @getAiSuggestedTime.
  ///
  /// In en, this message translates to:
  /// **'Get AI-Suggested Time Slot'**
  String get getAiSuggestedTime;

  /// No description provided for @aiSuggestedTime.
  ///
  /// In en, this message translates to:
  /// **'AI Suggested Time'**
  String get aiSuggestedTime;

  /// No description provided for @eventTitle.
  ///
  /// In en, this message translates to:
  /// **'Event Title'**
  String get eventTitle;

  /// No description provided for @eventTitleHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Operating Systems Lecture'**
  String get eventTitleHint;

  /// No description provided for @eventType.
  ///
  /// In en, this message translates to:
  /// **'Event Type'**
  String get eventType;

  /// No description provided for @course.
  ///
  /// In en, this message translates to:
  /// **'Course'**
  String get course;

  /// No description provided for @courseHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Operating Systems'**
  String get courseHint;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @time.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// No description provided for @locationHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Room 301, Building A'**
  String get locationHint;

  /// No description provided for @descriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Add notes or details about this event...'**
  String get descriptionHint;

  /// No description provided for @optional.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get optional;

  /// No description provided for @lectureType.
  ///
  /// In en, this message translates to:
  /// **'Lecture'**
  String get lectureType;

  /// No description provided for @examType.
  ///
  /// In en, this message translates to:
  /// **'Exam'**
  String get examType;

  /// No description provided for @personalTaskType.
  ///
  /// In en, this message translates to:
  /// **'Personal Task'**
  String get personalTaskType;

  /// No description provided for @chatTitle.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get chatTitle;

  /// No description provided for @chatSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Connect with instructors and classmates'**
  String get chatSubtitle;

  /// No description provided for @newChat.
  ///
  /// In en, this message translates to:
  /// **'New Chat'**
  String get newChat;

  /// No description provided for @newConversation.
  ///
  /// In en, this message translates to:
  /// **'New Conversation'**
  String get newConversation;

  /// No description provided for @searchConversations.
  ///
  /// In en, this message translates to:
  /// **'Search conversations...'**
  String get searchConversations;

  /// No description provided for @searchByNameOrEmail.
  ///
  /// In en, this message translates to:
  /// **'Search by name or email...'**
  String get searchByNameOrEmail;

  /// No description provided for @noConversations.
  ///
  /// In en, this message translates to:
  /// **'No Conversations Yet'**
  String get noConversations;

  /// No description provided for @noConversationsDesc.
  ///
  /// In en, this message translates to:
  /// **'Start a new conversation with instructors, students, or join course discussions.'**
  String get noConversationsDesc;

  /// No description provided for @noMatchingConversations.
  ///
  /// In en, this message translates to:
  /// **'No Matching Conversations'**
  String get noMatchingConversations;

  /// No description provided for @noMatchingConversationsDesc.
  ///
  /// In en, this message translates to:
  /// **'Try adjusting your filters or search query to find conversations.'**
  String get noMatchingConversationsDesc;

  /// No description provided for @startNewChat.
  ///
  /// In en, this message translates to:
  /// **'Start New Chat'**
  String get startNewChat;

  /// No description provided for @pinned.
  ///
  /// In en, this message translates to:
  /// **'Pinned'**
  String get pinned;

  /// No description provided for @conversations.
  ///
  /// In en, this message translates to:
  /// **'Conversations'**
  String get conversations;

  /// No description provided for @unread.
  ///
  /// In en, this message translates to:
  /// **'Unread'**
  String get unread;

  /// No description provided for @groups.
  ///
  /// In en, this message translates to:
  /// **'Groups'**
  String get groups;

  /// No description provided for @createGroup.
  ///
  /// In en, this message translates to:
  /// **'Create Group'**
  String get createGroup;

  /// No description provided for @joinCourseChat.
  ///
  /// In en, this message translates to:
  /// **'Join Course Chat'**
  String get joinCourseChat;

  /// No description provided for @suggestedContacts.
  ///
  /// In en, this message translates to:
  /// **'Suggested Contacts'**
  String get suggestedContacts;

  /// No description provided for @noUsersFound.
  ///
  /// In en, this message translates to:
  /// **'No users found'**
  String get noUsersFound;

  /// No description provided for @online.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get online;

  /// No description provided for @offline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get offline;

  /// No description provided for @away.
  ///
  /// In en, this message translates to:
  /// **'Away'**
  String get away;

  /// No description provided for @busy.
  ///
  /// In en, this message translates to:
  /// **'Busy'**
  String get busy;

  /// No description provided for @loadingMessages.
  ///
  /// In en, this message translates to:
  /// **'Loading messages...'**
  String get loadingMessages;

  /// No description provided for @noMessagesYet.
  ///
  /// In en, this message translates to:
  /// **'No messages yet'**
  String get noMessagesYet;

  /// No description provided for @startConversation.
  ///
  /// In en, this message translates to:
  /// **'Start the conversation by sending a message'**
  String get startConversation;

  /// No description provided for @replyingTo.
  ///
  /// In en, this message translates to:
  /// **'Replying to'**
  String get replyingTo;

  /// No description provided for @reply.
  ///
  /// In en, this message translates to:
  /// **'Reply'**
  String get reply;

  /// No description provided for @copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// No description provided for @forward.
  ///
  /// In en, this message translates to:
  /// **'Forward'**
  String get forward;

  /// No description provided for @copiedToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard'**
  String get copiedToClipboard;

  /// No description provided for @searchInConversation.
  ///
  /// In en, this message translates to:
  /// **'Search in conversation'**
  String get searchInConversation;

  /// No description provided for @muteNotifications.
  ///
  /// In en, this message translates to:
  /// **'Mute notifications'**
  String get muteNotifications;

  /// No description provided for @unmute.
  ///
  /// In en, this message translates to:
  /// **'Unmute'**
  String get unmute;

  /// No description provided for @blockUser.
  ///
  /// In en, this message translates to:
  /// **'Block user'**
  String get blockUser;

  /// No description provided for @pinChat.
  ///
  /// In en, this message translates to:
  /// **'Pin Chat'**
  String get pinChat;

  /// No description provided for @deleteConversation.
  ///
  /// In en, this message translates to:
  /// **'Delete Conversation'**
  String get deleteConversation;

  /// No description provided for @deleteConversationConfirm.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete the conversation. This action cannot be undone.'**
  String get deleteConversationConfirm;

  /// No description provided for @photo.
  ///
  /// In en, this message translates to:
  /// **'Photo'**
  String get photo;

  /// No description provided for @featureComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Feature coming soon!'**
  String get featureComingSoon;

  /// No description provided for @groupCreationComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Group creation coming soon!'**
  String get groupCreationComingSoon;

  /// No description provided for @courseChatComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Course chat feature coming soon!'**
  String get courseChatComingSoon;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @justNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get justNow;

  /// No description provided for @chatSwipeActions.
  ///
  /// In en, this message translates to:
  /// **'Swipe Actions'**
  String get chatSwipeActions;

  /// No description provided for @chatSwipeActionsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Customize chat swipe gestures'**
  String get chatSwipeActionsSubtitle;

  /// No description provided for @chatPin.
  ///
  /// In en, this message translates to:
  /// **'Pin'**
  String get chatPin;

  /// No description provided for @chatUnpin.
  ///
  /// In en, this message translates to:
  /// **'Unpin'**
  String get chatUnpin;

  /// No description provided for @chatMute.
  ///
  /// In en, this message translates to:
  /// **'Mute'**
  String get chatMute;

  /// No description provided for @chatUnmute.
  ///
  /// In en, this message translates to:
  /// **'Unmute'**
  String get chatUnmute;

  /// No description provided for @chatDeleteConversation.
  ///
  /// In en, this message translates to:
  /// **'Delete Chat'**
  String get chatDeleteConversation;

  /// No description provided for @chatArchiveConversation.
  ///
  /// In en, this message translates to:
  /// **'Archive Chat'**
  String get chatArchiveConversation;

  /// No description provided for @chatDeleteConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this conversation? This action cannot be undone.'**
  String get chatDeleteConfirmMessage;

  /// No description provided for @chatArchiveConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'This conversation will be moved to your archive. You can restore it anytime.'**
  String get chatArchiveConfirmMessage;

  /// No description provided for @chatSampleTitle.
  ///
  /// In en, this message translates to:
  /// **'Sample Conversation'**
  String get chatSampleTitle;

  /// No description provided for @chatSampleMessage.
  ///
  /// In en, this message translates to:
  /// **'Swipe left or right to see actions'**
  String get chatSampleMessage;

  /// No description provided for @chatDeleteDesc.
  ///
  /// In en, this message translates to:
  /// **'Permanently remove conversation'**
  String get chatDeleteDesc;

  /// No description provided for @chatArchiveDesc.
  ///
  /// In en, this message translates to:
  /// **'Move to archive folder'**
  String get chatArchiveDesc;

  /// No description provided for @chatPinDesc.
  ///
  /// In en, this message translates to:
  /// **'Keep at top of conversation list'**
  String get chatPinDesc;

  /// No description provided for @chatMuteDesc.
  ///
  /// In en, this message translates to:
  /// **'Disable notifications'**
  String get chatMuteDesc;

  /// No description provided for @chatMarkReadDesc.
  ///
  /// In en, this message translates to:
  /// **'Mark conversation as read'**
  String get chatMarkReadDesc;

  /// No description provided for @chatMarkUnreadDesc.
  ///
  /// In en, this message translates to:
  /// **'Mark conversation as unread'**
  String get chatMarkUnreadDesc;

  /// No description provided for @chatNoneDesc.
  ///
  /// In en, this message translates to:
  /// **'No action on this direction'**
  String get chatNoneDesc;

  /// No description provided for @none.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get none;

  /// No description provided for @aiNotesSummaries.
  ///
  /// In en, this message translates to:
  /// **'AI Notes & Summaries'**
  String get aiNotesSummaries;

  /// No description provided for @aiNotesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'AI-powered notes from your lectures'**
  String get aiNotesSubtitle;

  /// No description provided for @searchNotesHint.
  ///
  /// In en, this message translates to:
  /// **'Search notes by course, topic, or keyword...'**
  String get searchNotesHint;

  /// No description provided for @allNotes.
  ///
  /// In en, this message translates to:
  /// **'All Notes'**
  String get allNotes;

  /// No description provided for @byCourse.
  ///
  /// In en, this message translates to:
  /// **'By Course'**
  String get byCourse;

  /// No description provided for @byDate.
  ///
  /// In en, this message translates to:
  /// **'By Date'**
  String get byDate;

  /// No description provided for @newestFirst.
  ///
  /// In en, this message translates to:
  /// **'Newest First'**
  String get newestFirst;

  /// No description provided for @oldestFirst.
  ///
  /// In en, this message translates to:
  /// **'Oldest First'**
  String get oldestFirst;

  /// No description provided for @titleAZ.
  ///
  /// In en, this message translates to:
  /// **'Title A-Z'**
  String get titleAZ;

  /// No description provided for @titleZA.
  ///
  /// In en, this message translates to:
  /// **'Title Z-A'**
  String get titleZA;

  /// No description provided for @courseAZ.
  ///
  /// In en, this message translates to:
  /// **'Course A-Z'**
  String get courseAZ;

  /// No description provided for @quickStats.
  ///
  /// In en, this message translates to:
  /// **'Quick Stats'**
  String get quickStats;

  /// No description provided for @totalNotes.
  ///
  /// In en, this message translates to:
  /// **'Total Notes'**
  String get totalNotes;

  /// No description provided for @favorited.
  ///
  /// In en, this message translates to:
  /// **'Favorited'**
  String get favorited;

  /// No description provided for @aiStudyRecommendations.
  ///
  /// In en, this message translates to:
  /// **'AI Study Recommendations'**
  String get aiStudyRecommendations;

  /// No description provided for @reviewTopic.
  ///
  /// In en, this message translates to:
  /// **'Review Topic'**
  String get reviewTopic;

  /// No description provided for @relatedConcept.
  ///
  /// In en, this message translates to:
  /// **'Related Concept'**
  String get relatedConcept;

  /// No description provided for @upcomingQuiz.
  ///
  /// In en, this message translates to:
  /// **'Upcoming Quiz'**
  String get upcomingQuiz;

  /// No description provided for @generateFlashcards.
  ///
  /// In en, this message translates to:
  /// **'Generate Flashcards'**
  String get generateFlashcards;

  /// No description provided for @fromYourNotes.
  ///
  /// In en, this message translates to:
  /// **'From your notes'**
  String get fromYourNotes;

  /// No description provided for @newLabel.
  ///
  /// In en, this message translates to:
  /// **'NEW'**
  String get newLabel;

  /// No description provided for @inDays.
  ///
  /// In en, this message translates to:
  /// **'In'**
  String get inDays;

  /// No description provided for @yourNotes.
  ///
  /// In en, this message translates to:
  /// **'Your Notes'**
  String get yourNotes;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'notes'**
  String get notes;

  /// No description provided for @topics.
  ///
  /// In en, this message translates to:
  /// **'topics'**
  String get topics;

  /// No description provided for @viewStructure.
  ///
  /// In en, this message translates to:
  /// **'View Structure'**
  String get viewStructure;

  /// No description provided for @showLess.
  ///
  /// In en, this message translates to:
  /// **'Show Less'**
  String get showLess;

  /// No description provided for @shareNotePreparing.
  ///
  /// In en, this message translates to:
  /// **'Preparing note for sharing...'**
  String get shareNotePreparing;

  /// No description provided for @copyToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Copy to Clipboard'**
  String get copyToClipboard;

  /// No description provided for @downloadPdf.
  ///
  /// In en, this message translates to:
  /// **'Download PDF'**
  String get downloadPdf;

  /// No description provided for @pdfDownloadStarted.
  ///
  /// In en, this message translates to:
  /// **'PDF download started'**
  String get pdfDownloadStarted;

  /// No description provided for @translateNote.
  ///
  /// In en, this message translates to:
  /// **'Translate Note'**
  String get translateNote;

  /// No description provided for @translationInProgress.
  ///
  /// In en, this message translates to:
  /// **'Translation in progress...'**
  String get translationInProgress;

  /// No description provided for @deleteNote.
  ///
  /// In en, this message translates to:
  /// **'Delete Note'**
  String get deleteNote;

  /// No description provided for @deleteNoteConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this note? This action cannot be undone.'**
  String get deleteNoteConfirmation;

  /// No description provided for @noteDetails.
  ///
  /// In en, this message translates to:
  /// **'Note Details'**
  String get noteDetails;

  /// No description provided for @keyTopics.
  ///
  /// In en, this message translates to:
  /// **'Key Topics'**
  String get keyTopics;

  /// No description provided for @updated.
  ///
  /// In en, this message translates to:
  /// **'Updated'**
  String get updated;

  /// No description provided for @translate.
  ///
  /// In en, this message translates to:
  /// **'Translate'**
  String get translate;

  /// No description provided for @regenerate.
  ///
  /// In en, this message translates to:
  /// **'Regenerate'**
  String get regenerate;

  /// No description provided for @summarize.
  ///
  /// In en, this message translates to:
  /// **'Summarize'**
  String get summarize;

  /// No description provided for @errorLoadingNotes.
  ///
  /// In en, this message translates to:
  /// **'Error Loading Notes'**
  String get errorLoadingNotes;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @dismiss.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get dismiss;

  /// No description provided for @generateNotes.
  ///
  /// In en, this message translates to:
  /// **'Generate Notes'**
  String get generateNotes;

  /// No description provided for @generateNewNotes.
  ///
  /// In en, this message translates to:
  /// **'Generate New Notes'**
  String get generateNewNotes;

  /// No description provided for @generateNotesDescription.
  ///
  /// In en, this message translates to:
  /// **'Create AI-powered notes from various sources'**
  String get generateNotesDescription;

  /// No description provided for @uploadDocument.
  ///
  /// In en, this message translates to:
  /// **'Upload Document'**
  String get uploadDocument;

  /// No description provided for @uploadDocumentDescription.
  ///
  /// In en, this message translates to:
  /// **'PDF, Word, or text files'**
  String get uploadDocumentDescription;

  /// No description provided for @fromVideo.
  ///
  /// In en, this message translates to:
  /// **'From Video'**
  String get fromVideo;

  /// No description provided for @fromVideoDescription.
  ///
  /// In en, this message translates to:
  /// **'YouTube or uploaded video'**
  String get fromVideoDescription;

  /// No description provided for @fromUrl.
  ///
  /// In en, this message translates to:
  /// **'From URL'**
  String get fromUrl;

  /// No description provided for @fromUrlDescription.
  ///
  /// In en, this message translates to:
  /// **'Web article or blog post'**
  String get fromUrlDescription;

  /// No description provided for @fromAudio.
  ///
  /// In en, this message translates to:
  /// **'From Audio'**
  String get fromAudio;

  /// No description provided for @fromAudioDescription.
  ///
  /// In en, this message translates to:
  /// **'Record or upload audio'**
  String get fromAudioDescription;

  /// No description provided for @notesSettings.
  ///
  /// In en, this message translates to:
  /// **'Notes Settings'**
  String get notesSettings;

  /// No description provided for @exportAllNotes.
  ///
  /// In en, this message translates to:
  /// **'Export All Notes'**
  String get exportAllNotes;

  /// No description provided for @exportStarted.
  ///
  /// In en, this message translates to:
  /// **'Export started'**
  String get exportStarted;

  /// No description provided for @syncWithCloud.
  ///
  /// In en, this message translates to:
  /// **'Sync with Cloud'**
  String get syncWithCloud;

  /// No description provided for @syncInProgress.
  ///
  /// In en, this message translates to:
  /// **'Sync in progress...'**
  String get syncInProgress;

  /// No description provided for @defaultLanguage.
  ///
  /// In en, this message translates to:
  /// **'Default Language'**
  String get defaultLanguage;

  /// No description provided for @aboutAiNotes.
  ///
  /// In en, this message translates to:
  /// **'About AI Notes'**
  String get aboutAiNotes;

  /// No description provided for @aiNotesAboutDescription.
  ///
  /// In en, this message translates to:
  /// **'AI Notes uses advanced machine learning to generate comprehensive summaries from your lectures, textbooks, and other learning materials. It helps you study smarter, not harder.'**
  String get aiNotesAboutDescription;

  /// No description provided for @gotIt.
  ///
  /// In en, this message translates to:
  /// **'Got It'**
  String get gotIt;

  /// No description provided for @noNotesFoundSearch.
  ///
  /// In en, this message translates to:
  /// **'No Notes Found'**
  String get noNotesFoundSearch;

  /// No description provided for @tryDifferentSearch.
  ///
  /// In en, this message translates to:
  /// **'Try a different search term or filter'**
  String get tryDifferentSearch;

  /// No description provided for @noFavoriteNotes.
  ///
  /// In en, this message translates to:
  /// **'No Favorite Notes'**
  String get noFavoriteNotes;

  /// No description provided for @favoriteNotesWillAppear.
  ///
  /// In en, this message translates to:
  /// **'Notes you favorite will appear here'**
  String get favoriteNotesWillAppear;

  /// No description provided for @noNotesYet.
  ///
  /// In en, this message translates to:
  /// **'No Notes Yet'**
  String get noNotesYet;

  /// No description provided for @generateFirstNote.
  ///
  /// In en, this message translates to:
  /// **'Generate your first AI note to get started!'**
  String get generateFirstNote;

  /// No description provided for @profileSettings.
  ///
  /// In en, this message translates to:
  /// **'My Profile & Settings'**
  String get profileSettings;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @editProfileDesc.
  ///
  /// In en, this message translates to:
  /// **'Update your personal information'**
  String get editProfileDesc;

  /// No description provided for @personalInformation.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personalInformation;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @dateOfBirth.
  ///
  /// In en, this message translates to:
  /// **'Date of Birth'**
  String get dateOfBirth;

  /// No description provided for @bio.
  ///
  /// In en, this message translates to:
  /// **'Bio'**
  String get bio;

  /// No description provided for @coursesEnrolled.
  ///
  /// In en, this message translates to:
  /// **'Courses'**
  String get coursesEnrolled;

  /// No description provided for @assignmentsCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get assignmentsCompleted;

  /// No description provided for @change.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get change;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get currentPassword;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @changePasswordDesc.
  ///
  /// In en, this message translates to:
  /// **'Update your account password'**
  String get changePasswordDesc;

  /// No description provided for @passwordChangedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password changed successfully'**
  String get passwordChangedSuccess;

  /// No description provided for @preferencesNotifications.
  ///
  /// In en, this message translates to:
  /// **'Preferences & Notifications'**
  String get preferencesNotifications;

  /// No description provided for @pushNotifications.
  ///
  /// In en, this message translates to:
  /// **'Push Notifications'**
  String get pushNotifications;

  /// No description provided for @pushNotificationsDesc.
  ///
  /// In en, this message translates to:
  /// **'Receive push notifications'**
  String get pushNotificationsDesc;

  /// No description provided for @emailAlerts.
  ///
  /// In en, this message translates to:
  /// **'Email Alerts'**
  String get emailAlerts;

  /// No description provided for @emailAlertsDesc.
  ///
  /// In en, this message translates to:
  /// **'Get important updates via email'**
  String get emailAlertsDesc;

  /// No description provided for @aiSuggestions.
  ///
  /// In en, this message translates to:
  /// **'AI Suggestions'**
  String get aiSuggestions;

  /// No description provided for @aiSuggestionsDesc.
  ///
  /// In en, this message translates to:
  /// **'Receive AI-powered study tips'**
  String get aiSuggestionsDesc;

  /// No description provided for @autoDarkMode.
  ///
  /// In en, this message translates to:
  /// **'Auto Dark Mode'**
  String get autoDarkMode;

  /// No description provided for @autoDarkModeDesc.
  ///
  /// In en, this message translates to:
  /// **'Switch theme based on system settings'**
  String get autoDarkModeDesc;

  /// No description provided for @weeklyPerformanceSummary.
  ///
  /// In en, this message translates to:
  /// **'Weekly Performance Summary'**
  String get weeklyPerformanceSummary;

  /// No description provided for @weeklyPerformanceSummaryDesc.
  ///
  /// In en, this message translates to:
  /// **'Get weekly progress reports'**
  String get weeklyPerformanceSummaryDesc;

  /// No description provided for @appearanceTheme.
  ///
  /// In en, this message translates to:
  /// **'Appearance & Theme'**
  String get appearanceTheme;

  /// No description provided for @themeMode.
  ///
  /// In en, this message translates to:
  /// **'Theme Mode'**
  String get themeMode;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @primaryColorAccent.
  ///
  /// In en, this message translates to:
  /// **'Primary Color Accent'**
  String get primaryColorAccent;

  /// No description provided for @securityAccount.
  ///
  /// In en, this message translates to:
  /// **'Security & Account'**
  String get securityAccount;

  /// No description provided for @twoFactorAuth.
  ///
  /// In en, this message translates to:
  /// **'Two-Factor Authentication'**
  String get twoFactorAuth;

  /// No description provided for @twoFactorAuthDesc.
  ///
  /// In en, this message translates to:
  /// **'Add extra security to your account'**
  String get twoFactorAuthDesc;

  /// No description provided for @deviceManagement.
  ///
  /// In en, this message translates to:
  /// **'Device Management'**
  String get deviceManagement;

  /// No description provided for @manage.
  ///
  /// In en, this message translates to:
  /// **'Manage'**
  String get manage;

  /// No description provided for @connectedDevicesCount.
  ///
  /// In en, this message translates to:
  /// **'{count} devices connected'**
  String connectedDevicesCount(int count);

  /// No description provided for @connectedDevices.
  ///
  /// In en, this message translates to:
  /// **'Connected Devices'**
  String get connectedDevices;

  /// No description provided for @currentDevice.
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get currentDevice;

  /// No description provided for @activeNow.
  ///
  /// In en, this message translates to:
  /// **'Active now'**
  String get activeNow;

  /// No description provided for @minutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{count}m ago'**
  String minutesAgo(int count);

  /// No description provided for @hoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{count}h ago'**
  String hoursAgo(int count);

  /// No description provided for @removeDevice.
  ///
  /// In en, this message translates to:
  /// **'Remove Device'**
  String get removeDevice;

  /// No description provided for @downloadMyData.
  ///
  /// In en, this message translates to:
  /// **'Download My Data'**
  String get downloadMyData;

  /// No description provided for @downloadMyDataDesc.
  ///
  /// In en, this message translates to:
  /// **'Export a copy of your data'**
  String get downloadMyDataDesc;

  /// No description provided for @downloadDataConfirmation.
  ///
  /// In en, this message translates to:
  /// **'We\'ll prepare a download of all your personal data. This may take a few minutes.'**
  String get downloadDataConfirmation;

  /// No description provided for @dataExportStarted.
  ///
  /// In en, this message translates to:
  /// **'Data export started. You\'ll be notified when ready.'**
  String get dataExportStarted;

  /// No description provided for @download.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get download;

  /// No description provided for @deleteMyAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete My Account'**
  String get deleteMyAccount;

  /// No description provided for @deleteMyAccountDesc.
  ///
  /// In en, this message translates to:
  /// **'Permanently delete your account'**
  String get deleteMyAccountDesc;

  /// No description provided for @deleteAccountWarning.
  ///
  /// In en, this message translates to:
  /// **'This action is permanent. All your data, courses, and progress will be deleted forever.'**
  String get deleteAccountWarning;

  /// No description provided for @typeDeleteToConfirm.
  ///
  /// In en, this message translates to:
  /// **'Type DELETE to confirm'**
  String get typeDeleteToConfirm;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @faq.
  ///
  /// In en, this message translates to:
  /// **'FAQ'**
  String get faq;

  /// No description provided for @faqDesc.
  ///
  /// In en, this message translates to:
  /// **'Frequently asked questions'**
  String get faqDesc;

  /// No description provided for @contactSupport.
  ///
  /// In en, this message translates to:
  /// **'Contact Support'**
  String get contactSupport;

  /// No description provided for @reportBug.
  ///
  /// In en, this message translates to:
  /// **'Report a Bug'**
  String get reportBug;

  /// No description provided for @reportBugDesc.
  ///
  /// In en, this message translates to:
  /// **'Help us improve by reporting issues'**
  String get reportBugDesc;

  /// No description provided for @sendFeedback.
  ///
  /// In en, this message translates to:
  /// **'Send Feedback'**
  String get sendFeedback;

  /// No description provided for @sendFeedbackDesc.
  ///
  /// In en, this message translates to:
  /// **'Share your thoughts with us'**
  String get sendFeedbackDesc;

  /// No description provided for @documentation.
  ///
  /// In en, this message translates to:
  /// **'Documentation'**
  String get documentation;

  /// No description provided for @documentationDesc.
  ///
  /// In en, this message translates to:
  /// **'Learn how to use EduVerse'**
  String get documentationDesc;

  /// No description provided for @dataCollection.
  ///
  /// In en, this message translates to:
  /// **'Data Collection'**
  String get dataCollection;

  /// No description provided for @dataCollectionDesc.
  ///
  /// In en, this message translates to:
  /// **'Allow us to collect usage data'**
  String get dataCollectionDesc;

  /// No description provided for @dataUsage.
  ///
  /// In en, this message translates to:
  /// **'Data Usage'**
  String get dataUsage;

  /// No description provided for @dataUsageDesc.
  ///
  /// In en, this message translates to:
  /// **'Your data helps us personalize your learning experience, improve our AI recommendations, and provide better educational content.'**
  String get dataUsageDesc;

  /// No description provided for @dataSecurity.
  ///
  /// In en, this message translates to:
  /// **'Data Security'**
  String get dataSecurity;

  /// No description provided for @dataSecurityDesc.
  ///
  /// In en, this message translates to:
  /// **'We implement industry-standard security measures to protect your personal information from unauthorized access.'**
  String get dataSecurityDesc;

  /// No description provided for @thirdPartyServices.
  ///
  /// In en, this message translates to:
  /// **'Third-Party Services'**
  String get thirdPartyServices;

  /// No description provided for @thirdPartyServicesDesc.
  ///
  /// In en, this message translates to:
  /// **'We may share data with trusted partners to enhance our services, always in compliance with privacy regulations.'**
  String get thirdPartyServicesDesc;

  /// No description provided for @yourRights.
  ///
  /// In en, this message translates to:
  /// **'Your Rights'**
  String get yourRights;

  /// No description provided for @yourRightsDesc.
  ///
  /// In en, this message translates to:
  /// **'You have the right to access, correct, or delete your personal data at any time through your account settings.'**
  String get yourRightsDesc;

  /// No description provided for @academicInformation.
  ///
  /// In en, this message translates to:
  /// **'Academic Information'**
  String get academicInformation;

  /// No description provided for @university.
  ///
  /// In en, this message translates to:
  /// **'University'**
  String get university;

  /// No description provided for @studentId.
  ///
  /// In en, this message translates to:
  /// **'Student ID'**
  String get studentId;

  /// No description provided for @major.
  ///
  /// In en, this message translates to:
  /// **'Major'**
  String get major;

  /// No description provided for @minor.
  ///
  /// In en, this message translates to:
  /// **'Minor'**
  String get minor;

  /// No description provided for @year.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get year;

  /// No description provided for @expectedGraduation.
  ///
  /// In en, this message translates to:
  /// **'Expected Graduation'**
  String get expectedGraduation;

  /// No description provided for @socialProfessionalLinks.
  ///
  /// In en, this message translates to:
  /// **'Social & Professional Links'**
  String get socialProfessionalLinks;

  /// No description provided for @personalWebsite.
  ///
  /// In en, this message translates to:
  /// **'Personal Website'**
  String get personalWebsite;

  /// No description provided for @changeCover.
  ///
  /// In en, this message translates to:
  /// **'Change Cover'**
  String get changeCover;

  /// No description provided for @changePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change Photo'**
  String get changePhoto;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @discardChanges.
  ///
  /// In en, this message translates to:
  /// **'Discard Changes?'**
  String get discardChanges;

  /// No description provided for @discardChangesMessage.
  ///
  /// In en, this message translates to:
  /// **'You have unsaved changes. Are you sure you want to discard them?'**
  String get discardChangesMessage;

  /// No description provided for @keepEditing.
  ///
  /// In en, this message translates to:
  /// **'Keep Editing'**
  String get keepEditing;

  /// No description provided for @discard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get discard;

  /// No description provided for @profileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully'**
  String get profileUpdated;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @emailPreferences.
  ///
  /// In en, this message translates to:
  /// **'Email Preferences'**
  String get emailPreferences;

  /// No description provided for @emailPreferencesDesc.
  ///
  /// In en, this message translates to:
  /// **'Manage email communication'**
  String get emailPreferencesDesc;

  /// No description provided for @notSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get notSet;

  /// No description provided for @phoneUpdated.
  ///
  /// In en, this message translates to:
  /// **'Phone number updated'**
  String get phoneUpdated;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @currentLanguage.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get currentLanguage;

  /// No description provided for @fontSize.
  ///
  /// In en, this message translates to:
  /// **'Font Size'**
  String get fontSize;

  /// No description provided for @small.
  ///
  /// In en, this message translates to:
  /// **'Small'**
  String get small;

  /// No description provided for @large.
  ///
  /// In en, this message translates to:
  /// **'Large'**
  String get large;

  /// No description provided for @privacySecurity.
  ///
  /// In en, this message translates to:
  /// **'Privacy & Security'**
  String get privacySecurity;

  /// No description provided for @enabled.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get enabled;

  /// No description provided for @disabled.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get disabled;

  /// No description provided for @devicesConnected.
  ///
  /// In en, this message translates to:
  /// **'{count} devices'**
  String devicesConnected(int count);

  /// No description provided for @privacySettings.
  ///
  /// In en, this message translates to:
  /// **'Privacy Settings'**
  String get privacySettings;

  /// No description provided for @privacySettingsDesc.
  ///
  /// In en, this message translates to:
  /// **'Control your privacy preferences'**
  String get privacySettingsDesc;

  /// No description provided for @loginHistory.
  ///
  /// In en, this message translates to:
  /// **'Login History'**
  String get loginHistory;

  /// No description provided for @loginHistoryDesc.
  ///
  /// In en, this message translates to:
  /// **'View recent login activity'**
  String get loginHistoryDesc;

  /// No description provided for @learning.
  ///
  /// In en, this message translates to:
  /// **'Learning'**
  String get learning;

  /// No description provided for @aiSettings.
  ///
  /// In en, this message translates to:
  /// **'AI Settings'**
  String get aiSettings;

  /// No description provided for @aiSettingsDesc.
  ///
  /// In en, this message translates to:
  /// **'Configure AI features'**
  String get aiSettingsDesc;

  /// No description provided for @downloadSettings.
  ///
  /// In en, this message translates to:
  /// **'Download Settings'**
  String get downloadSettings;

  /// No description provided for @downloadSettingsDesc.
  ///
  /// In en, this message translates to:
  /// **'Manage offline content'**
  String get downloadSettingsDesc;

  /// No description provided for @swipeActionsDesc.
  ///
  /// In en, this message translates to:
  /// **'Customize swipe gestures'**
  String get swipeActionsDesc;

  /// No description provided for @storageData.
  ///
  /// In en, this message translates to:
  /// **'Storage & Data'**
  String get storageData;

  /// No description provided for @clearCache.
  ///
  /// In en, this message translates to:
  /// **'Clear Cache'**
  String get clearCache;

  /// No description provided for @clearCacheDesc.
  ///
  /// In en, this message translates to:
  /// **'Free up storage space'**
  String get clearCacheDesc;

  /// No description provided for @clearCacheConfirmation.
  ///
  /// In en, this message translates to:
  /// **'This will clear temporary files and cached data. Your personal data will not be affected.'**
  String get clearCacheConfirmation;

  /// No description provided for @cacheCleared.
  ///
  /// In en, this message translates to:
  /// **'Cache cleared successfully'**
  String get cacheCleared;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @downloadMyDataSettingsDesc.
  ///
  /// In en, this message translates to:
  /// **'Export your personal data'**
  String get downloadMyDataSettingsDesc;

  /// No description provided for @backup.
  ///
  /// In en, this message translates to:
  /// **'Backup'**
  String get backup;

  /// No description provided for @backupDesc.
  ///
  /// In en, this message translates to:
  /// **'Backup your data to cloud'**
  String get backupDesc;

  /// No description provided for @support.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get support;

  /// No description provided for @helpCenterDesc.
  ///
  /// In en, this message translates to:
  /// **'Get help and support'**
  String get helpCenterDesc;

  /// No description provided for @sendFeedbackSettingsDesc.
  ///
  /// In en, this message translates to:
  /// **'Share your experience'**
  String get sendFeedbackSettingsDesc;

  /// No description provided for @reportBugSettingsDesc.
  ///
  /// In en, this message translates to:
  /// **'Report issues you found'**
  String get reportBugSettingsDesc;

  /// No description provided for @rateApp.
  ///
  /// In en, this message translates to:
  /// **'Rate App'**
  String get rateApp;

  /// No description provided for @rateAppDesc.
  ///
  /// In en, this message translates to:
  /// **'Rate us on the app store'**
  String get rateAppDesc;

  /// No description provided for @licenses.
  ///
  /// In en, this message translates to:
  /// **'Open Source Licenses'**
  String get licenses;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'App Version'**
  String get appVersion;

  /// No description provided for @dangerZone.
  ///
  /// In en, this message translates to:
  /// **'Danger Zone'**
  String get dangerZone;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @signOutConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out?'**
  String get signOutConfirmation;

  /// No description provided for @searchSettings.
  ///
  /// In en, this message translates to:
  /// **'Search settings...'**
  String get searchSettings;

  /// No description provided for @noResultsFound.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noResultsFound;

  /// No description provided for @updatePassword.
  ///
  /// In en, this message translates to:
  /// **'Update Password'**
  String get updatePassword;

  /// No description provided for @feedbackPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Tell us what you think...'**
  String get feedbackPlaceholder;

  /// No description provided for @feedbackSent.
  ///
  /// In en, this message translates to:
  /// **'Thank you for your feedback!'**
  String get feedbackSent;

  /// No description provided for @bugTitle.
  ///
  /// In en, this message translates to:
  /// **'Bug Title'**
  String get bugTitle;

  /// No description provided for @bugDescription.
  ///
  /// In en, this message translates to:
  /// **'Bug Description'**
  String get bugDescription;

  /// No description provided for @bugReportSent.
  ///
  /// In en, this message translates to:
  /// **'Bug report submitted. Thank you!'**
  String get bugReportSent;

  /// No description provided for @rateAppMessage.
  ///
  /// In en, this message translates to:
  /// **'If you enjoy using EduVerse, would you mind taking a moment to rate us?'**
  String get rateAppMessage;

  /// No description provided for @notNow.
  ///
  /// In en, this message translates to:
  /// **'Not Now'**
  String get notNow;

  /// No description provided for @thankYouForRating.
  ///
  /// In en, this message translates to:
  /// **'Thank you for your rating!'**
  String get thankYouForRating;

  /// No description provided for @pushNotificationsSettingsDesc.
  ///
  /// In en, this message translates to:
  /// **'Configure push notifications'**
  String get pushNotificationsSettingsDesc;

  /// No description provided for @emailNotifications.
  ///
  /// In en, this message translates to:
  /// **'Email Notifications'**
  String get emailNotifications;

  /// No description provided for @emailNotificationsDesc.
  ///
  /// In en, this message translates to:
  /// **'Configure email notifications'**
  String get emailNotificationsDesc;

  /// No description provided for @doNotDisturb.
  ///
  /// In en, this message translates to:
  /// **'Do Not Disturb'**
  String get doNotDisturb;

  /// No description provided for @doNotDisturbDesc.
  ///
  /// In en, this message translates to:
  /// **'Schedule quiet hours'**
  String get doNotDisturbDesc;

  /// No description provided for @notificationTypes.
  ///
  /// In en, this message translates to:
  /// **'Notification Types'**
  String get notificationTypes;

  /// No description provided for @courseUpdates.
  ///
  /// In en, this message translates to:
  /// **'Course Updates'**
  String get courseUpdates;

  /// No description provided for @courseUpdatesDesc.
  ///
  /// In en, this message translates to:
  /// **'New content, lectures, and materials'**
  String get courseUpdatesDesc;

  /// No description provided for @assignmentReminders.
  ///
  /// In en, this message translates to:
  /// **'Assignment Reminders'**
  String get assignmentReminders;

  /// No description provided for @assignmentRemindersDesc.
  ///
  /// In en, this message translates to:
  /// **'Due dates and submission reminders'**
  String get assignmentRemindersDesc;

  /// No description provided for @gradeNotifications.
  ///
  /// In en, this message translates to:
  /// **'Grade Notifications'**
  String get gradeNotifications;

  /// No description provided for @gradeNotificationsDesc.
  ///
  /// In en, this message translates to:
  /// **'New grades and feedback'**
  String get gradeNotificationsDesc;

  /// No description provided for @chatMessages.
  ///
  /// In en, this message translates to:
  /// **'Chat Messages'**
  String get chatMessages;

  /// No description provided for @chatMessagesDesc.
  ///
  /// In en, this message translates to:
  /// **'Messages from instructors and peers'**
  String get chatMessagesDesc;

  /// No description provided for @announcements.
  ///
  /// In en, this message translates to:
  /// **'Announcements'**
  String get announcements;

  /// No description provided for @announcementsDesc.
  ///
  /// In en, this message translates to:
  /// **'Important announcements'**
  String get announcementsDesc;

  /// No description provided for @scheduleChanges.
  ///
  /// In en, this message translates to:
  /// **'Schedule Changes'**
  String get scheduleChanges;

  /// No description provided for @scheduleChangesDesc.
  ///
  /// In en, this message translates to:
  /// **'Class time and location changes'**
  String get scheduleChangesDesc;

  /// No description provided for @soundVibration.
  ///
  /// In en, this message translates to:
  /// **'Sound & Vibration'**
  String get soundVibration;

  /// No description provided for @notificationSound.
  ///
  /// In en, this message translates to:
  /// **'Notification Sound'**
  String get notificationSound;

  /// No description provided for @notificationSoundDesc.
  ///
  /// In en, this message translates to:
  /// **'Play sound for notifications'**
  String get notificationSoundDesc;

  /// No description provided for @vibration.
  ///
  /// In en, this message translates to:
  /// **'Vibration'**
  String get vibration;

  /// No description provided for @vibrationDesc.
  ///
  /// In en, this message translates to:
  /// **'Vibrate for notifications'**
  String get vibrationDesc;

  /// No description provided for @enableDoNotDisturb.
  ///
  /// In en, this message translates to:
  /// **'Enable Do Not Disturb'**
  String get enableDoNotDisturb;

  /// No description provided for @enableDoNotDisturbDesc.
  ///
  /// In en, this message translates to:
  /// **'Mute notifications during set hours'**
  String get enableDoNotDisturbDesc;

  /// No description provided for @startTime.
  ///
  /// In en, this message translates to:
  /// **'Start Time'**
  String get startTime;

  /// No description provided for @endTime.
  ///
  /// In en, this message translates to:
  /// **'End Time'**
  String get endTime;

  /// No description provided for @enableAll.
  ///
  /// In en, this message translates to:
  /// **'Enable All'**
  String get enableAll;

  /// No description provided for @disableAll.
  ///
  /// In en, this message translates to:
  /// **'Disable All'**
  String get disableAll;

  /// No description provided for @emailDigest.
  ///
  /// In en, this message translates to:
  /// **'Email Digest'**
  String get emailDigest;

  /// No description provided for @emailDigestDesc.
  ///
  /// In en, this message translates to:
  /// **'Receive a summary of notifications'**
  String get emailDigestDesc;

  /// No description provided for @frequency.
  ///
  /// In en, this message translates to:
  /// **'Frequency'**
  String get frequency;

  /// No description provided for @daily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get daily;

  /// No description provided for @weeklyProgress.
  ///
  /// In en, this message translates to:
  /// **'Weekly Progress'**
  String get weeklyProgress;

  /// No description provided for @weeklyProgressDesc.
  ///
  /// In en, this message translates to:
  /// **'Weekly learning progress reports'**
  String get weeklyProgressDesc;

  /// No description provided for @promotionalEmails.
  ///
  /// In en, this message translates to:
  /// **'Promotional Emails'**
  String get promotionalEmails;

  /// No description provided for @promotionalEmailsDesc.
  ///
  /// In en, this message translates to:
  /// **'Deals, offers, and new features'**
  String get promotionalEmailsDesc;

  /// No description provided for @unsubscribeAll.
  ///
  /// In en, this message translates to:
  /// **'Unsubscribe from All'**
  String get unsubscribeAll;

  /// No description provided for @unsubscribedAll.
  ///
  /// In en, this message translates to:
  /// **'Unsubscribed from all emails'**
  String get unsubscribedAll;

  /// No description provided for @unsubscribeAllConfirm.
  ///
  /// In en, this message translates to:
  /// **'You will stop receiving all email notifications. You can re-enable them anytime.'**
  String get unsubscribeAllConfirm;

  /// No description provided for @unsubscribe.
  ///
  /// In en, this message translates to:
  /// **'Unsubscribe'**
  String get unsubscribe;

  /// No description provided for @authenticationMethod.
  ///
  /// In en, this message translates to:
  /// **'Authentication Method'**
  String get authenticationMethod;

  /// No description provided for @authenticatorApp.
  ///
  /// In en, this message translates to:
  /// **'Authenticator App'**
  String get authenticatorApp;

  /// No description provided for @authenticatorAppDesc.
  ///
  /// In en, this message translates to:
  /// **'Use Google or Microsoft Authenticator'**
  String get authenticatorAppDesc;

  /// No description provided for @smsCode.
  ///
  /// In en, this message translates to:
  /// **'SMS Code'**
  String get smsCode;

  /// No description provided for @smsCodeDesc.
  ///
  /// In en, this message translates to:
  /// **'Receive codes via text message'**
  String get smsCodeDesc;

  /// No description provided for @emailCode.
  ///
  /// In en, this message translates to:
  /// **'Email Code'**
  String get emailCode;

  /// No description provided for @emailCodeDesc.
  ///
  /// In en, this message translates to:
  /// **'Receive codes via email'**
  String get emailCodeDesc;

  /// No description provided for @backupCodes.
  ///
  /// In en, this message translates to:
  /// **'Backup Codes'**
  String get backupCodes;

  /// No description provided for @viewBackupCodes.
  ///
  /// In en, this message translates to:
  /// **'View Backup Codes'**
  String get viewBackupCodes;

  /// No description provided for @codesRemaining.
  ///
  /// In en, this message translates to:
  /// **'codes remaining'**
  String get codesRemaining;

  /// No description provided for @codesCopied.
  ///
  /// In en, this message translates to:
  /// **'Codes copied to clipboard'**
  String get codesCopied;

  /// No description provided for @copyCodes.
  ///
  /// In en, this message translates to:
  /// **'Copy Codes'**
  String get copyCodes;

  /// No description provided for @setup2FA.
  ///
  /// In en, this message translates to:
  /// **'Set Up 2FA'**
  String get setup2FA;

  /// No description provided for @setup2FADesc.
  ///
  /// In en, this message translates to:
  /// **'Add an extra layer of security to protect your account from unauthorized access.'**
  String get setup2FADesc;

  /// No description provided for @enable2FA.
  ///
  /// In en, this message translates to:
  /// **'Enable Two-Factor Authentication'**
  String get enable2FA;

  /// No description provided for @why2FA.
  ///
  /// In en, this message translates to:
  /// **'Why use 2FA?'**
  String get why2FA;

  /// No description provided for @protectAccount.
  ///
  /// In en, this message translates to:
  /// **'Protect your account from unauthorized access'**
  String get protectAccount;

  /// No description provided for @preventUnauthorized.
  ///
  /// In en, this message translates to:
  /// **'Prevent others from logging in without your permission'**
  String get preventUnauthorized;

  /// No description provided for @verifyIdentity.
  ///
  /// In en, this message translates to:
  /// **'Verify your identity with something you have'**
  String get verifyIdentity;

  /// No description provided for @disable2FA.
  ///
  /// In en, this message translates to:
  /// **'Disable 2FA'**
  String get disable2FA;

  /// No description provided for @disable2FAWarning.
  ///
  /// In en, this message translates to:
  /// **'Disabling 2FA will make your account less secure. Are you sure?'**
  String get disable2FAWarning;

  /// No description provided for @disable.
  ///
  /// In en, this message translates to:
  /// **'Disable'**
  String get disable;

  /// No description provided for @twoFactorDisabled.
  ///
  /// In en, this message translates to:
  /// **'Two-factor authentication disabled'**
  String get twoFactorDisabled;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @inactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get inactive;

  /// No description provided for @otherDevices.
  ///
  /// In en, this message translates to:
  /// **'Other Devices'**
  String get otherDevices;

  /// No description provided for @thisDevice.
  ///
  /// In en, this message translates to:
  /// **'This Device'**
  String get thisDevice;

  /// No description provided for @signOutAllDevices.
  ///
  /// In en, this message translates to:
  /// **'Sign Out All Devices'**
  String get signOutAllDevices;

  /// No description provided for @deviceRemoved.
  ///
  /// In en, this message translates to:
  /// **'Device removed successfully'**
  String get deviceRemoved;

  /// No description provided for @allDevicesRemoved.
  ///
  /// In en, this message translates to:
  /// **'All other devices signed out'**
  String get allDevicesRemoved;

  /// No description provided for @removeDeviceWarning.
  ///
  /// In en, this message translates to:
  /// **'This device will be signed out immediately.'**
  String get removeDeviceWarning;

  /// No description provided for @signOutAllWarning.
  ///
  /// In en, this message translates to:
  /// **'This will sign out all other devices'**
  String get signOutAllWarning;

  /// No description provided for @devices.
  ///
  /// In en, this message translates to:
  /// **'devices'**
  String get devices;

  /// No description provided for @securityTip.
  ///
  /// In en, this message translates to:
  /// **'If you see a device you don\'t recognize, remove it and change your password immediately.'**
  String get securityTip;

  /// No description provided for @profilePrivacy.
  ///
  /// In en, this message translates to:
  /// **'Profile Privacy'**
  String get profilePrivacy;

  /// No description provided for @profileVisibility.
  ///
  /// In en, this message translates to:
  /// **'Profile Visibility'**
  String get profileVisibility;

  /// No description provided for @profileVisibilityDesc.
  ///
  /// In en, this message translates to:
  /// **'Who can see your profile'**
  String get profileVisibilityDesc;

  /// No description provided for @activityStatus.
  ///
  /// In en, this message translates to:
  /// **'Activity Status'**
  String get activityStatus;

  /// No description provided for @activityStatusDesc.
  ///
  /// In en, this message translates to:
  /// **'Who can see your activity'**
  String get activityStatusDesc;

  /// No description provided for @everyone.
  ///
  /// In en, this message translates to:
  /// **'Everyone'**
  String get everyone;

  /// No description provided for @friendsOnly.
  ///
  /// In en, this message translates to:
  /// **'Friends Only'**
  String get friendsOnly;

  /// No description provided for @onlyMe.
  ///
  /// In en, this message translates to:
  /// **'Only Me'**
  String get onlyMe;

  /// No description provided for @nobody.
  ///
  /// In en, this message translates to:
  /// **'Nobody'**
  String get nobody;

  /// No description provided for @onlineStatus.
  ///
  /// In en, this message translates to:
  /// **'Online Status'**
  String get onlineStatus;

  /// No description provided for @showOnlineStatus.
  ///
  /// In en, this message translates to:
  /// **'Show Online Status'**
  String get showOnlineStatus;

  /// No description provided for @showOnlineStatusDesc.
  ///
  /// In en, this message translates to:
  /// **'Let others see when you\'re online'**
  String get showOnlineStatusDesc;

  /// No description provided for @showLastSeen.
  ///
  /// In en, this message translates to:
  /// **'Show Last Seen'**
  String get showLastSeen;

  /// No description provided for @showLastSeenDesc.
  ///
  /// In en, this message translates to:
  /// **'Let others see when you were last active'**
  String get showLastSeenDesc;

  /// No description provided for @interactions.
  ///
  /// In en, this message translates to:
  /// **'Interactions'**
  String get interactions;

  /// No description provided for @allowTagging.
  ///
  /// In en, this message translates to:
  /// **'Allow Tagging'**
  String get allowTagging;

  /// No description provided for @allowTaggingDesc.
  ///
  /// In en, this message translates to:
  /// **'Let others tag you in posts'**
  String get allowTaggingDesc;

  /// No description provided for @allowMentions.
  ///
  /// In en, this message translates to:
  /// **'Allow Mentions'**
  String get allowMentions;

  /// No description provided for @allowMentionsDesc.
  ///
  /// In en, this message translates to:
  /// **'Let others mention you in comments'**
  String get allowMentionsDesc;

  /// No description provided for @dataAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Data & Analytics'**
  String get dataAnalytics;

  /// No description provided for @personalization.
  ///
  /// In en, this message translates to:
  /// **'Personalization'**
  String get personalization;

  /// No description provided for @personalizationDesc.
  ///
  /// In en, this message translates to:
  /// **'Allow personalized recommendations'**
  String get personalizationDesc;

  /// No description provided for @analytics.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get analytics;

  /// No description provided for @analyticsDesc.
  ///
  /// In en, this message translates to:
  /// **'Share analytics to improve our service'**
  String get analyticsDesc;

  /// No description provided for @blockedUsers.
  ///
  /// In en, this message translates to:
  /// **'Blocked Users'**
  String get blockedUsers;

  /// No description provided for @dataRequestSent.
  ///
  /// In en, this message translates to:
  /// **'Data request sent. You\'ll receive an email shortly.'**
  String get dataRequestSent;

  /// No description provided for @recentActivity.
  ///
  /// In en, this message translates to:
  /// **'Recent Activity'**
  String get recentActivity;

  /// No description provided for @loginActivity.
  ///
  /// In en, this message translates to:
  /// **'Login Activity'**
  String get loginActivity;

  /// No description provided for @last30Days.
  ///
  /// In en, this message translates to:
  /// **'Last 30 days'**
  String get last30Days;

  /// No description provided for @successful.
  ///
  /// In en, this message translates to:
  /// **'Successful'**
  String get successful;

  /// No description provided for @failed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get failed;

  /// No description provided for @blocked.
  ///
  /// In en, this message translates to:
  /// **'Blocked'**
  String get blocked;

  /// No description provided for @coreFeatures.
  ///
  /// In en, this message translates to:
  /// **'Core Features'**
  String get coreFeatures;

  /// No description provided for @aiAssistantDesc.
  ///
  /// In en, this message translates to:
  /// **'Enable AI-powered learning assistant'**
  String get aiAssistantDesc;

  /// No description provided for @smartSuggestions.
  ///
  /// In en, this message translates to:
  /// **'Smart Suggestions'**
  String get smartSuggestions;

  /// No description provided for @smartSuggestionsDesc.
  ///
  /// In en, this message translates to:
  /// **'Get AI suggestions while studying'**
  String get smartSuggestionsDesc;

  /// No description provided for @autoComplete.
  ///
  /// In en, this message translates to:
  /// **'Auto Complete'**
  String get autoComplete;

  /// No description provided for @autoCompleteDesc.
  ///
  /// In en, this message translates to:
  /// **'AI-powered text completion'**
  String get autoCompleteDesc;

  /// No description provided for @contextualHelp.
  ///
  /// In en, this message translates to:
  /// **'Contextual Help'**
  String get contextualHelp;

  /// No description provided for @contextualHelpDesc.
  ///
  /// In en, this message translates to:
  /// **'Show helpful tips based on context'**
  String get contextualHelpDesc;

  /// No description provided for @learningAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Learning & Analytics'**
  String get learningAnalytics;

  /// No description provided for @learningAnalyticsFeature.
  ///
  /// In en, this message translates to:
  /// **'Learning Analytics'**
  String get learningAnalyticsFeature;

  /// No description provided for @learningAnalyticsDesc.
  ///
  /// In en, this message translates to:
  /// **'Track your learning patterns with AI'**
  String get learningAnalyticsDesc;

  /// No description provided for @voiceInteraction.
  ///
  /// In en, this message translates to:
  /// **'Voice Interaction'**
  String get voiceInteraction;

  /// No description provided for @voiceInteractionDesc.
  ///
  /// In en, this message translates to:
  /// **'Talk to AI using your voice'**
  String get voiceInteractionDesc;

  /// No description provided for @responseSettings.
  ///
  /// In en, this message translates to:
  /// **'Response Settings'**
  String get responseSettings;

  /// No description provided for @responseLength.
  ///
  /// In en, this message translates to:
  /// **'Response Length'**
  String get responseLength;

  /// No description provided for @concise.
  ///
  /// In en, this message translates to:
  /// **'Concise'**
  String get concise;

  /// No description provided for @balanced.
  ///
  /// In en, this message translates to:
  /// **'Balanced'**
  String get balanced;

  /// No description provided for @detailed.
  ///
  /// In en, this message translates to:
  /// **'Detailed'**
  String get detailed;

  /// No description provided for @aiPersonality.
  ///
  /// In en, this message translates to:
  /// **'AI Personality'**
  String get aiPersonality;

  /// No description provided for @professional.
  ///
  /// In en, this message translates to:
  /// **'Professional'**
  String get professional;

  /// No description provided for @friendly.
  ///
  /// In en, this message translates to:
  /// **'Friendly'**
  String get friendly;

  /// No description provided for @academic.
  ///
  /// In en, this message translates to:
  /// **'Academic'**
  String get academic;

  /// No description provided for @responseSpeed.
  ///
  /// In en, this message translates to:
  /// **'Response Speed'**
  String get responseSpeed;

  /// No description provided for @responseSpeedDesc.
  ///
  /// In en, this message translates to:
  /// **'Balance between speed and accuracy'**
  String get responseSpeedDesc;

  /// No description provided for @fast.
  ///
  /// In en, this message translates to:
  /// **'Fast'**
  String get fast;

  /// No description provided for @accurate.
  ///
  /// In en, this message translates to:
  /// **'Accurate'**
  String get accurate;

  /// No description provided for @usageStats.
  ///
  /// In en, this message translates to:
  /// **'Usage Statistics'**
  String get usageStats;

  /// No description provided for @timeSaved.
  ///
  /// In en, this message translates to:
  /// **'Time Saved'**
  String get timeSaved;

  /// No description provided for @accuracy.
  ///
  /// In en, this message translates to:
  /// **'Accuracy'**
  String get accuracy;

  /// No description provided for @storageBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Storage Breakdown'**
  String get storageBreakdown;

  /// No description provided for @cache.
  ///
  /// In en, this message translates to:
  /// **'Cache'**
  String get cache;

  /// No description provided for @autoDownload.
  ///
  /// In en, this message translates to:
  /// **'Auto Download'**
  String get autoDownload;

  /// No description provided for @autoDownloadDesc.
  ///
  /// In en, this message translates to:
  /// **'Automatically download course materials'**
  String get autoDownloadDesc;

  /// No description provided for @downloadOnWifi.
  ///
  /// In en, this message translates to:
  /// **'Download on Wi-Fi Only'**
  String get downloadOnWifi;

  /// No description provided for @downloadOnWifiDesc.
  ///
  /// In en, this message translates to:
  /// **'Only download when connected to Wi-Fi'**
  String get downloadOnWifiDesc;

  /// No description provided for @downloadQuality.
  ///
  /// In en, this message translates to:
  /// **'Download Quality'**
  String get downloadQuality;

  /// No description provided for @backupSettings.
  ///
  /// In en, this message translates to:
  /// **'Backup Settings'**
  String get backupSettings;

  /// No description provided for @autoBackup.
  ///
  /// In en, this message translates to:
  /// **'Auto Backup'**
  String get autoBackup;

  /// No description provided for @autoBackupDesc.
  ///
  /// In en, this message translates to:
  /// **'Automatically backup your data'**
  String get autoBackupDesc;

  /// No description provided for @backupFrequency.
  ///
  /// In en, this message translates to:
  /// **'Backup Frequency'**
  String get backupFrequency;

  /// No description provided for @backupNow.
  ///
  /// In en, this message translates to:
  /// **'Backup Now'**
  String get backupNow;

  /// No description provided for @lastBackup.
  ///
  /// In en, this message translates to:
  /// **'Last backup: Today'**
  String get lastBackup;

  /// No description provided for @backupStarted.
  ///
  /// In en, this message translates to:
  /// **'Backup started'**
  String get backupStarted;

  /// No description provided for @storageUsed.
  ///
  /// In en, this message translates to:
  /// **'Storage Used'**
  String get storageUsed;

  /// No description provided for @free.
  ///
  /// In en, this message translates to:
  /// **'free'**
  String get free;

  /// No description provided for @clearDownloads.
  ///
  /// In en, this message translates to:
  /// **'Clear Downloads'**
  String get clearDownloads;

  /// No description provided for @clearDownloadsConfirm.
  ///
  /// In en, this message translates to:
  /// **'This will delete all downloaded course materials. You can re-download them anytime.'**
  String get clearDownloadsConfirm;

  /// No description provided for @downloadsCleared.
  ///
  /// In en, this message translates to:
  /// **'Downloads cleared successfully'**
  String get downloadsCleared;

  /// No description provided for @clearCacheConfirm.
  ///
  /// In en, this message translates to:
  /// **'This will clear temporary files and cached data.'**
  String get clearCacheConfirm;

  /// No description provided for @quickHelp.
  ///
  /// In en, this message translates to:
  /// **'Quick Help'**
  String get quickHelp;

  /// No description provided for @frequentlyAsked.
  ///
  /// In en, this message translates to:
  /// **'Frequently Asked Questions'**
  String get frequentlyAsked;

  /// No description provided for @howCanWeHelp.
  ///
  /// In en, this message translates to:
  /// **'How can we help?'**
  String get howCanWeHelp;

  /// No description provided for @searchHelpDesc.
  ///
  /// In en, this message translates to:
  /// **'Search for answers to your questions'**
  String get searchHelpDesc;

  /// No description provided for @searchHelp.
  ///
  /// In en, this message translates to:
  /// **'Search for help...'**
  String get searchHelp;

  /// No description provided for @gettingStarted.
  ///
  /// In en, this message translates to:
  /// **'Getting Started'**
  String get gettingStarted;

  /// No description provided for @accountHelp.
  ///
  /// In en, this message translates to:
  /// **'Account Help'**
  String get accountHelp;

  /// No description provided for @coursesHelp.
  ///
  /// In en, this message translates to:
  /// **'Courses Help'**
  String get coursesHelp;

  /// No description provided for @billingHelp.
  ///
  /// In en, this message translates to:
  /// **'Billing Help'**
  String get billingHelp;

  /// No description provided for @stillNeedHelp.
  ///
  /// In en, this message translates to:
  /// **'Still Need Help?'**
  String get stillNeedHelp;

  /// No description provided for @contactSupportDesc.
  ///
  /// In en, this message translates to:
  /// **'Our support team is here to help'**
  String get contactSupportDesc;

  /// No description provided for @liveChat.
  ///
  /// In en, this message translates to:
  /// **'Live Chat'**
  String get liveChat;

  /// No description provided for @emailUs.
  ///
  /// In en, this message translates to:
  /// **'Email Us'**
  String get emailUs;

  /// No description provided for @faqQuestion1.
  ///
  /// In en, this message translates to:
  /// **'How do I reset my password?'**
  String get faqQuestion1;

  /// No description provided for @faqAnswer1.
  ///
  /// In en, this message translates to:
  /// **'Go to Settings > Security > Change Password or use the \'Forgot Password\' link on the login page.'**
  String get faqAnswer1;

  /// No description provided for @faqQuestion2.
  ///
  /// In en, this message translates to:
  /// **'How do I enable two-factor authentication?'**
  String get faqQuestion2;

  /// No description provided for @faqAnswer2.
  ///
  /// In en, this message translates to:
  /// **'Navigate to Settings > Privacy & Security > Two-Factor Authentication and follow the setup wizard.'**
  String get faqAnswer2;

  /// No description provided for @faqQuestion3.
  ///
  /// In en, this message translates to:
  /// **'Can I download courses for offline viewing?'**
  String get faqQuestion3;

  /// No description provided for @faqAnswer3.
  ///
  /// In en, this message translates to:
  /// **'Yes! Look for the download icon on any course page. Downloaded content will be available offline.'**
  String get faqAnswer3;

  /// No description provided for @faqQuestion4.
  ///
  /// In en, this message translates to:
  /// **'How do I contact my instructor?'**
  String get faqQuestion4;

  /// No description provided for @faqAnswer4.
  ///
  /// In en, this message translates to:
  /// **'Use the Messages tab in your course page or the Chat feature to reach out to instructors.'**
  String get faqAnswer4;

  /// No description provided for @faqQuestion5.
  ///
  /// In en, this message translates to:
  /// **'Why am I not receiving notifications?'**
  String get faqQuestion5;

  /// No description provided for @faqAnswer5.
  ///
  /// In en, this message translates to:
  /// **'Check Settings > Notifications to ensure notifications are enabled. Also verify your device settings allow app notifications.'**
  String get faqAnswer5;

  /// No description provided for @legal.
  ///
  /// In en, this message translates to:
  /// **'Legal'**
  String get legal;

  /// No description provided for @team.
  ///
  /// In en, this message translates to:
  /// **'Team'**
  String get team;

  /// No description provided for @allRightsReserved.
  ///
  /// In en, this message translates to:
  /// **'All rights reserved'**
  String get allRightsReserved;

  /// No description provided for @appDescription.
  ///
  /// In en, this message translates to:
  /// **'Your all-in-one learning platform powered by AI. Learn smarter, achieve more.'**
  String get appDescription;

  /// No description provided for @followUs.
  ///
  /// In en, this message translates to:
  /// **'Follow Us'**
  String get followUs;

  /// No description provided for @showingResultsFor.
  ///
  /// In en, this message translates to:
  /// **'Showing results for:'**
  String get showingResultsFor;

  /// No description provided for @clearSearch.
  ///
  /// In en, this message translates to:
  /// **'Clear Search'**
  String get clearSearch;

  /// No description provided for @emailCopied.
  ///
  /// In en, this message translates to:
  /// **'Email copied'**
  String get emailCopied;

  /// No description provided for @supportGreeting.
  ///
  /// In en, this message translates to:
  /// **'Hi! I\'m your support assistant. How can I help you today?'**
  String get supportGreeting;

  /// No description provided for @supportAutoReply.
  ///
  /// In en, this message translates to:
  /// **'Thank you for your message. A support agent will respond shortly. In the meantime, check our FAQ section for quick answers.'**
  String get supportAutoReply;

  /// No description provided for @liveSupport.
  ///
  /// In en, this message translates to:
  /// **'Live Support'**
  String get liveSupport;

  /// No description provided for @connectingToSupport.
  ///
  /// In en, this message translates to:
  /// **'Connecting to support...'**
  String get connectingToSupport;

  /// No description provided for @pleaseWait.
  ///
  /// In en, this message translates to:
  /// **'Please wait'**
  String get pleaseWait;

  /// No description provided for @typeMessage.
  ///
  /// In en, this message translates to:
  /// **'Type a message...'**
  String get typeMessage;

  /// No description provided for @accessibility.
  ///
  /// In en, this message translates to:
  /// **'Accessibility'**
  String get accessibility;

  /// No description provided for @reduceMotion.
  ///
  /// In en, this message translates to:
  /// **'Reduce Motion'**
  String get reduceMotion;

  /// No description provided for @reduceMotionDesc.
  ///
  /// In en, this message translates to:
  /// **'Reduces animations throughout the app'**
  String get reduceMotionDesc;

  /// No description provided for @highContrast.
  ///
  /// In en, this message translates to:
  /// **'High Contrast'**
  String get highContrast;

  /// No description provided for @highContrastDesc.
  ///
  /// In en, this message translates to:
  /// **'Increases contrast for better visibility'**
  String get highContrastDesc;

  /// No description provided for @system.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get system;

  /// No description provided for @noBlockedUsers.
  ///
  /// In en, this message translates to:
  /// **'No Blocked Users'**
  String get noBlockedUsers;

  /// No description provided for @noBlockedUsersDesc.
  ///
  /// In en, this message translates to:
  /// **'Users you block will appear here'**
  String get noBlockedUsersDesc;

  /// No description provided for @blockedUsersInfo.
  ///
  /// In en, this message translates to:
  /// **'Blocked users cannot message you or see your profile'**
  String get blockedUsersInfo;

  /// No description provided for @unblock.
  ///
  /// In en, this message translates to:
  /// **'Unblock'**
  String get unblock;

  /// No description provided for @userUnblocked.
  ///
  /// In en, this message translates to:
  /// **'{name} has been unblocked'**
  String userUnblocked(String name);

  /// No description provided for @unblockUser.
  ///
  /// In en, this message translates to:
  /// **'Unblock User'**
  String get unblockUser;

  /// No description provided for @unblockUserConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to unblock {name}?'**
  String unblockUserConfirm(String name);

  /// No description provided for @chatSwipeSettings.
  ///
  /// In en, this message translates to:
  /// **'Chat Swipe Settings'**
  String get chatSwipeSettings;

  /// No description provided for @general.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get general;

  /// No description provided for @enableSwipe.
  ///
  /// In en, this message translates to:
  /// **'Enable Swipe Actions'**
  String get enableSwipe;

  /// No description provided for @enableSwipeDesc.
  ///
  /// In en, this message translates to:
  /// **'Allow swiping on items for quick actions'**
  String get enableSwipeDesc;

  /// No description provided for @confirmDelete.
  ///
  /// In en, this message translates to:
  /// **'Confirm Delete'**
  String get confirmDelete;

  /// No description provided for @confirmDeleteDesc.
  ///
  /// In en, this message translates to:
  /// **'Show confirmation before deleting'**
  String get confirmDeleteDesc;

  /// No description provided for @swipeDirections.
  ///
  /// In en, this message translates to:
  /// **'Swipe Directions'**
  String get swipeDirections;

  /// No description provided for @swipeLeft.
  ///
  /// In en, this message translates to:
  /// **'Swipe Left'**
  String get swipeLeft;

  /// No description provided for @swipeRight.
  ///
  /// In en, this message translates to:
  /// **'Swipe Right'**
  String get swipeRight;

  /// No description provided for @sampleChat.
  ///
  /// In en, this message translates to:
  /// **'Sample Chat'**
  String get sampleChat;

  /// No description provided for @swipeToSeeActions.
  ///
  /// In en, this message translates to:
  /// **'Swipe to see actions'**
  String get swipeToSeeActions;

  /// No description provided for @pin.
  ///
  /// In en, this message translates to:
  /// **'Pin'**
  String get pin;

  /// No description provided for @mute.
  ///
  /// In en, this message translates to:
  /// **'Mute'**
  String get mute;

  /// No description provided for @schedule.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get schedule;

  /// No description provided for @repeatDays.
  ///
  /// In en, this message translates to:
  /// **'Repeat Days'**
  String get repeatDays;

  /// No description provided for @exceptions.
  ///
  /// In en, this message translates to:
  /// **'Exceptions'**
  String get exceptions;

  /// No description provided for @allowCalls.
  ///
  /// In en, this message translates to:
  /// **'Allow Calls'**
  String get allowCalls;

  /// No description provided for @allowCallsDesc.
  ///
  /// In en, this message translates to:
  /// **'Allow calls from contacts'**
  String get allowCallsDesc;

  /// No description provided for @allowImportant.
  ///
  /// In en, this message translates to:
  /// **'Allow Important'**
  String get allowImportant;

  /// No description provided for @allowImportantDesc.
  ///
  /// In en, this message translates to:
  /// **'Allow important notifications'**
  String get allowImportantDesc;

  /// No description provided for @dndEnabled.
  ///
  /// In en, this message translates to:
  /// **'DND Enabled'**
  String get dndEnabled;

  /// No description provided for @dndDisabled.
  ///
  /// In en, this message translates to:
  /// **'DND Disabled'**
  String get dndDisabled;

  /// No description provided for @monday.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get monday;

  /// No description provided for @tuesday.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get tuesday;

  /// No description provided for @wednesday.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get wednesday;

  /// No description provided for @thursday.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get thursday;

  /// No description provided for @friday.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get friday;

  /// No description provided for @saturday.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get saturday;

  /// No description provided for @sunday.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get sunday;

  /// No description provided for @oneHour.
  ///
  /// In en, this message translates to:
  /// **'1 Hour'**
  String get oneHour;

  /// No description provided for @dndEnabledFor.
  ///
  /// In en, this message translates to:
  /// **'DND enabled for {duration}'**
  String dndEnabledFor(String duration);

  /// No description provided for @hour.
  ///
  /// In en, this message translates to:
  /// **'hour'**
  String get hour;

  /// No description provided for @untilTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Until Tomorrow'**
  String get untilTomorrow;

  /// No description provided for @dndEnabledUntilTomorrow.
  ///
  /// In en, this message translates to:
  /// **'DND enabled until tomorrow'**
  String get dndEnabledUntilTomorrow;

  /// No description provided for @primaryEmail.
  ///
  /// In en, this message translates to:
  /// **'Primary Email'**
  String get primaryEmail;

  /// No description provided for @recoveryEmail.
  ///
  /// In en, this message translates to:
  /// **'Recovery Email'**
  String get recoveryEmail;

  /// No description provided for @marketingEmails.
  ///
  /// In en, this message translates to:
  /// **'Marketing Emails'**
  String get marketingEmails;

  /// No description provided for @marketingEmailsDesc.
  ///
  /// In en, this message translates to:
  /// **'Receive promotional emails and updates'**
  String get marketingEmailsDesc;

  /// No description provided for @securityAlerts.
  ///
  /// In en, this message translates to:
  /// **'Security Alerts'**
  String get securityAlerts;

  /// No description provided for @securityAlertsDesc.
  ///
  /// In en, this message translates to:
  /// **'Get notified about security events'**
  String get securityAlertsDesc;

  /// No description provided for @accountUpdates.
  ///
  /// In en, this message translates to:
  /// **'Account Updates'**
  String get accountUpdates;

  /// No description provided for @accountUpdatesDesc.
  ///
  /// In en, this message translates to:
  /// **'Receive account-related notifications'**
  String get accountUpdatesDesc;

  /// No description provided for @verified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get verified;

  /// No description provided for @notVerified.
  ///
  /// In en, this message translates to:
  /// **'Not Verified'**
  String get notVerified;

  /// No description provided for @recoveryEmailDesc.
  ///
  /// In en, this message translates to:
  /// **'Used to recover your account'**
  String get recoveryEmailDesc;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @changeEmail.
  ///
  /// In en, this message translates to:
  /// **'Change Email'**
  String get changeEmail;

  /// No description provided for @newEmail.
  ///
  /// In en, this message translates to:
  /// **'New Email'**
  String get newEmail;

  /// No description provided for @verificationEmailSent.
  ///
  /// In en, this message translates to:
  /// **'Verification email sent'**
  String get verificationEmailSent;

  /// No description provided for @addRecoveryEmail.
  ///
  /// In en, this message translates to:
  /// **'Add Recovery Email'**
  String get addRecoveryEmail;

  /// No description provided for @recoveryEmailAdded.
  ///
  /// In en, this message translates to:
  /// **'Recovery email added'**
  String get recoveryEmailAdded;

  /// No description provided for @fileSwipeSettings.
  ///
  /// In en, this message translates to:
  /// **'File Swipe Settings'**
  String get fileSwipeSettings;

  /// No description provided for @sampleFile.
  ///
  /// In en, this message translates to:
  /// **'Sample File'**
  String get sampleFile;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @move.
  ///
  /// In en, this message translates to:
  /// **'Move'**
  String get move;

  /// No description provided for @noteSwipeSettings.
  ///
  /// In en, this message translates to:
  /// **'Note Swipe Settings'**
  String get noteSwipeSettings;

  /// No description provided for @sampleNote.
  ///
  /// In en, this message translates to:
  /// **'Sample Note'**
  String get sampleNote;

  /// No description provided for @notificationSwipeSettings.
  ///
  /// In en, this message translates to:
  /// **'Notification Swipe Settings'**
  String get notificationSwipeSettings;

  /// No description provided for @sampleNotification.
  ///
  /// In en, this message translates to:
  /// **'Sample Notification'**
  String get sampleNotification;

  /// No description provided for @informationWeCollect.
  ///
  /// In en, this message translates to:
  /// **'Information We Collect'**
  String get informationWeCollect;

  /// No description provided for @informationWeCollectContent.
  ///
  /// In en, this message translates to:
  /// **'We collect information you provide directly to us, such as when you create an account, make a purchase, or contact us for support.'**
  String get informationWeCollectContent;

  /// No description provided for @howWeUseInfo.
  ///
  /// In en, this message translates to:
  /// **'How We Use Your Information'**
  String get howWeUseInfo;

  /// No description provided for @howWeUseInfoContent.
  ///
  /// In en, this message translates to:
  /// **'We use the information we collect to provide, maintain, and improve our services, process transactions, and send you related information.'**
  String get howWeUseInfoContent;

  /// No description provided for @informationSharing.
  ///
  /// In en, this message translates to:
  /// **'Information Sharing'**
  String get informationSharing;

  /// No description provided for @informationSharingContent.
  ///
  /// In en, this message translates to:
  /// **'We do not share your personal information with third parties except as described in this policy or with your consent.'**
  String get informationSharingContent;

  /// No description provided for @dataSecurityContent.
  ///
  /// In en, this message translates to:
  /// **'We take reasonable measures to help protect your personal information from loss, theft, misuse, and unauthorized access.'**
  String get dataSecurityContent;

  /// No description provided for @cookiesTracking.
  ///
  /// In en, this message translates to:
  /// **'Cookies & Tracking'**
  String get cookiesTracking;

  /// No description provided for @cookiesTrackingContent.
  ///
  /// In en, this message translates to:
  /// **'We use cookies and similar tracking technologies to track activity on our service and hold certain information.'**
  String get cookiesTrackingContent;

  /// No description provided for @yourRightsContent.
  ///
  /// In en, this message translates to:
  /// **'You have the right to access, correct, or delete your personal information. You can also opt out of certain data collection practices.'**
  String get yourRightsContent;

  /// No description provided for @childrenPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Children\'s Privacy'**
  String get childrenPrivacy;

  /// No description provided for @childrenPrivacyContent.
  ///
  /// In en, this message translates to:
  /// **'Our service is not directed to children under 13. We do not knowingly collect personal information from children under 13.'**
  String get childrenPrivacyContent;

  /// No description provided for @internationalTransfers.
  ///
  /// In en, this message translates to:
  /// **'International Transfers'**
  String get internationalTransfers;

  /// No description provided for @internationalTransfersContent.
  ///
  /// In en, this message translates to:
  /// **'Your information may be transferred to and maintained on servers located outside of your country.'**
  String get internationalTransfersContent;

  /// No description provided for @policyChanges.
  ///
  /// In en, this message translates to:
  /// **'Changes to This Policy'**
  String get policyChanges;

  /// No description provided for @policyChangesContent.
  ///
  /// In en, this message translates to:
  /// **'We may update this policy from time to time. We will notify you of any changes by posting the new policy on this page.'**
  String get policyChangesContent;

  /// No description provided for @privacyContactContent.
  ///
  /// In en, this message translates to:
  /// **'If you have any questions about this Privacy Policy, please contact us at privacy@eduverse.com'**
  String get privacyContactContent;

  /// No description provided for @lastUpdated.
  ///
  /// In en, this message translates to:
  /// **'Last updated: {date}'**
  String lastUpdated(String date);

  /// No description provided for @privacyIntro.
  ///
  /// In en, this message translates to:
  /// **'Your privacy is important to us. This Privacy Policy explains how we collect, use, disclose, and safeguard your information.'**
  String get privacyIntro;

  /// No description provided for @notificationSwipeDesc.
  ///
  /// In en, this message translates to:
  /// **'Configure notification swipe actions'**
  String get notificationSwipeDesc;

  /// No description provided for @chats.
  ///
  /// In en, this message translates to:
  /// **'Chats'**
  String get chats;

  /// No description provided for @chatSwipeDesc.
  ///
  /// In en, this message translates to:
  /// **'Configure chat swipe actions'**
  String get chatSwipeDesc;

  /// No description provided for @fileSwipeDesc.
  ///
  /// In en, this message translates to:
  /// **'Configure file swipe actions'**
  String get fileSwipeDesc;

  /// No description provided for @noteSwipeDesc.
  ///
  /// In en, this message translates to:
  /// **'Configure note swipe actions'**
  String get noteSwipeDesc;

  /// No description provided for @swipeActionsInfo.
  ///
  /// In en, this message translates to:
  /// **'Customize swipe actions for different features'**
  String get swipeActionsInfo;

  /// No description provided for @acceptanceOfTerms.
  ///
  /// In en, this message translates to:
  /// **'Acceptance of Terms'**
  String get acceptanceOfTerms;

  /// No description provided for @acceptanceOfTermsContent.
  ///
  /// In en, this message translates to:
  /// **'By accessing or using EduVerse, you agree to be bound by these Terms of Service and all applicable laws and regulations.'**
  String get acceptanceOfTermsContent;

  /// No description provided for @useOfService.
  ///
  /// In en, this message translates to:
  /// **'Use of Service'**
  String get useOfService;

  /// No description provided for @useOfServiceContent.
  ///
  /// In en, this message translates to:
  /// **'You may use our service only for lawful purposes and in accordance with these Terms. You agree not to use the service in any way that violates any applicable law.'**
  String get useOfServiceContent;

  /// No description provided for @userAccounts.
  ///
  /// In en, this message translates to:
  /// **'User Accounts'**
  String get userAccounts;

  /// No description provided for @userAccountsContent.
  ///
  /// In en, this message translates to:
  /// **'You are responsible for maintaining the confidentiality of your account and password. You agree to accept responsibility for all activities that occur under your account.'**
  String get userAccountsContent;

  /// No description provided for @intellectualProperty.
  ///
  /// In en, this message translates to:
  /// **'Intellectual Property'**
  String get intellectualProperty;

  /// No description provided for @intellectualPropertyContent.
  ///
  /// In en, this message translates to:
  /// **'The service and its original content, features, and functionality are owned by EduVerse and are protected by international copyright and trademark laws.'**
  String get intellectualPropertyContent;

  /// No description provided for @userContent.
  ///
  /// In en, this message translates to:
  /// **'User Content'**
  String get userContent;

  /// No description provided for @userContentContent.
  ///
  /// In en, this message translates to:
  /// **'You retain ownership of content you create. By posting content, you grant us a license to use, modify, and display that content in connection with the service.'**
  String get userContentContent;

  /// No description provided for @prohibitedActivities.
  ///
  /// In en, this message translates to:
  /// **'Prohibited Activities'**
  String get prohibitedActivities;

  /// No description provided for @prohibitedActivitiesContent.
  ///
  /// In en, this message translates to:
  /// **'You may not engage in unauthorized access, data mining, or any activity that interferes with the proper working of the service.'**
  String get prohibitedActivitiesContent;

  /// No description provided for @termination.
  ///
  /// In en, this message translates to:
  /// **'Termination'**
  String get termination;

  /// No description provided for @terminationContent.
  ///
  /// In en, this message translates to:
  /// **'We may terminate or suspend your account at any time without prior notice if you breach these Terms or engage in harmful behavior.'**
  String get terminationContent;

  /// No description provided for @disclaimers.
  ///
  /// In en, this message translates to:
  /// **'Disclaimers'**
  String get disclaimers;

  /// No description provided for @disclaimersContent.
  ///
  /// In en, this message translates to:
  /// **'The service is provided \"as is\" without warranties of any kind, either express or implied, including but not limited to implied warranties of merchantability.'**
  String get disclaimersContent;

  /// No description provided for @limitationOfLiability.
  ///
  /// In en, this message translates to:
  /// **'Limitation of Liability'**
  String get limitationOfLiability;

  /// No description provided for @limitationOfLiabilityContent.
  ///
  /// In en, this message translates to:
  /// **'EduVerse shall not be liable for any indirect, incidental, special, consequential, or punitive damages resulting from your use of the service.'**
  String get limitationOfLiabilityContent;

  /// No description provided for @changesToTerms.
  ///
  /// In en, this message translates to:
  /// **'Changes to Terms'**
  String get changesToTerms;

  /// No description provided for @changesToTermsContent.
  ///
  /// In en, this message translates to:
  /// **'We reserve the right to modify these terms at any time. We will provide notice of significant changes by posting the new Terms on the service.'**
  String get changesToTermsContent;

  /// No description provided for @contactUsContent.
  ///
  /// In en, this message translates to:
  /// **'If you have any questions about these Terms, please contact us at legal@eduverse.com'**
  String get contactUsContent;

  /// No description provided for @termsIntro.
  ///
  /// In en, this message translates to:
  /// **'Please read these Terms of Service carefully before using EduVerse. Your access to and use of the service is conditioned on your acceptance of these terms.'**
  String get termsIntro;

  /// No description provided for @searchHintText.
  ///
  /// In en, this message translates to:
  /// **'Search courses, tasks, features...'**
  String get searchHintText;

  /// No description provided for @searchRecentSearches.
  ///
  /// In en, this message translates to:
  /// **'RECENT SEARCHES'**
  String get searchRecentSearches;

  /// No description provided for @searchQuickActions.
  ///
  /// In en, this message translates to:
  /// **'QUICK ACTIONS'**
  String get searchQuickActions;

  /// No description provided for @searchResultsFound.
  ///
  /// In en, this message translates to:
  /// **'results found'**
  String get searchResultsFound;

  /// No description provided for @searchNoResults.
  ///
  /// In en, this message translates to:
  /// **'No Results Found'**
  String get searchNoResults;

  /// No description provided for @searchNoResultsFor.
  ///
  /// In en, this message translates to:
  /// **'No results for'**
  String get searchNoResultsFor;

  /// No description provided for @searchTryDifferent.
  ///
  /// In en, this message translates to:
  /// **'Try a different search term or adjust your filters'**
  String get searchTryDifferent;

  /// No description provided for @searchFilters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get searchFilters;

  /// No description provided for @searchSortByName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get searchSortByName;

  /// No description provided for @searchSortByDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get searchSortByDate;

  /// No description provided for @searchSortByType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get searchSortByType;

  /// No description provided for @searchSortDirection.
  ///
  /// In en, this message translates to:
  /// **'Sort Direction'**
  String get searchSortDirection;

  /// No description provided for @searchAscending.
  ///
  /// In en, this message translates to:
  /// **'Ascending'**
  String get searchAscending;

  /// No description provided for @searchDescending.
  ///
  /// In en, this message translates to:
  /// **'Descending'**
  String get searchDescending;

  /// No description provided for @searchTipsTitle.
  ///
  /// In en, this message translates to:
  /// **'Search Tips'**
  String get searchTipsTitle;

  /// No description provided for @searchTip1.
  ///
  /// In en, this message translates to:
  /// **'Search by course name, instructor, or code'**
  String get searchTip1;

  /// No description provided for @searchTip2.
  ///
  /// In en, this message translates to:
  /// **'Find tasks, assignments, and labs by title'**
  String get searchTip2;

  /// No description provided for @searchTip3.
  ///
  /// In en, this message translates to:
  /// **'Type a feature name to navigate quickly'**
  String get searchTip3;

  /// No description provided for @searchCategoryAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get searchCategoryAll;

  /// No description provided for @searchCategoryCourses.
  ///
  /// In en, this message translates to:
  /// **'Courses'**
  String get searchCategoryCourses;

  /// No description provided for @searchCategoryTasks.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get searchCategoryTasks;

  /// No description provided for @searchCategoryAssignments.
  ///
  /// In en, this message translates to:
  /// **'Assignments'**
  String get searchCategoryAssignments;

  /// No description provided for @searchCategoryLabs.
  ///
  /// In en, this message translates to:
  /// **'Labs'**
  String get searchCategoryLabs;

  /// No description provided for @searchCategoryGrades.
  ///
  /// In en, this message translates to:
  /// **'Grades'**
  String get searchCategoryGrades;

  /// No description provided for @searchCategoryFlashcards.
  ///
  /// In en, this message translates to:
  /// **'Flashcards'**
  String get searchCategoryFlashcards;

  /// No description provided for @searchCategoryNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get searchCategoryNotes;

  /// No description provided for @searchCategoryMessages.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get searchCategoryMessages;

  /// No description provided for @searchCategoryFeatures.
  ///
  /// In en, this message translates to:
  /// **'Features'**
  String get searchCategoryFeatures;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @onboardingTitle1.
  ///
  /// In en, this message translates to:
  /// **'Welcome to EduVerse'**
  String get onboardingTitle1;

  /// No description provided for @onboardingDescription1.
  ///
  /// In en, this message translates to:
  /// **'Your AI-powered learning companion. Experience smarter education with personalized study plans, intelligent quizzes, and comprehensive progress tracking.'**
  String get onboardingDescription1;

  /// No description provided for @onboardingTitle2.
  ///
  /// In en, this message translates to:
  /// **'AI-Powered Learning'**
  String get onboardingTitle2;

  /// No description provided for @onboardingDescription2.
  ///
  /// In en, this message translates to:
  /// **'Unlock powerful AI tools that adapt to your learning style. Generate quizzes, create flashcards, and get smart summaries automatically.'**
  String get onboardingDescription2;

  /// No description provided for @onboardingTitle3.
  ///
  /// In en, this message translates to:
  /// **'Track Your Progress'**
  String get onboardingTitle3;

  /// No description provided for @onboardingDescription3.
  ///
  /// In en, this message translates to:
  /// **'Monitor your performance with detailed analytics. Track attendance, grades, and achievements all in one place.'**
  String get onboardingDescription3;

  /// No description provided for @onboardingTitle4.
  ///
  /// In en, this message translates to:
  /// **'Ready to Begin?'**
  String get onboardingTitle4;

  /// No description provided for @onboardingDescription4.
  ///
  /// In en, this message translates to:
  /// **'Join thousands of students achieving their academic goals. Your journey to smarter learning starts now.'**
  String get onboardingDescription4;

  /// No description provided for @shareApp.
  ///
  /// In en, this message translates to:
  /// **'Share App'**
  String get shareApp;

  /// No description provided for @shareAppDesc.
  ///
  /// In en, this message translates to:
  /// **'Share EduVerse with friends'**
  String get shareAppDesc;

  /// No description provided for @shareAppTitle.
  ///
  /// In en, this message translates to:
  /// **'Share EduVerse'**
  String get shareAppTitle;

  /// No description provided for @shareAppSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Help your friends discover the future of intelligent learning'**
  String get shareAppSubtitle;

  /// No description provided for @chooseShareMethod.
  ///
  /// In en, this message translates to:
  /// **'Choose how you want to share'**
  String get chooseShareMethod;

  /// No description provided for @shareViaQrCode.
  ///
  /// In en, this message translates to:
  /// **'QR Code'**
  String get shareViaQrCode;

  /// No description provided for @shareViaQrCodeDesc.
  ///
  /// In en, this message translates to:
  /// **'Let others scan to download'**
  String get shareViaQrCodeDesc;

  /// No description provided for @shareViaApk.
  ///
  /// In en, this message translates to:
  /// **'APK File'**
  String get shareViaApk;

  /// No description provided for @shareViaApkDesc.
  ///
  /// In en, this message translates to:
  /// **'Share the app installation file'**
  String get shareViaApkDesc;

  /// No description provided for @qrCodeShareTitle.
  ///
  /// In en, this message translates to:
  /// **'Share via QR Code'**
  String get qrCodeShareTitle;

  /// No description provided for @qrCodeShareSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Let others scan this code to get EduVerse'**
  String get qrCodeShareSubtitle;

  /// No description provided for @scanToDownload.
  ///
  /// In en, this message translates to:
  /// **'Scan to Download'**
  String get scanToDownload;

  /// No description provided for @qrCodeInstructions.
  ///
  /// In en, this message translates to:
  /// **'Ask your friend to scan this QR code with their camera app to download EduVerse'**
  String get qrCodeInstructions;

  /// No description provided for @shareQrCode.
  ///
  /// In en, this message translates to:
  /// **'Share QR Code'**
  String get shareQrCode;

  /// No description provided for @saveQrCode.
  ///
  /// In en, this message translates to:
  /// **'Save QR Code'**
  String get saveQrCode;

  /// No description provided for @qrCodeSaved.
  ///
  /// In en, this message translates to:
  /// **'QR code saved to gallery'**
  String get qrCodeSaved;

  /// No description provided for @qrCodeShared.
  ///
  /// In en, this message translates to:
  /// **'QR code shared successfully'**
  String get qrCodeShared;

  /// No description provided for @apkShareTitle.
  ///
  /// In en, this message translates to:
  /// **'Share via APK'**
  String get apkShareTitle;

  /// No description provided for @apkShareSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Share the app installation file directly'**
  String get apkShareSubtitle;

  /// No description provided for @shareApkFile.
  ///
  /// In en, this message translates to:
  /// **'Share APK File'**
  String get shareApkFile;

  /// No description provided for @apkShareInstructions.
  ///
  /// In en, this message translates to:
  /// **'The APK file will be shared via your preferred app. The recipient can install it directly on their Android device.'**
  String get apkShareInstructions;

  /// No description provided for @preparingApk.
  ///
  /// In en, this message translates to:
  /// **'Preparing APK file...'**
  String get preparingApk;

  /// No description provided for @apkShared.
  ///
  /// In en, this message translates to:
  /// **'APK shared successfully'**
  String get apkShared;

  /// No description provided for @apkShareFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to share APK'**
  String get apkShareFailed;

  /// No description provided for @apkNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'APK file not available on this device'**
  String get apkNotAvailable;

  /// No description provided for @shareAppMessage.
  ///
  /// In en, this message translates to:
  /// **'Check out EduVerse - the AI-powered learning platform! Download it now: https://eduverse.app/download'**
  String get shareAppMessage;

  /// No description provided for @appDownloadLink.
  ///
  /// In en, this message translates to:
  /// **'https://eduverse.app/download'**
  String get appDownloadLink;

  /// No description provided for @copyLink.
  ///
  /// In en, this message translates to:
  /// **'Copy Link'**
  String get copyLink;

  /// No description provided for @linkCopied.
  ///
  /// In en, this message translates to:
  /// **'Link copied to clipboard'**
  String get linkCopied;

  /// No description provided for @shareLink.
  ///
  /// In en, this message translates to:
  /// **'Share Link'**
  String get shareLink;

  /// No description provided for @orShareVia.
  ///
  /// In en, this message translates to:
  /// **'Or share via'**
  String get orShareVia;

  /// No description provided for @backToOptions.
  ///
  /// In en, this message translates to:
  /// **'Back to Options'**
  String get backToOptions;

  /// No description provided for @shareError.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while sharing'**
  String get shareError;

  /// No description provided for @tryAgainLater.
  ///
  /// In en, this message translates to:
  /// **'Please try again later'**
  String get tryAgainLater;

  /// No description provided for @androidOnly.
  ///
  /// In en, this message translates to:
  /// **'This feature is only available on Android devices'**
  String get androidOnly;

  /// No description provided for @sharingInProgress.
  ///
  /// In en, this message translates to:
  /// **'Sharing in progress...'**
  String get sharingInProgress;

  /// No description provided for @qrCodeGenerating.
  ///
  /// In en, this message translates to:
  /// **'Generating QR code...'**
  String get qrCodeGenerating;

  /// No description provided for @downloadApp.
  ///
  /// In en, this message translates to:
  /// **'Download EduVerse'**
  String get downloadApp;

  /// No description provided for @inviteFriends.
  ///
  /// In en, this message translates to:
  /// **'Invite Friends'**
  String get inviteFriends;

  /// No description provided for @spreadTheWord.
  ///
  /// In en, this message translates to:
  /// **'Spread the word about EduVerse'**
  String get spreadTheWord;

  /// No description provided for @shareStatistics.
  ///
  /// In en, this message translates to:
  /// **'Share Statistics'**
  String get shareStatistics;

  /// No description provided for @friendsInvited.
  ///
  /// In en, this message translates to:
  /// **'Friends Invited'**
  String get friendsInvited;

  /// No description provided for @appInstallations.
  ///
  /// In en, this message translates to:
  /// **'App Installations'**
  String get appInstallations;

  /// No description provided for @brightness.
  ///
  /// In en, this message translates to:
  /// **'Brightness'**
  String get brightness;

  /// No description provided for @qrSize.
  ///
  /// In en, this message translates to:
  /// **'QR Size'**
  String get qrSize;

  /// No description provided for @customizeQr.
  ///
  /// In en, this message translates to:
  /// **'Customize QR Code'**
  String get customizeQr;

  /// No description provided for @resetQr.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get resetQr;

  /// No description provided for @apkSize.
  ///
  /// In en, this message translates to:
  /// **'APK Size'**
  String get apkSize;

  /// No description provided for @estimatedSize.
  ///
  /// In en, this message translates to:
  /// **'Estimated size: ~50 MB'**
  String get estimatedSize;

  /// No description provided for @requiresAndroid.
  ///
  /// In en, this message translates to:
  /// **'Requires Android 5.0 or later'**
  String get requiresAndroid;

  /// No description provided for @installationNote.
  ///
  /// In en, this message translates to:
  /// **'Note: The recipient may need to enable \'Install from unknown sources\' in their device settings'**
  String get installationNote;

  /// No description provided for @instructorDashboard.
  ///
  /// In en, this message translates to:
  /// **'Instructor Dashboard'**
  String get instructorDashboard;

  /// No description provided for @totalStudentsLabel.
  ///
  /// In en, this message translates to:
  /// **'Total Students'**
  String get totalStudentsLabel;

  /// No description provided for @pendingGrading.
  ///
  /// In en, this message translates to:
  /// **'Pending Grading'**
  String get pendingGrading;

  /// No description provided for @pendingQuizzes.
  ///
  /// In en, this message translates to:
  /// **'Pending Quizzes'**
  String get pendingQuizzes;

  /// No description provided for @unreadMessagesLabel.
  ///
  /// In en, this message translates to:
  /// **'Unread Messages'**
  String get unreadMessagesLabel;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// No description provided for @createAssignment.
  ///
  /// In en, this message translates to:
  /// **'Create Assignment'**
  String get createAssignment;

  /// No description provided for @uploadMaterial.
  ///
  /// In en, this message translates to:
  /// **'Upload Material'**
  String get uploadMaterial;

  /// No description provided for @openCourse.
  ///
  /// In en, this message translates to:
  /// **'Open Course'**
  String get openCourse;

  /// No description provided for @askAiAssistant.
  ///
  /// In en, this message translates to:
  /// **'Ask AI Assistant'**
  String get askAiAssistant;

  /// No description provided for @viewAllCourses.
  ///
  /// In en, this message translates to:
  /// **'View All Courses'**
  String get viewAllCourses;

  /// No description provided for @students.
  ///
  /// In en, this message translates to:
  /// **'Students'**
  String get students;

  /// No description provided for @courseCode.
  ///
  /// In en, this message translates to:
  /// **'Course Code'**
  String get courseCode;

  /// No description provided for @courseName.
  ///
  /// In en, this message translates to:
  /// **'Course Name'**
  String get courseName;

  /// No description provided for @enterCourseName.
  ///
  /// In en, this message translates to:
  /// **'Enter course name'**
  String get enterCourseName;

  /// No description provided for @courseCreated.
  ///
  /// In en, this message translates to:
  /// **'Course created successfully'**
  String get courseCreated;

  /// No description provided for @createCourse.
  ///
  /// In en, this message translates to:
  /// **'Create Course'**
  String get createCourse;

  /// No description provided for @editCourse.
  ///
  /// In en, this message translates to:
  /// **'Edit Course'**
  String get editCourse;

  /// No description provided for @manageStudents.
  ///
  /// In en, this message translates to:
  /// **'Manage Students'**
  String get manageStudents;

  /// No description provided for @viewAnalytics.
  ///
  /// In en, this message translates to:
  /// **'View Analytics'**
  String get viewAnalytics;

  /// No description provided for @archiveCourse.
  ///
  /// In en, this message translates to:
  /// **'Archive Course'**
  String get archiveCourse;

  /// No description provided for @gradingCenter.
  ///
  /// In en, this message translates to:
  /// **'Grading Center'**
  String get gradingCenter;

  /// No description provided for @totalSubmissions.
  ///
  /// In en, this message translates to:
  /// **'Total Submissions'**
  String get totalSubmissions;

  /// No description provided for @averageGrade.
  ///
  /// In en, this message translates to:
  /// **'Average Grade'**
  String get averageGrade;

  /// No description provided for @completionRate.
  ///
  /// In en, this message translates to:
  /// **'Completion Rate'**
  String get completionRate;

  /// No description provided for @submissions.
  ///
  /// In en, this message translates to:
  /// **'Submissions'**
  String get submissions;

  /// No description provided for @searchStudents.
  ///
  /// In en, this message translates to:
  /// **'Search students...'**
  String get searchStudents;

  /// No description provided for @allCourses.
  ///
  /// In en, this message translates to:
  /// **'All Courses'**
  String get allCourses;

  /// No description provided for @noPendingSubmissions.
  ///
  /// In en, this message translates to:
  /// **'No pending submissions'**
  String get noPendingSubmissions;

  /// No description provided for @noGradedSubmissions.
  ///
  /// In en, this message translates to:
  /// **'No graded submissions yet'**
  String get noGradedSubmissions;

  /// No description provided for @noLateSubmissions.
  ///
  /// In en, this message translates to:
  /// **'Great! No late submissions'**
  String get noLateSubmissions;

  /// No description provided for @noSubmissionsFound.
  ///
  /// In en, this message translates to:
  /// **'No submissions found'**
  String get noSubmissionsFound;

  /// No description provided for @gradeSubmission.
  ///
  /// In en, this message translates to:
  /// **'Grade Submission'**
  String get gradeSubmission;

  /// No description provided for @grade.
  ///
  /// In en, this message translates to:
  /// **'Grade'**
  String get grade;

  /// No description provided for @quickGrade.
  ///
  /// In en, this message translates to:
  /// **'Quick Grade'**
  String get quickGrade;

  /// No description provided for @feedback.
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get feedback;

  /// No description provided for @quickFeedback.
  ///
  /// In en, this message translates to:
  /// **'Quick Feedback'**
  String get quickFeedback;

  /// No description provided for @enterFeedback.
  ///
  /// In en, this message translates to:
  /// **'Enter your feedback for the student...'**
  String get enterFeedback;

  /// No description provided for @submitGrade.
  ///
  /// In en, this message translates to:
  /// **'Submit Grade'**
  String get submitGrade;

  /// No description provided for @gradeSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Grade submitted successfully'**
  String get gradeSubmitted;

  /// No description provided for @editGrade.
  ///
  /// In en, this message translates to:
  /// **'Edit Grade'**
  String get editGrade;

  /// No description provided for @viewDetails.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get viewDetails;

  /// No description provided for @assignmentDetails.
  ///
  /// In en, this message translates to:
  /// **'Assignment Details'**
  String get assignmentDetails;

  /// No description provided for @assignment.
  ///
  /// In en, this message translates to:
  /// **'Assignment'**
  String get assignment;

  /// No description provided for @submittedFiles.
  ///
  /// In en, this message translates to:
  /// **'Submitted Files'**
  String get submittedFiles;

  /// No description provided for @gradeInfo.
  ///
  /// In en, this message translates to:
  /// **'Grade Information'**
  String get gradeInfo;

  /// No description provided for @percentage.
  ///
  /// In en, this message translates to:
  /// **'Percentage'**
  String get percentage;

  /// No description provided for @exportGrades.
  ///
  /// In en, this message translates to:
  /// **'Export Grades'**
  String get exportGrades;

  /// No description provided for @gradingSettings.
  ///
  /// In en, this message translates to:
  /// **'Grading Settings'**
  String get gradingSettings;

  /// No description provided for @day.
  ///
  /// In en, this message translates to:
  /// **'day'**
  String get day;

  /// No description provided for @courseMaterials.
  ///
  /// In en, this message translates to:
  /// **'Course Materials'**
  String get courseMaterials;

  /// No description provided for @courseAnnouncements.
  ///
  /// In en, this message translates to:
  /// **'Announcements'**
  String get courseAnnouncements;

  /// No description provided for @courseStudents.
  ///
  /// In en, this message translates to:
  /// **'Students'**
  String get courseStudents;

  /// No description provided for @courseAssignments.
  ///
  /// In en, this message translates to:
  /// **'Assignments'**
  String get courseAssignments;

  /// No description provided for @instructorCourses.
  ///
  /// In en, this message translates to:
  /// **'Instructor Courses'**
  String get instructorCourses;

  /// No description provided for @type.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get type;

  /// No description provided for @courseProgress.
  ///
  /// In en, this message translates to:
  /// **'Course Progress'**
  String get courseProgress;

  /// No description provided for @pendingLabel.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pendingLabel;

  /// No description provided for @quizzesLabel.
  ///
  /// In en, this message translates to:
  /// **'Quizzes'**
  String get quizzesLabel;

  /// No description provided for @messagesLabel.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get messagesLabel;

  /// No description provided for @nextClass.
  ///
  /// In en, this message translates to:
  /// **'Next Class'**
  String get nextClass;

  /// No description provided for @activeLabel.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get activeLabel;

  /// No description provided for @progress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progress;

  /// No description provided for @studentCount.
  ///
  /// In en, this message translates to:
  /// **'Student Count'**
  String get studentCount;

  /// No description provided for @createFirstCourse.
  ///
  /// In en, this message translates to:
  /// **'Create your first course'**
  String get createFirstCourse;

  /// No description provided for @analyticsTitle.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get analyticsTitle;

  /// No description provided for @assignmentTitle.
  ///
  /// In en, this message translates to:
  /// **'Assignment Title'**
  String get assignmentTitle;

  /// No description provided for @enterAssignmentTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter assignment title'**
  String get enterAssignmentTitle;

  /// No description provided for @assignmentCreated.
  ///
  /// In en, this message translates to:
  /// **'Assignment created successfully'**
  String get assignmentCreated;

  /// No description provided for @dragAndDropFiles.
  ///
  /// In en, this message translates to:
  /// **'Drag and drop files here'**
  String get dragAndDropFiles;

  /// No description provided for @orBrowseFiles.
  ///
  /// In en, this message translates to:
  /// **'or browse files'**
  String get orBrowseFiles;

  /// No description provided for @materialUploaded.
  ///
  /// In en, this message translates to:
  /// **'Material uploaded successfully'**
  String get materialUploaded;

  /// No description provided for @browseFiles.
  ///
  /// In en, this message translates to:
  /// **'Browse Files'**
  String get browseFiles;

  /// No description provided for @sendMessage.
  ///
  /// In en, this message translates to:
  /// **'Send Message'**
  String get sendMessage;

  /// No description provided for @viewGrades.
  ///
  /// In en, this message translates to:
  /// **'View Grades'**
  String get viewGrades;

  /// No description provided for @postAnnouncement.
  ///
  /// In en, this message translates to:
  /// **'Post Announcement'**
  String get postAnnouncement;

  /// No description provided for @myCourses.
  ///
  /// In en, this message translates to:
  /// **'My Courses'**
  String get myCourses;

  /// No description provided for @archived.
  ///
  /// In en, this message translates to:
  /// **'Archived'**
  String get archived;

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good Morning'**
  String get goodMorning;

  /// No description provided for @goodAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good Afternoon'**
  String get goodAfternoon;

  /// No description provided for @aiTeachingOverview.
  ///
  /// In en, this message translates to:
  /// **'AI Teaching Overview'**
  String get aiTeachingOverview;

  /// No description provided for @dashboardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Explore AI-assisted course insights — here are your priority actions today.'**
  String get dashboardSubtitle;

  /// No description provided for @assignmentsPendingGrading.
  ///
  /// In en, this message translates to:
  /// **'Assignments Pending Grading'**
  String get assignmentsPendingGrading;

  /// No description provided for @studentsAtRisk.
  ///
  /// In en, this message translates to:
  /// **'Students At Risk (Low Progress)'**
  String get studentsAtRisk;

  /// No description provided for @submissionsToReview.
  ///
  /// In en, this message translates to:
  /// **'submissions to review'**
  String get submissionsToReview;

  /// No description provided for @nextDays.
  ///
  /// In en, this message translates to:
  /// **'Next {count} days'**
  String nextDays(int count);

  /// No description provided for @viewFullCalendar.
  ///
  /// In en, this message translates to:
  /// **'View Full Calendar'**
  String get viewFullCalendar;

  /// No description provided for @calendarComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Calendar feature coming soon'**
  String get calendarComingSoon;

  /// No description provided for @messagesComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Messages feature coming soon'**
  String get messagesComingSoon;

  /// No description provided for @helpComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Help & Support coming soon'**
  String get helpComingSoon;

  /// No description provided for @helpSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpSupport;

  /// No description provided for @noMaterialsYet.
  ///
  /// In en, this message translates to:
  /// **'No materials uploaded yet'**
  String get noMaterialsYet;

  /// No description provided for @noAnnouncementsYet.
  ///
  /// In en, this message translates to:
  /// **'No announcements yet'**
  String get noAnnouncementsYet;

  /// No description provided for @announcementPosted.
  ///
  /// In en, this message translates to:
  /// **'Announcement posted successfully'**
  String get announcementPosted;

  /// No description provided for @newAnnouncement.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get newAnnouncement;

  /// No description provided for @announcementsManager.
  ///
  /// In en, this message translates to:
  /// **'Announcements Manager'**
  String get announcementsManager;

  /// No description provided for @announcementsManagerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create, publish, and track course updates'**
  String get announcementsManagerSubtitle;

  /// No description provided for @searchAnnouncements.
  ///
  /// In en, this message translates to:
  /// **'Search announcements...'**
  String get searchAnnouncements;

  /// No description provided for @noAnnouncementsFoundSearch.
  ///
  /// In en, this message translates to:
  /// **'No Announcements Found'**
  String get noAnnouncementsFoundSearch;

  /// No description provided for @createFirstAnnouncement.
  ///
  /// In en, this message translates to:
  /// **'Create your first announcement to keep students informed'**
  String get createFirstAnnouncement;

  /// No description provided for @allAnnouncements.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allAnnouncements;

  /// No description provided for @publishedAnnouncements.
  ///
  /// In en, this message translates to:
  /// **'Published'**
  String get publishedAnnouncements;

  /// No description provided for @scheduledAnnouncements.
  ///
  /// In en, this message translates to:
  /// **'Scheduled'**
  String get scheduledAnnouncements;

  /// No description provided for @draftAnnouncements.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get draftAnnouncements;

  /// No description provided for @editAnnouncement.
  ///
  /// In en, this message translates to:
  /// **'Edit Announcement'**
  String get editAnnouncement;

  /// No description provided for @deleteAnnouncement.
  ///
  /// In en, this message translates to:
  /// **'Delete Announcement'**
  String get deleteAnnouncement;

  /// No description provided for @deleteAnnouncementConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this announcement? This action cannot be undone.'**
  String get deleteAnnouncementConfirm;

  /// No description provided for @announcementTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get announcementTitle;

  /// No description provided for @announcementTitleHint.
  ///
  /// In en, this message translates to:
  /// **'Enter announcement title...'**
  String get announcementTitleHint;

  /// No description provided for @announcementContent.
  ///
  /// In en, this message translates to:
  /// **'Content'**
  String get announcementContent;

  /// No description provided for @announcementContentHint.
  ///
  /// In en, this message translates to:
  /// **'Write your announcement here...'**
  String get announcementContentHint;

  /// No description provided for @announcementAudience.
  ///
  /// In en, this message translates to:
  /// **'Audience'**
  String get announcementAudience;

  /// No description provided for @publishImmediately.
  ///
  /// In en, this message translates to:
  /// **'Publish Immediately'**
  String get publishImmediately;

  /// No description provided for @scheduleDate.
  ///
  /// In en, this message translates to:
  /// **'Schedule Date'**
  String get scheduleDate;

  /// No description provided for @scheduleTime.
  ///
  /// In en, this message translates to:
  /// **'Schedule Time'**
  String get scheduleTime;

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'Select date'**
  String get selectDate;

  /// No description provided for @selectTime.
  ///
  /// In en, this message translates to:
  /// **'Select time'**
  String get selectTime;

  /// No description provided for @attachments.
  ///
  /// In en, this message translates to:
  /// **'Attachments'**
  String get attachments;

  /// No description provided for @dragFilesOrBrowse.
  ///
  /// In en, this message translates to:
  /// **'Drag files here or tap to browse'**
  String get dragFilesOrBrowse;

  /// No description provided for @addFiles.
  ///
  /// In en, this message translates to:
  /// **'Add Files'**
  String get addFiles;

  /// No description provided for @saveDraft.
  ///
  /// In en, this message translates to:
  /// **'Save Draft'**
  String get saveDraft;

  /// No description provided for @publish.
  ///
  /// In en, this message translates to:
  /// **'Publish'**
  String get publish;

  /// No description provided for @aiWritingAssistant.
  ///
  /// In en, this message translates to:
  /// **'AI Writing Assistant'**
  String get aiWritingAssistant;

  /// No description provided for @announcementCreated.
  ///
  /// In en, this message translates to:
  /// **'Announcement created successfully!'**
  String get announcementCreated;

  /// No description provided for @announcementUpdated.
  ///
  /// In en, this message translates to:
  /// **'Announcement updated successfully!'**
  String get announcementUpdated;

  /// No description provided for @announcementDeleted.
  ///
  /// In en, this message translates to:
  /// **'Announcement deleted successfully!'**
  String get announcementDeleted;

  /// No description provided for @announcementPublished.
  ///
  /// In en, this message translates to:
  /// **'Announcement published successfully!'**
  String get announcementPublished;

  /// No description provided for @readRate.
  ///
  /// In en, this message translates to:
  /// **'Read Rate'**
  String get readRate;

  /// No description provided for @views.
  ///
  /// In en, this message translates to:
  /// **'Views'**
  String get views;

  /// No description provided for @announcementAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Announcement Analytics'**
  String get announcementAnalytics;

  /// No description provided for @viewsOverTime.
  ///
  /// In en, this message translates to:
  /// **'Views Over Time'**
  String get viewsOverTime;

  /// No description provided for @aiInsight.
  ///
  /// In en, this message translates to:
  /// **'AI Insight'**
  String get aiInsight;

  /// No description provided for @dailyViews.
  ///
  /// In en, this message translates to:
  /// **'Daily Views'**
  String get dailyViews;

  /// No description provided for @publishNow.
  ///
  /// In en, this message translates to:
  /// **'Publish Now'**
  String get publishNow;

  /// No description provided for @analyticsComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Analytics feature coming soon'**
  String get analyticsComingSoon;

  /// No description provided for @activeQuizzes.
  ///
  /// In en, this message translates to:
  /// **'active quizzes'**
  String get activeQuizzes;

  /// No description provided for @newItems.
  ///
  /// In en, this message translates to:
  /// **'new items'**
  String get newItems;

  /// No description provided for @gradeNow.
  ///
  /// In en, this message translates to:
  /// **'Grade Now'**
  String get gradeNow;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
