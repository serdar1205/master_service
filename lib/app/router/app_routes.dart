class AppRoutes {
  const AppRoutes._();

  static const splash = '/';
  static const phoneLogin = '/login';
  static const otp = '/otp';
  static const profileSetup = '/profile-setup';
  static const categorySetup = '/category-setup';
  static const home = '/home';
  static const jobs = '/jobs';
  static const jobDetails = '/jobs/:jobId';
  static const map = '/map';
  static const history = '/history';
  static const payments = '/payments';
  static const settings = '/settings';

  static String jobDetailsPath(String jobId) => '/jobs/$jobId';
}
