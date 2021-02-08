class Podatek {
  int day;
  int month;
  int year;
  int performedTests;
  int positiveTests;
  int deceased;
  int inHospital;
  int inICU;
  int outOfHospital;

  Podatek(int day, int month, int year, int performedTests, int positiveTests,
      int deceased, int inHospital, int inICU, int outOfHospital) {
    this.day = day;
    this.month = month;
    this.year = year;
    this.performedTests = performedTests;
    this.positiveTests = positiveTests;
    this.deceased = deceased;
    this.inHospital = inHospital;
    this.inICU = inICU;
    this.outOfHospital = outOfHospital;
  }

  Podatek.fromJson(Map json)
      : day = json['day'],
        month = json['month'],
        year = json['year'],
        performedTests = json['performedTests'],
        positiveTests = json['cases']['confirmedToday'],
        deceased = json['statePerTreatment']['deceased'],
        inHospital = json['statePerTreatment']['inHospital'],
        inICU = json['statePerTreatment']['inICU'],
        outOfHospital = json['statePerTreatment']['outOfHospital'];
}
