
import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../models/study_session.dart';
import '../widgets/session_card.dart';
import 'add_update_session_screen.dart';
import 'session_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  List<StudySession> sessions = [];

  int currentPage = 1;
  int totalRecords = 0;

  // Bulk selection
  bool isSelectionMode = false;
  Set<int> selectedSessionIds = {};

  final int recordsPerPage = 10;

  bool isLoading = true;
  String errorMessage = '';

  // Load study sessions from SQLite
  Future<void> loadSessions() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      int count = await DatabaseHelper.instance.getSessionCount();

      int totalPages = (count / recordsPerPage).ceil();

      // Keep the page within the valid range
      if (totalPages == 0) {
        currentPage = 1;
      } else if (currentPage > totalPages) {
        currentPage = totalPages;
      }

      List<StudySession> data =
          await DatabaseHelper.instance.getSessions(
        recordsPerPage,
        (currentPage - 1) * recordsPerPage,
      );

      if (!mounted) return;

      setState(() {
        totalRecords = count;
        sessions = data;
        isLoading = false;
      });

    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = 'Unable to load study sessions.';
      });
    }
  }

  // Open add session screen
  Future<void> addSession() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddSessionScreen(),
      ),
    );

    if (result == true) {
      currentPage = 1;
      loadSessions();
    }
  }

  // Open session details
  Future<void> openDetails(StudySession session) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            SessionDetailsScreen(session: session),
      ),
    );

    if (result == true) {
      loadSessions();
    }
  }

  // Delete session after confirmation
  Future<void> confirmDelete(StudySession session) async {

    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Session?'),
        content: Text(
          'Are you sure you want to delete "${session.title}"?',
        ),
        actions: [

          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),

          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await DatabaseHelper.instance.deleteSession(session.id!);

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Session deleted successfully!'),
          ),
        );

        loadSessions();

      } catch (e) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to delete session.'),
          ),
        );
      }
    }
  }

  // Enter selection mode
  void startSelection() {
    setState(() {
      isSelectionMode = true;
      selectedSessionIds.clear();
    });
  }

// Cancel selection mode
  void cancelSelection() {
    setState(() {
      isSelectionMode = false;
      selectedSessionIds.clear();
    });
  }

