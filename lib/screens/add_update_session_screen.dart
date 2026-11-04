
import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/study_session.dart';

class AddSessionScreen extends StatefulWidget {
  final StudySession? session;

  const AddSessionScreen({super.key, this.session});

  @override
  State<AddSessionScreen> createState() => _AddSessionScreenState();
}

class _AddSessionScreenState extends State<AddSessionScreen> {

  final _formKey = GlobalKey<FormState>();

  final titleController = TextEditingController();
  final subjectController = TextEditingController();
  final durationController = TextEditingController();
  final notesController = TextEditingController();

  String? selectedType;
  DateTime selectedDate = DateTime.now();

  final List<String> studyTypes = [
    'Assignment',
    'Revision',
    'Reading',
    'Practice',
    'Group Study',
    'Exam Preparation',
    'Other',
  ];

  bool isSaving = false;

  bool get isEditing => widget.session != null;

  @override
  void initState() {
    super.initState();

    // Fill the form when editing a session
    if (isEditing) {
      final session = widget.session!;

      titleController.text = session.title;
      subjectController.text = session.subject;
      durationController.text = session.duration.toString();
      notesController.text = session.notes;
      selectedType = session.studyType;

      selectedDate = DateTime.parse(session.studyDate);
    }
  }

  // Format date
  String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  // Select study date
  Future<void> chooseDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  // Show save confirmation
  Future<void> saveSession() async {

    if (!_formKey.currentState!.validate()) {
      return;
    }

    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? 'Confirm Update' : 'Confirm Save'),
        content: Text(
          isEditing
              ? 'Do you want to update this study session?'
              : 'Do you want to save this study session?',
        ),
        actions: [

          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),

          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    setState(() {
      isSaving = true;
    });

    try {
      final session = StudySession(
        id: widget.session?.id,
        title: titleController.text.trim(),
        subject: subjectController.text.trim(),
        studyType: selectedType!,
        studyDate: selectedDate.toIso8601String(),
        duration: int.parse(durationController.text),
        notes: notesController.text.trim(),
        createdAt: widget.session?.createdAt ??
            DateTime.now().toIso8601String(),
      );

      if (isEditing) {
        await DatabaseHelper.instance.updateSession(session);
      } else {
        await DatabaseHelper.instance.insertSession(session);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEditing
                ? 'Session updated successfully!'
                : 'Session saved successfully!',
          ),
        ),
      );

      Navigator.pop(context, true);

    } catch (e) {
      if (!mounted) return;

      setState(() {
        isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to save session. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    subjectController.dispose();
    durationController.dispose();
    notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        title: Text(isEditing ? 'Edit Session' : 'Add Study Session'),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Form(
          key: _formKey,

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // Session title
              const Text(
                'Session Title *',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              TextFormField(
                controller: titleController,
                decoration: const InputDecoration(
                  hintText: 'Enter session title',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.edit),
                ),

                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a session title';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 18),

              // Subject
              const Text(
                'Subject *',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              TextFormField(
                controller: subjectController,
                decoration: const InputDecoration(
                  hintText: 'Enter subject name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.book),
                ),

                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a subject';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 18),

              // Study type
              const Text(
                'Study Type *',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              DropdownButtonFormField<String>(
                value: selectedType,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                  hintText: 'Select study type',
                ),

                items: studyTypes.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),

                onChanged: (value) {
                  setState(() {
                    selectedType = value;
                  });
                },

                validator: (value) {
                  if (value == null) {
                    return 'Please select a study type';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 18),

              // Study date
              const Text(
                'Study Date *',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              InkWell(
                onTap: chooseDate,

                child: InputDecorator(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_month),
                    suffixIcon: Icon(Icons.arrow_drop_down),
                  ),

                  child: Text(formatDate(selectedDate)),
                ),
              ),

              const SizedBox(height: 18),

              // Duration
              const Text(
                'Duration (Minutes) *',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              TextFormField(
                controller: durationController,
                keyboardType: TextInputType.number,

                decoration: const InputDecoration(
                  hintText: 'Example: 60',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.timer),
                ),

                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter study duration';
                  }

                  int? duration = int.tryParse(value);

                  if (duration == null) {
                    return 'Please enter a valid whole number';
                  }

                  if (duration <= 0) {
                    return 'Duration must be greater than zero';
                  }

                  if (duration > 1440) {
                    return 'Duration cannot exceed 1440 minutes';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 18),

              // Optional notes
              const Text(
                'Notes (Optional)',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              TextFormField(
                controller: notesController,
                maxLines: 3,

                decoration: const InputDecoration(
                  hintText: 'Enter additional notes...',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.notes),
                ),
              ),

              const SizedBox(height: 25),

              // Save button
              SizedBox(
                width: double.infinity,
                height: 50,

                child: ElevatedButton.icon(
                  onPressed: isSaving ? null : saveSession,

                  icon: const Icon(Icons.save),

                  label: Text(
                    isSaving
                        ? 'Saving...'
                        : isEditing
                            ? 'Update Session'
                            : 'Save Session',
                  ),

                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
