class EmployeeProfile {
  final String iin;
  final String tableNumber;
  final String position;
  final String brigade;
  final String branch;
  final String phone;
  final String fullName;
  final String? s3Photo;

  EmployeeProfile({
    required this.iin,
    required this.tableNumber,
    required this.position,
    required this.brigade,
    required this.branch,
    required this.phone,
    required this.fullName,
    this.s3Photo,
  });

  static String _s(dynamic v) {
    final str = v?.toString() ?? '';
    return str.trim().isEmpty ? '-' : str;
  }

  static String? _sOpt(dynamic v) {
    final str = v?.toString() ?? '';
    final trimmed = str.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  factory EmployeeProfile.fromJson(Map<String, dynamic> j) {
    final userPos =
        (j['user'] is Map) ? (j['user'] as Map)['positionName'] : null;

    final teamMap = j['team'] is Map ? (j['team'] as Map) : null;
    final teamName = teamMap?['name'];

    final deptMap = j['department'] is Map ? (j['department'] as Map) : null;

    final branch = deptMap?['name'];

    final brigade = teamName;

    final position = userPos;

    final userFullName = (j['user'] is Map) ? (j['user'] as Map)['fullName'] : null;
    final lastName = j['lastName'];
    final firstName = j['firstName'];
    final fatherName = j['fatherName'];

    final builtName = [lastName, firstName, fatherName]
        .where((e) => e != null && e.toString().trim().isNotEmpty)
        .map((e) => e.toString().trim())
        .join(' ');

    final fullName = (userFullName == null || userFullName.toString().trim().isEmpty)
        ? builtName
        : userFullName;

    return EmployeeProfile(
      iin: _s(j['iin']),
      tableNumber: _s(j['tableNumber']),
      position: _s(position),
      brigade: _s(brigade),
      branch: _s(branch),
      phone: _s(j['phone']),
      fullName: _s(fullName),
      s3Photo: _sOpt(j['s3Photo']),
    );
  }
}