// Select or deselect a session
  void toggleSelection(int id) {
    setState(() {
      if (selectedSessionIds.contains(id)) {
        selectedSessionIds.remove(id);
      } else {
        selectedSessionIds.add(id);
      }
    });
  }

  // Select all sessions across every page
  Future<void> selectAllSessions() async {
    try {
      final ids = await DatabaseHelper.instance.getAllSessionIds();

      if (!mounted) return;

      setState(() {
        selectedSessionIds = ids.toSet();
      });

    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to select all sessions.'),
        ),
      );
    }
  }

  // Delete all selected sessions
  Future<void> deleteSelectedSessions() async {
    if (selectedSessionIds.isEmpty) return;

    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Selected Sessions?'),
        content: Text(
          'Are you sure you want to delete '
              '${selectedSessionIds.length} selected sessions?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await DatabaseHelper.instance.deleteMultipleSessions(
          selectedSessionIds.toList(),
        );

        if (!mounted) return;

        setState(() {
          selectedSessionIds.clear();
          isSelectionMode = false;
        });

        await loadSessions();

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Selected sessions deleted successfully!'),
          ),
        );
      } catch (e) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to delete selected sessions.'),
          ),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    loadSessions();
  }

  @override
  Widget build(BuildContext context) {

    int totalPages = (totalRecords / recordsPerPage).ceil();

    return Scaffold(

      appBar: AppBar(
        centerTitle: false,
        title: const Text(
          'StudyTrack',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),

        actions: [
          if (!isSelectionMode)
            TextButton(
              onPressed: startSelection,
              child: const Text(
                'Select',
                style: TextStyle(
                  color: Colors.deepPurple,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

          if (isSelectionMode) ...[
            IconButton(
              icon: const Icon(Icons.select_all),
              tooltip: 'Select All',
              onPressed: selectAllSessions,
            ),

            IconButton(
              icon: const Icon(Icons.close),
              tooltip: 'Cancel Selection',
              onPressed: cancelSelection,
            ),
          ],

          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: loadSessions,
          ),
        ],
      ),

      body: Column(
        children: [

          // Welcome section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            color: const Color(0xFFE6DCFF),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                const Text(
                  'Hello, Student! 👋',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),

                const SizedBox(height: 5),

                const Text(
                  'Keep track of your learning journey.',
                  style: TextStyle(fontSize: 14),
                ),

                const SizedBox(height: 15),

                Text(
                  'Total Study Sessions: $totalRecords',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.deepPurple,
                  ),
                ),
              ],
            ),
          ),

          // Bulk selection toolbar
          if (isSelectionMode)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              color: const Color(0xFFF1ECFF),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${selectedSessionIds.length} selected',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),

                  ElevatedButton.icon(
                    onPressed: selectedSessionIds.isEmpty
                        ? null
                        : deleteSelectedSessions,
                    icon: const Icon(Icons.delete),
                    label: const Text('Delete Selected'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

          // Section title
          const Padding(
            padding: EdgeInsets.all(16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'My Study Sessions',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // Session list
          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )

                : errorMessage.isNotEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(errorMessage),
                            ElevatedButton(
                              onPressed: loadSessions,
                              child: const Text('Try Again'),
                            ),
                          ],
                        ),
                      )

                    : sessions.isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [

                                Icon(
                                  Icons.menu_book_outlined,
                                  size: 70,
                                  color: Colors.deepPurple,
                                ),

                                SizedBox(height: 15),

                                Text(
                                  'No study sessions yet!',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                SizedBox(height: 5),

                                Text(
                                  'Tap + to add your first session.',
                                  style: TextStyle(
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          )

                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                            ),
                            itemCount: sessions.length,

                            itemBuilder: (context, index) {
                              final session = sessions[index];

                              return Row(
                                children: [
                                  if (isSelectionMode)
                                    Checkbox(
                                      value: selectedSessionIds.contains(session.id),
                                      activeColor: Colors.deepPurple,
                                      onChanged: (value) {
                                        toggleSelection(session.id!);
                                      },
                                    ),

                                  Expanded(
                                    child: SessionCard(
                                      session: session,

                                      onTap: () {
                                        if (isSelectionMode) {
                                          toggleSelection(session.id!);
                                        } else {
                                          openDetails(session);
                                        }
                                      },

                                      onLongPress: () {
                                        if (!isSelectionMode) {
                                          confirmDelete(session);
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
          ),

          // Add session button above pagination
          if (!isSelectionMode)
            Padding(
              padding: const EdgeInsets.only(
                right: 16,
                bottom: 10,
              ),
              child: Align(
                alignment: Alignment.centerRight,
                child: FloatingActionButton(
                  heroTag: 'addSessionButton',
                  onPressed: addSession,
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  child: const Icon(Icons.add),
                ),
              ),
            ),

          // Bottom pagination
          Container(
            padding: const EdgeInsets.all(12),
            color: const Color(0xFFE6DCFF),

            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [

                ElevatedButton(
                  onPressed: currentPage > 1 && !isLoading
                      ? () {
                          setState(() {
                            currentPage--;
                          });
                          loadSessions();
                        }
                      : null,

                  child: const Text('Previous'),
                ),

                Text(
                  totalPages == 0
                      ? 'Page 0 of 0'
                      : 'Page $currentPage of $totalPages',

                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                ElevatedButton(
                  onPressed: currentPage < totalPages && !isLoading
                      ? () {
                          setState(() {
                            currentPage++;
                          });
                          loadSessions();
                        }
                      : null,

                  child: const Text('Next'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}