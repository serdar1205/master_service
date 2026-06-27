/// Prepares CMS/API HTML for [flutter_html] by removing inline styles that
/// can crash the CSS parser (e.g. invalid font-feature-settings values).
String sanitizeHtmlForDisplay(String html) {
  var sanitized = html;

  sanitized = sanitized.replaceAll(
    RegExp(r'<style[^>]*>[\s\S]*?</style>', caseSensitive: false),
    '',
  );

  sanitized = sanitized.replaceAll(
    RegExp(r'\sstyle="[^"]*"', caseSensitive: false),
    '',
  );

  sanitized = sanitized.replaceAll(
    RegExp(r"\sstyle='[^']*'", caseSensitive: false),
    '',
  );

  return sanitized.trim();
}
