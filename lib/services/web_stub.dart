class WebStorage {
  static final Map<String, String> _stubMap = {};
  static Map<String, String> get localStorage => _stubMap;
}

void openWebFilePicker(void Function(String?) onFilePicked) {
  onFilePicked(null);
}
