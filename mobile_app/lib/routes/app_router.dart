import 'package:flutter/material.dart';
import 'package:mobile_app/models/donation_model.dart';
import 'package:mobile_app/screens/admin/admin_home_screen.dart';
import 'package:mobile_app/screens/auth/email_verification_screen.dart';
import 'package:mobile_app/screens/auth/forgot_password_screen.dart';
import 'package:mobile_app/screens/auth/login_screen.dart';
import 'package:mobile_app/screens/auth/register_screen.dart';
import 'package:mobile_app/screens/auth/welcome_screen.dart';
import 'package:mobile_app/screens/beneficiary/beneficiary_home_screen.dart';
import 'package:mobile_app/screens/common/edit_profile_screen.dart';
import 'package:mobile_app/screens/common/not_found_screen.dart';
import 'package:mobile_app/screens/common/splash_screen.dart';
import 'package:mobile_app/screens/common/user_profile_screen.dart';
import 'package:mobile_app/screens/delivery/delivery_home_screen.dart';
import 'package:mobile_app/screens/donor/create_donation_screen.dart';
import 'package:mobile_app/screens/donor/donation_details_screen.dart';
import 'package:mobile_app/screens/donor/donor_home_screen.dart';
import 'package:mobile_app/screens/donor/edit_donation_screen.dart';
import 'package:mobile_app/screens/donor/my_donations_screen.dart';
import 'package:mobile_app/screens/ngo/browse_donations_screen.dart';
import 'package:mobile_app/screens/ngo/ngo_donation_details_screen.dart';
import 'package:mobile_app/screens/ngo/ngo_history_screen.dart';
import 'package:mobile_app/screens/ngo/ngo_home_screen.dart';
import 'package:mobile_app/screens/ngo/notification_center_screen.dart';
import 'package:mobile_app/screens/tracking/live_tracking_screen.dart';
import 'package:mobile_app/screens/tracking/qr_scanner_screen.dart';
import 'package:mobile_app/screens/volunteer/available_deliveries_screen.dart';
import 'package:mobile_app/screens/volunteer/volunteer_history_screen.dart';
import 'package:mobile_app/screens/volunteer/volunteer_home_screen.dart';
import 'package:mobile_app/screens/volunteer/volunteer_task_details_screen.dart';

class AppRouter {
  // Common Routes
  static const String splashRoute = '/';
  static const String profileRoute = '/profile';
  static const String editProfileRoute = '/profile/edit';

  // Auth Routes
  static const String welcomeRoute = '/welcome';
  static const String loginRoute = '/login';
  static const String registerRoute = '/register';
  static const String forgotPasswordRoute = '/forgot-password';
  static const String emailVerificationRoute = '/email-verification';

  // Donor Routes
  static const String donorHomeRoute = '/donor/home';
  static const String createDonationRoute = '/donor/create';
  static const String myDonationsRoute = '/donor/my-donations';
  static const String donationDetailsRoute = '/donor/details';
  static const String editDonationRoute = '/donor/edit';

  // NGO Routes
  static const String ngoHomeRoute = '/ngo/home';
  static const String ngoBrowseRoute = '/ngo/browse';
  static const String ngoDetailsRoute = '/ngo/details';
  static const String ngoHistoryRoute = '/ngo/history';
  static const String ngoNotificationsRoute = '/ngo/notifications';

  // Volunteer Routes
  static const String volunteerHomeRoute = '/volunteer/home';
  static const String volunteerAvailableRoute = '/volunteer/available';
  static const String volunteerTaskDetailsRoute = '/volunteer/details';
  static const String volunteerHistoryRoute = '/volunteer/history';

  // Tracking Routes
  static const String liveTrackingRoute = '/tracking/live';
  static const String qrScannerRoute = '/tracking/qr-scan';

  // Other Role Routes
  static const String deliveryHomeRoute = '/delivery/home';
  static const String beneficiaryHomeRoute = '/beneficiary/home';
  static const String adminHomeRoute = '/admin/home';

