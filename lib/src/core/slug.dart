/// Converts a string to a URL/filesystem-safe slug.
///
/// Lowercases and replaces non-alphanumeric characters with underscores.
String slugify(String input) => input.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_');
