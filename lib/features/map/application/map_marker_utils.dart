String clientInitialFromName(String name) {
  final trimmed = name.trim();
  if (trimmed.isEmpty) {
    return '?';
  }

  final firstName = trimmed.split(RegExp(r'\s+')).first;
  if (firstName.isEmpty) {
    return '?';
  }

  return firstName.substring(0, 1).toUpperCase();
}
