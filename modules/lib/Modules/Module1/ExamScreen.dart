//Module1/ExamScreen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:modules/Modules/Model/lesson_model.dart';
import 'package:modules/Modules/moduleHome.dart';

class ExamScreen extends StatefulWidget {
  final List<ExamQuestions> examQuestions;

  const ExamScreen({required this.examQuestions, Key? key}) : super(key: key);

  @override
  _ExamScreenState createState() => _ExamScreenState();
}

class _ExamScreenState extends State<ExamScreen> {
  final Map<int, String?> _answers = {};
  int? _score;
  bool _showAnswers = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Exam'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _score == null
            ? ListView.builder(
                itemCount: widget.examQuestions.length,
                itemBuilder: (context, index) {
                  final question = widget.examQuestions[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 10),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            question.examquestion ?? '',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 10),
                          if (question.examoptions != null) ...[
                            ...question.examoptions!.map(
                              (option) => RadioListTile<String>(
                                title: Text(option),
                                value: option,
                                groupValue: _answers[index],
                                onChanged: (value) {
                                  setState(() {
                                    _answers[index] = value;
                                  });
                                },
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              )
            : _buildAnswersView(),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: _score == null
              ? _submitExam
              : () {
                  Navigator.pop(context); // Close the exam screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ModuleHomeScreen()),
                  ); // Navigate to ModuleHomeScreen
                },
          child: Text(_score == null ? 'Submit' : 'Close'),
        ),
      ),
    );
  }

  Widget _buildAnswersView() {
    return ListView.builder(
      itemCount: widget.examQuestions.length,
      itemBuilder: (context, index) {
        final question = widget.examQuestions[index];
        final userAnswer = _answers[index];
        final correctAnswer = question.examanswer;

        return Card(
          margin: EdgeInsets.symmetric(vertical: 10),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  question.examquestion ?? '',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text(
                  'Your answer: ${userAnswer ?? 'No answer provided'}',
                  style: TextStyle(
                      color: userAnswer == correctAnswer
                          ? Colors.green
                          : Colors.red),
                ),
                Text(
                  'Correct answer: $correctAnswer',
                  style: TextStyle(color: Colors.blue),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _submitExam() async {
    if (_answers.length != widget.examQuestions.length) {
      // If not all questions have been answered
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Please answer all questions before submitting.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
      return;
    }

    int score = 0;

    for (int i = 0; i < widget.examQuestions.length; i++) {
      final question = widget.examQuestions[i];
      if (_answers[i] == question.examanswer) {
        score++;
      }
    }

    setState(() {
      _score = score;
      _showAnswers = true;
    });

    await _updateUserProgress(score);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Exam Result'),
          content: Text(
              'Your score is $_score out of ${widget.examQuestions.length}'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _showAnswers = true;
                });
              },
              child: Text('View Answers'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ModuleHomeScreen()),
                );
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateUserProgress(int score) async {
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      print("No user is currently signed in!");
      return;
    }

    String uid = currentUser.uid;
    DocumentReference progressDocRef =
        FirebaseFirestore.instance.collection('user_lesson_progress').doc(uid);

    DocumentSnapshot progressSnapshot = await progressDocRef.get();

    // Create a map for updates
    Map<String, dynamic> updates = {};

    if (progressSnapshot.exists) {
      int currentExamScore = progressSnapshot['ExamScore'] ?? 0;
      bool currentExamComplete = progressSnapshot['ExamComplete'] ?? false;

      // Debugging prints
      print("Current Exam Score: $currentExamScore");
      print("Current Exam Complete: $currentExamComplete");

      // Update score if it's higher
      if (score > currentExamScore) {
        updates['ExamScore'] = score;
      }

      // Ensure ExamComplete is set correctly
      if (score >= 20) { // Assuming passing score is 20
        if (!currentExamComplete) {
          updates['ExamComplete'] = true;
          print("Setting ExamComplete to true");
        }
      }
    } else {
      // Document does not exist, create with initial values
      updates = {
        'ExamScore': score,
        'ExamComplete': score >= 20, // Assuming passing score is 20
      };

      print("Creating new document with initial values");
    }

    // Apply updates
    if (updates.isNotEmpty) {
      try {
        await progressDocRef.update(updates);
        print("Document updated with: $updates");

        await Future.delayed(Duration(seconds: 1));
        DocumentSnapshot refreshedSnapshot = await progressDocRef.get();
        print("Refreshed Document Data: ${refreshedSnapshot.data()}");
      } catch (e) {
        print("Error updating document: $e");
      }
    }
  }
}
