/// Thrown when the Dart API on [ApiConfig.baseUrl] cannot be reached.
class ApiUnavailableException implements Exception {
  ApiUnavailableException([this.message = _defaultMessage]);

  static const _defaultMessage =
      'Cannot reach the E-Archive API at http://127.0.0.1:8080.\n\n'
      'The app starts the API automatically. For a release build, run '
      'build_release.bat once so api\\bin\\server.exe sits next to e_archive.exe.\n\n'
      'Otherwise start it manually:\n'
      '1. Double-click run_api_server.bat in the E-Archive folder\n'
      '2. Leave that window open, then click Retry here\n\n'
      'To test: open http://127.0.0.1:8080/api/health in your browser';

  final String message;

  @override
  String toString() => message;
}
