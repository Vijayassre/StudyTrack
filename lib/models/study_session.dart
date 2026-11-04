
class StudySession {
  int? id;
  String title;
  String subject;
  String studyType;
  String studyDate;
  int duration;
  String notes;
  String createdAt;

  StudySession({
    this.id,
    required this.title,
    required this.subject,
    required this.studyType,
    required this.studyDate,
    required this.duration,
    required this.notes,
    required this.createdAt,
  });

  // Convert study session into a Map for SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'subject': subject,
      'study_type': studyType,
      'study_date': studyDate,
      'duration': duration,
      'notes': notes,
      'created_at': createdAt,
    };
  }

  // Convert SQLite Map into a study session
  factory StudySession.fromMap(Map<String, dynamic> map) {
    return StudySession(
      id: map['id'],
      title: map['title'],
      subject: map['subject'],
      studyType: map['study_type'],
      studyDate: map['study_date'],
      duration: map['duration'],
      notes: map['notes'],
      createdAt: map['created_at'],
    );
  }
}
