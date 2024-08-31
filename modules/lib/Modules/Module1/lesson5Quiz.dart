import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:modules/Modules/Model/lesson_model.dart';
import 'package:modules/Modules/moduleHome.dart';

class QuizScreen5 extends StatefulWidget {
  final List<QuizQuestion> quizQuestions;

  const QuizScreen5({required this.quizQuestions, super.key});

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen5> {
  final Map<int, String?> _answers = {};
  int? _score;
  bool _showAnswers = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _score == null
            ? ListView.builder(
                itemCount: widget.quizQuestions.length,
                itemBuilder: (context, index) {
                  final question = widget.quizQuestions[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 10),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            question.question,
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 10),
                          if (question.options != null) ...[
                            ...question.options!.map(
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
          ? _submitQuiz 
          : () {
              Navigator.pop(context); // Close the quiz screen
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
      itemCount: widget.quizQuestions.length,
      itemBuilder: (context, index) {
        final question = widget.quizQuestions[index];
        final userAnswer = _answers[index];
        final correctAnswer = question.answer;

        return Card(
          margin: EdgeInsets.symmetric(vertical: 10),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  question.question,
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

  void _submitQuiz() async {
    if (_answers.length != widget.quizQuestions.length) {
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

    for (int i = 0; i < widget.quizQuestions.length; i++) {
      final question = widget.quizQuestions[i];
      if (_answers[i] == question.answer) {
        score++;
      }
    }

    setState(() {
      _score = score;
      _showAnswers = true;
    });

    await _updateUserProgress(score); // Call the method to update progress

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Quiz Result'),
          content: Text(
              'Your score is $_score out of ${widget.quizQuestions.length}'),
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
      int currentLesson5Score = progressSnapshot['5Score'] ?? 0;
      bool currentLesson5Complete = progressSnapshot['5Complete'] ?? false;

      // Debugging prints
      print("Current Lesson 5 Score: $currentLesson5Score");
      print("Current Lesson 5 Complete: $currentLesson5Complete");

      // Update score if it's higher
      if (score > currentLesson5Score) {
        updates['5Score'] = score;
      }

      // Ensure 1Complete is set correctly
      if (score >= 8) {
        if (!currentLesson5Complete) {
          updates['5Complete'] = true;
          print("Setting 5Complete to true");
        }
      }

      // Update 2Start based on 1Complete and score
      bool shouldExamStart = progressSnapshot['5Complete'] == true && score >= 8;
      if (shouldExamStart) {
        updates['ExamStart'] = true;
        print("Setting ExamStart to true");
      }
    } else {
      // Document does not exist, create with initial values
      updates = {
        '5Complete': score >= 8,
        '5Score': score,
        'ExamStart': score >= 8,
        'ExamComplete': false,
        'ExamScore': 0,
      };

      print("Creating new document with initial values");
    }

    // Apply updates
    if (updates.isNotEmpty) {
      try {
        await progressDocRef.update(updates);
        print("Document updated with: $updates");

        await Future.delayed(
            Duration(seconds: 1));
        DocumentSnapshot refreshedSnapshot = await progressDocRef.get();
        print("Refreshed Document Data: ${refreshedSnapshot.data()}");
      } catch (e) {
        print("Error updating document: $e");
      }
    }
  }
}
