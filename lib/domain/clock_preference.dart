/// The 24-hour choice in the server's `use_military_time` preference; null
/// while it isn't set.
bool? clockFrom(String? value) => switch (value) {
  'true' => true,
  'false' => false,
  _ => null,
};
