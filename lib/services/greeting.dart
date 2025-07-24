import 'dart:math';

String generateGreeting() {
  final hour = DateTime.now().hour;
  String greeting;

  if (hour < 12) {
    greeting = 'Good morning';
  } else if (hour < 17) {
    greeting = 'Good afternoon';
  } else {
    greeting = 'Good evening';
  }

  List<String> phrases = [
    'How are you?',
    'What’s up?',
    'Hope you’re doing well!',
    'How’s it going?',
    'Have a great day!',
    'How are things?',
  ];

  var random = Random();
  String randomPhrase = phrases[random.nextInt(phrases.length)];

  return '$greeting. $randomPhrase';
}
