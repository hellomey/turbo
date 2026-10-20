/// The 18+ gate (§17.1 step 1). Age is counted on the calendar date in India (IST, UTC+05:30, §37),
/// whatever time zone the phone is set to.
abstract final class AgeGate {
  static const minimumAge = 18;
  static const istOffset = Duration(hours: 5, minutes: 30);

  /// Shown exactly (also the server's `UNDER_18` message).
  static const under18Message =
      'HeyMey is for 18+. See you on your 18th birthday.';

  /// Today's calendar date in IST.
  static DateTime istToday(DateTime now) {
    final ist = now.toUtc().add(istOffset);
    return DateTime(ist.year, ist.month, ist.day);
  }

  /// Whole years between [dateOfBirth] and [today] (both calendar dates).
  static int ageOn(DateTime dateOfBirth, DateTime today) {
    var age = today.year - dateOfBirth.year;
    final beforeBirthday =
        today.month < dateOfBirth.month ||
        (today.month == dateOfBirth.month && today.day < dateOfBirth.day);
    if (beforeBirthday) age--;
    return age;
  }

  static bool isAdult(DateTime dateOfBirth, DateTime now) =>
      ageOn(dateOfBirth, istToday(now)) >= minimumAge;

  /// True when day/month/year form a real calendar date.
  static bool isRealDate(int year, int month, int day) {
    final d = DateTime(year, month, day);
    return d.year == year && d.month == month && d.day == day;
  }
}
