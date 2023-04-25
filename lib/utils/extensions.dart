import 'package:whatspp_direct/utils/countries.dart';

extension CleanNumber on String {
  String cleanNumber() {
    Map<String, String> foundedCountry = {};
    for (var country in Countries.allCountries) {
      String dialCode = country["dial_code"].toString();
      if (contains(dialCode)) {
        foundedCountry = country;
      }
    }

    var newPhoneNumber = '';

    if (foundedCountry.isNotEmpty) {
      var dialCode = substring(
        0,
        foundedCountry["dial_code"]!.length,
      );
      newPhoneNumber = substring(
        foundedCountry["dial_code"]!.length,
      );
      print("----");
      print({dialCode, newPhoneNumber});
    }
    return newPhoneNumber;
  }
}

extension CleanCode on String {
  String cleanCode() {
    Map<String, String> foundedCountry = {};
    for (var country in Countries.allCountries) {
      String dialCode = country["dial_code"].toString();
      if (contains(dialCode)) {
        foundedCountry = country;
      }
    }

    var dialCode = '';

    if (foundedCountry.isNotEmpty) {
      dialCode = substring(
        0,
        foundedCountry["dial_code"]!.length,
      );
    }
    return dialCode;
  }
}

