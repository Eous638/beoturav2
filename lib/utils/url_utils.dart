
/// Utility function to replace `localhost` with `http://88.99.137.223/` in URLs.
String replaceLocalhost(String url) {
  final regex = RegExp(r'^http://localhost');
  return url.replaceAll(regex, 'http://88.99.137.223');
}
