/// Build-time configuration for optional external services.
///
/// Supply the Listen Notes key with:
/// `flutter run --dart-define=LISTEN_NOTES_API_KEY=<key>`
const environment = <String, String>{
  'apiKey': String.fromEnvironment('LISTEN_NOTES_API_KEY'),
};
