import 'browser_url_sanitizer_stub.dart'
    if (dart.library.html) 'browser_url_sanitizer_web.dart'
    as implementation;

void replaceCurrentBrowserUrl(String path) {
  implementation.replaceCurrentBrowserUrl(path);
}
