/// Teammate name display, the `display_settings/name_format` preference.
enum NameFormat {
  username('username', 'Username'),
  nickname('nickname_full_name', 'Nickname, else full name'),
  fullName('full_name', 'Full name');

  const NameFormat(this.value, this.label);
  final String value;
  final String label;

  static NameFormat of(String? value) =>
      values.where((f) => f.value == value).firstOrNull ?? username;
}

/// First and last name with a space between; empty when neither is set.
String fullName(String firstName, String lastName) =>
    '$firstName $lastName'.trim();
