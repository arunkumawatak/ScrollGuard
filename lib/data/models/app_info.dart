class AppInfo {
  final String name;
  final String packageName;
  final String iconBase64;

  AppInfo({
    required this.name,
    required this.packageName,
    required this.iconBase64,
  });

  factory AppInfo.fromMap(Map<String, dynamic> map) {
    return AppInfo(
      name: map['name'] ?? 'Unknown',
      packageName: map['packageName'] ?? '',
      iconBase64: map['icon'] ?? '',
    );
  }
}