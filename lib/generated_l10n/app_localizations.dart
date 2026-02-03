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
  /// **'Simplify grading and focus on teaching impact.'**
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
  /// **'Quiz Type'**
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
