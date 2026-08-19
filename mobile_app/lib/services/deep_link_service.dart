class DeepLinkService {
  static const String webBaseUrl = 'https://lifeline-42717.web.app';
  static const String appScheme = 'lifeline';

  /// Generates a universal web link that works on both web browsers and inside the mobile app.
  static String createUniversalLink({required String path, Map<String, String>? queryParams}) {
    final uri = Uri.parse('$webBaseUrl$path').replace(queryParameters: queryParams);
    return uri.toString();
  }

  /// Generates a custom app scheme link (e.g. lifeline://open?path=/donor/details)
  static String createAppSchemeLink({required String path, Map<String, String>? queryParams}) {
    final params = Map<String, String>.from(queryParams ?? {});
    params['path'] = path;
    final uri = Uri(scheme: appScheme, host: 'open', queryParameters: params);
    return uri.toString();
  }

  /// Parses incoming web or app links and returns the matching internal app route
  static String? parseIncomingLink(Uri uri) {
    if (uri.scheme == appScheme) {
      return uri.queryParameters['path'];
    } else if (uri.scheme == 'https' || uri.scheme == 'http') {
      return uri.path.isNotEmpty ? uri.path : '/';
    }
    return null;
  }
}
