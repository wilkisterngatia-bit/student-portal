class LibraryResource {
  final String title;
  final String unit;
  final String type;
  final String sizeLabel;

  const LibraryResource({
    required this.title,
    required this.unit,
    required this.type,
    required this.sizeLabel,
  });
}

class LibraryData {
  LibraryData._();

  static const List<LibraryResource> resources = [
    LibraryResource(title: 'Mobile App Dev — Lecture Notes Wk 1-6', unit: 'BIT 4107', type: 'Notes', sizeLabel: '2.4 MB'),
    LibraryResource(title: 'Mobile App Dev — Past Paper 2025', unit: 'BIT 4107', type: 'Past Paper', sizeLabel: '850 KB'),
    LibraryResource(title: 'Networking Fundamentals Slides', unit: 'BIT 4102', type: 'Slides', sizeLabel: '5.1 MB'),
    LibraryResource(title: 'Database Systems eBook', unit: 'BIT 4105', type: 'eBook', sizeLabel: '12.3 MB'),
    LibraryResource(title: 'Software Engineering Case Studies', unit: 'BIT 4108', type: 'Notes', sizeLabel: '1.8 MB'),
    LibraryResource(title: 'Systems Analysis Past Paper 2024', unit: 'BIT 4109', type: 'Past Paper', sizeLabel: '690 KB'),
  ];

  static List<String> get units =>
      resources.map((r) => r.unit).toSet().toList()..sort();
}
