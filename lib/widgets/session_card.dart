
import 'package:flutter/material.dart';
import '../models/study_session.dart';

class SessionCard extends StatelessWidget {
  final StudySession session;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const SessionCard({
    super.key,
    required this.session,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 7),

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),

      child: ListTile(
        contentPadding: const EdgeInsets.all(12),

        onTap: onTap,
        onLongPress: onLongPress,

        // Study icon
        leading: const CircleAvatar(
          backgroundColor: Color(0xFFE6DCFF),
          child: Icon(
            Icons.menu_book,
            color: Colors.deepPurple,
          ),
        ),

        // Session title
        title: Text(
          session.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),

        // Subject and study type
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Text('Subject: ${session.subject}'),

              const SizedBox(height: 4),

              Text('Type: ${session.studyType}'),

              const SizedBox(height: 4),

              Text('Date: ${session.studyDate}'),

              const SizedBox(height: 4),

              Text(
                'Duration: ${session.duration} minutes',
                style: const TextStyle(
                  color: Colors.deepPurple,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),

        // Arrow icon
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.deepPurple,
        ),
      ),
    );
  }
}
