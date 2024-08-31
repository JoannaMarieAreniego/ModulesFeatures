import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:modules/Modules/Model/lesson_model.dart';
import 'package:modules/Modules/moduleHome.dart';

class QuizScreen3 extends StatefulWidget {
  final List<QuizQuestion> quizQuestions;

  const QuizScreen3({required this.quizQuestions, super.key});

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen3> {
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
      int currentLesson3Score = progressSnapshot['3Score'] ?? 0;
      bool currentLesson3Complete = progressSnapshot['3Complete'] ?? false;

      // Debugging prints
      print("Current Lesson 3 Score: $currentLesson3Score");
      print("Current Lesson 3 Complete: $currentLesson3Complete");

      // Update score if it's higher
      if (score > currentLesson3Score) {
        updates['3Score'] = score;
      }

      // Ensure 1Complete is set correctly
      if (score >= 8) {
        if (!currentLesson3Complete) {
          updates['3Complete'] = true;
          print("Setting 2Complete to true");
        }
      }

      // Update 2Start based on 1Complete and score
      bool shouldSet4Start = progressSnapshot['3Complete'] == true && score >= 8;
      if (shouldSet4Start) {
        updates['4Start'] = true;
        print("Setting 4Start to true");
      }
    } else {
      // Document does not exist, create with initial values
      updates = {
        '3Complete': score >= 8,
        '3Score': score,
        '4Start': score >= 8,
        '4Complete': false,
        '4Score': 0,
        '5Start': false,
        '5Complete': false,
        '5Score': 0,
        'ExamStart': false,
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
