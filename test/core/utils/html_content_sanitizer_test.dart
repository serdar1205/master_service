import 'package:flutter_test/flutter_test.dart';
import 'package:master_service/core/utils/html_content_sanitizer.dart';

void main() {
  test('sanitizeHtmlForDisplay removes inline style attributes', () {
    const html =
        '<h1 style="font-feature-settings: liga 0;">Title</h1>'
        '<p style="color: red;">Body</p>';

    expect(sanitizeHtmlForDisplay(html), '<h1>Title</h1><p>Body</p>');
  });

  test('sanitizeHtmlForDisplay removes style blocks', () {
    const html =
        '<style>p { font-feature-settings: "liga" off; }</style>'
        '<p>Body</p>';

    expect(sanitizeHtmlForDisplay(html), '<p>Body</p>');
  });
}
