import 'checklist.dart';

/// Everything the app persists, stored as one JSON blob.
class AppData {
  List<Checklist> checklists;

  AppData({required this.checklists});

  factory AppData.empty() => AppData(checklists: []);

  factory AppData.fromJson(Map<String, dynamic> json) => AppData(
    checklists: (json['checklists'] as List<dynamic>? ?? [])
        .map((c) => Checklist.fromJson(c as Map<String, dynamic>))
        .toList(),
  );

  Map<String, dynamic> toJson() => {
    'checklists': checklists.map((c) => c.toJson()).toList(),
  };
}
