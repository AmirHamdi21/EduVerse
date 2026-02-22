// IT Admin Search Models

class ITSearchResult {
  final String id;
  final String title;
  final String subtitle;
  final String type;
  final String status;
  final String? timestamp;
  final Map<String, dynamic>? metadata;

  ITSearchResult({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.type,
    this.status = 'active',
    this.timestamp,
    this.metadata,
  });
}

class ITSearchCategory {
  final String id;
  final String label;
  final int count;

  ITSearchCategory({
    required this.id,
    required this.label,
    required this.count,
  });
}
