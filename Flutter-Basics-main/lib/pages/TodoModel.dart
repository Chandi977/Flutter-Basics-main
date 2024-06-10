class TodoModel {
  String title;
  String notes;

  TodoModel({required this.title, this.notes = ''});

  // Convert a TodoModel into a Map.
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'notes': notes,
    };
  }

  // Convert a Map into a TodoModel.
  factory TodoModel.fromMap(Map<String, dynamic> map) {
    return TodoModel(
      title: map['title'],
      notes: map['notes'],
    );
  }
}
