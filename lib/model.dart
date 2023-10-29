class Note {
  final int id;
  final String title;
  final String content;
  final String date;

  const Note({
    required this.id,
    required this.title,
    required this.content,
    required this.date,
  });

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'] as int,
      title: json['title'] as String,
      content: json['content'] as String,
      date: json['updated_at'] as String,
    );
  }
}
