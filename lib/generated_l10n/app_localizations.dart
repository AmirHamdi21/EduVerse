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
  /// **'Email address not found'**
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