  static String getHomeRouteForRole(String role) {
    switch (role.trim().toLowerCase()) {
      case 'ngo':
        return ngoHomeRoute;
      case 'volunteer':
        return volunteerHomeRoute;
      case 'delivery partner':
      case 'delivery':
        return deliveryHomeRoute;
      case 'beneficiary':
        return beneficiaryHomeRoute;
      case 'admin':
        return adminHomeRoute;
      case 'donor':
      default:
        return donorHomeRoute;
    }
  }

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splashRoute:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case profileRoute:
        return MaterialPageRoute(builder: (_) => const UserProfileScreen());
      case editProfileRoute:
        return MaterialPageRoute(builder: (_) => const EditProfileScreen());
      case welcomeRoute:
        return MaterialPageRoute(builder: (_) => const WelcomeScreen());
      case loginRoute:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case registerRoute:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case forgotPasswordRoute:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());
      case emailVerificationRoute:
        return MaterialPageRoute(builder: (_) => const EmailVerificationScreen());

      // Donor Routes
      case donorHomeRoute:
        return MaterialPageRoute(builder: (_) => const DonorHomeScreen());
      case createDonationRoute:
        return MaterialPageRoute(builder: (_) => const CreateDonationScreen());
      case myDonationsRoute:
        return MaterialPageRoute(builder: (_) => const MyDonationsScreen());
      case donationDetailsRoute:
        return MaterialPageRoute(builder: (_) => const DonationDetailsScreen());
      case editDonationRoute:
        return MaterialPageRoute(builder: (_) => const EditDonationScreen());

      // NGO Routes
      case ngoHomeRoute:
        return MaterialPageRoute(builder: (_) => const NgoHomeScreen());
      case ngoBrowseRoute:
        return MaterialPageRoute(builder: (_) => const BrowseDonationsScreen());
      case ngoDetailsRoute:
        return MaterialPageRoute(builder: (_) => const NgoDonationDetailsScreen());
      case ngoHistoryRoute:
        return MaterialPageRoute(builder: (_) => const NgoHistoryScreen());
      case ngoNotificationsRoute:
        return MaterialPageRoute(builder: (_) => const NotificationCenterScreen());

      // Volunteer Routes
      case volunteerHomeRoute:
        return MaterialPageRoute(builder: (_) => const VolunteerHomeScreen());
      case volunteerAvailableRoute:
        return MaterialPageRoute(builder: (_) => const AvailableDeliveriesScreen());
      case volunteerTaskDetailsRoute:
        return MaterialPageRoute(builder: (_) => const VolunteerTaskDetailsScreen());
      case volunteerHistoryRoute:
        return MaterialPageRoute(builder: (_) => const VolunteerHistoryScreen());

      // Tracking Routes
      case liveTrackingRoute:
        final donation = settings.arguments as DonationModel?;
        return MaterialPageRoute(
          builder: (_) => LiveTrackingScreen(
            donation: donation ??
                DonationModel(
                  donationId: 'demo_id',
                  donorId: 'donor_demo',
                  donorName: 'Arun Balaji',
                  foodName: 'Surplus Food Rescue',
                  foodCategory: 'cooked_meal',
                  foodType: 'Veg',
                  quantity: 10,
                  unit: 'kg',
                  numberOfMeals: 20,
                  preparationTime: DateTime.now(),
                  expiryTime: DateTime.now().add(const Duration(hours: 4)),
                  pickupAddress: 'Sector 5, Bangalore',
                  latitude: 12.9716,
                  longitude: 77.5946,
                  contactNumber: '+919876543210',
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                ),
          ),
        );
      case qrScannerRoute:
        return MaterialPageRoute(builder: (_) => const QrScannerScreen());

      // Other Role Routes
      case deliveryHomeRoute:
        return MaterialPageRoute(builder: (_) => const DeliveryHomeScreen());
      case beneficiaryHomeRoute:
        return MaterialPageRoute(builder: (_) => const BeneficiaryHomeScreen());
      case adminHomeRoute:
        return MaterialPageRoute(builder: (_) => const AdminHomeScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => NotFoundScreen(routeName: settings.name),
        );
    }
  }
}
