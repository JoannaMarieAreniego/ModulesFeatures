import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:modules/Modules/Model/lesson_model.dart';
import 'package:modules/Modules/moduleHome.dart';

class QuizScreen extends StatefulWidget {
  final List<QuizQuestion> quizQuestions;

  const QuizScreen({required this.quizQuestions, super.key});

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final Map<int, String?> _answers = {};
  int? _score;
  bool _showAnswers = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent, 
        iconTheme: IconThemeData(
          color: Colors.white
        ),
        title: Text('Lesson 1 Quiz'),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 24
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: _score == null
            ? ListView.builder(
                itemCount: widget.quizQuestions.length,
                itemBuilder: (context, index) {
                  final question = widget.quizQuestions[index];
                  return _buildQuestionCard(index, question);
                },
              )
            : _buildAnswersView(),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: _score == null ? _submitQuiz : _closeQuiz,
          style: ElevatedButton.styleFrom(
            backgroundColor:  Colors.blueAccent, 
          ),
          child: Text(_score == null ? 'Submit' : 'Close',
          style: TextStyle(color: Colors.white),),
        ),
      ),
    );
  }

  Widget _buildQuestionCard(int index, QuizQuestion question) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Question ${index + 1}/${widget.quizQuestions.length}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade700, 
              ),
            ),
            SizedBox(height: 10),
            Text(
              question.question,
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 15),
            Column(
              children: question.options!.map((option) {
                final isSelected = _answers[index] == option;
                final isCorrect = question.answer == option;
                return Container(
                  margin: EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                      color: isSelected
                          ? (isCorrect ? Colors.green : Colors.red)
                          : Colors.blue.shade300,
                      width: 1,
                    ),
                    color: _showAnswers
                        ? (isCorrect
                            ? Colors.green.shade100
                            : isSelected ? Colors.red.shade100 : Colors.white)
                        : Colors.white,
                  ),
                  child: RadioListTile<String>(
                    activeColor: Colors.blue, 
                    title: Row(
                      children: [
                        Expanded(child: Text(option)),
                        if (_showAnswers && isSelected)
                          Icon(
                            isCorrect ? Icons.check : Icons.close,
                            color: isCorrect ? Colors.green : Colors.red,
                          ),
                      ],
                    ),
                    value: option,
                    groupValue: _answers[index],
                    onChanged: (value) {
                      setState(() {
                        _answers[index] = value;
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ],
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
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  question.question,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade800, 
                  ),
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
      _showIncompleteDialog();
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

    await _updateUserProgress(score);
    _showScoreDialog();
  }

  void _showIncompleteDialog() {
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
  }

  void _showScoreDialog() {
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
                _closeQuiz();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _closeQuiz() {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ModuleHomeScreen()),
    );
  }

  Future<void> _updateUserProgress(int score) async {
   
  }
}
