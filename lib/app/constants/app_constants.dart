/// Site-wide configuration. Everything you may need to edit lives here or in
/// `portfolio_content.dart`.
abstract final class AppConstants {
  static const siteTitle = 'Dinolin Dhas | Flutter Developer';

  static const email = 'cdinolindhas@gmail.com';
  static const linkedInUrl = 'https://www.linkedin.com/in/dinolindhas-c';

  // ---------------------------------------------------------------------------
  // TODO(dinolin): WhatsApp number in international format, digits only, with
  // no "+", spaces or dashes. For an Indian number: 91XXXXXXXXXX.
  // While this is empty the WhatsApp button explains that and offers email.
  // ---------------------------------------------------------------------------
  static const whatsAppNumber = '';

  /// While empty, no GitHub link is shown.
  static const gitHubUsername = 'DinotechDesigns';

  /// Drop the PDF at this path and rebuild; see the README.
  static const resumeAsset = 'assets/resume/dinolin-dhas-resume.pdf';
  static const resumeFileName = 'Dinolin-Dhas-Resume.pdf';
}

abstract final class AppAssets {
  static const profile = 'assets/images/profile.webp';
  static const about = 'assets/images/about.webp';
  static const opticalIcon = 'assets/images/opticalhr_icon.png';
  static const opticalDashboard = 'assets/images/opticalhr_dashboard.webp';
  static const opticalAttendance = 'assets/images/opticalhr_attendance.webp';
  static const smartmiIcon = 'assets/images/smartmi_icon.png';
  static const smartmiHome = 'assets/images/smartmi_home.webp';
  static const smartmiSignIn = 'assets/images/smartmi_signin.webp';

  static const all = [
    profile,
    about,
    opticalIcon,
    opticalDashboard,
    opticalAttendance,
    smartmiIcon,
    smartmiHome,
    smartmiSignIn,
  ];
}

/// Page sections in scroll order.
enum SectionId {
  home('Home'),
  about('About'),
  skills('Skills'),
  experience('Experience'),
  projects('Projects'),
  education('Education'),
  contact('Contact');

  const SectionId(this.label);

  final String label;
}
