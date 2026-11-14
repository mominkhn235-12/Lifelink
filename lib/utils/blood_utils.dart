class BloodUtils {
  // Which patient blood groups a donor of each group can give blood to.
  static const Map<String, List<String>> canGiveTo = {
    'O-': ['O-', 'O+', 'A-', 'A+', 'B-', 'B+', 'AB-', 'AB+'],
    'O+': ['O+', 'A+', 'B+', 'AB+'],
    'A-': ['A-', 'A+', 'AB-', 'AB+'],
    'A+': ['A+', 'AB+'],
    'B-': ['B-', 'B+', 'AB-', 'AB+'],
    'B+': ['B+', 'AB+'],
    'AB-': ['AB-', 'AB+'],
    'AB+': ['AB+'],
  };

  static bool canDonate(String donorGroup, String patientGroup) {
    return canGiveTo[donorGroup]?.contains(patientGroup) ?? false;
  }
}