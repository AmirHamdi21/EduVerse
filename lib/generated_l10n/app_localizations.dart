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
  /// **'Enter description (optional)'**
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
  /// **'days ago'**
  String get daysAgo;

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
  /// **'this week'**
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
  /// **'Try adjusting your filters'**
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
