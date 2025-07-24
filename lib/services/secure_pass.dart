import 'dart:math';

String generateSecurePassword({
  required int length,
  bool includeUpperCase = true,
  bool includeLowerCase = true,
  bool includeNumbers = true,
  bool includeSpecialChars = true,
}) {
  // Define the characters for each category
  const String upperCaseLetters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  const String lowerCaseLetters = 'abcdefghijklmnopqrstuvwxyz';
  const String numbers = '0123456789';
  const String specialCharacters = '!@#\$%^&*()-_=+{}[]|:;<>,.?/~';

  // Initialize all available characters and store them in a list.
  String availableChars = '';
  if (includeUpperCase) availableChars += upperCaseLetters;
  if (includeLowerCase) availableChars += lowerCaseLetters;
  if (includeNumbers) availableChars += numbers;
  if (includeSpecialChars) availableChars += specialCharacters;

  if (availableChars.isEmpty) {
    throw ArgumentError('At least one character category must be selected.');
  }

  final Random random = Random.secure();

  // Function to get a random character from a given set of characters
  String getRandomCharacter(String chars) =>
      chars[random.nextInt(chars.length)];

  // Ensure the password contains at least one character from each selected category
  List<String> passwordParts = [];
  if (includeUpperCase) passwordParts.add(getRandomCharacter(upperCaseLetters));
  if (includeLowerCase) passwordParts.add(getRandomCharacter(lowerCaseLetters));
  if (includeNumbers) passwordParts.add(getRandomCharacter(numbers));
  if (includeSpecialChars)
    passwordParts.add(getRandomCharacter(specialCharacters));

  // Add remaining random characters to meet the required password length
  while (passwordParts.length < length) {
    passwordParts.add(getRandomCharacter(availableChars));
  }

  // Shuffle to randomize character placement and return as a string
  passwordParts.shuffle(random);
  return passwordParts.join();
}
