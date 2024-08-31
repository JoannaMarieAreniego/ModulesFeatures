// Module1/lesson2.dart
import 'package:flutter/material.dart';
import 'package:modules/Modules/Model/mod1les5.dart';
import 'package:modules/Modules/Module1/lesson5Quiz.dart';

class Lesson5Screen extends StatelessWidget {
  const Lesson5Screen({super.key});

  @override
  Widget build(BuildContext context) {
    final lesson = Lesson5.getLesson5();

    return Scaffold(
      appBar: AppBar(
        title: Text(lesson.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                lesson.title,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              _buildContentText(lesson.content),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => QuizScreen5(
                        quizQuestions: lesson.quizQuestions,
                      ),
                    ),
                  );
                },
                child: Text('Take Quiz'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContentText(String content) {
    final lines = content.split('\n');
    List<InlineSpan> spans = [];
    
    for (var line in lines) {
      final parts = line.split('*');
      for (int i = 0; i < parts.length; i++) {
        if (i % 2 == 1) {
          spans.add(TextSpan(
            text: parts[i],
            style: TextStyle(fontWeight: FontWeight.bold),
          ));
        } else {
          spans.add(TextSpan(text: parts[i]));
        }
      }
      spans.add(TextSpan(text: '\n'));
    }

    return RichText(
      text: TextSpan(
        children: spans,
        style: TextStyle(fontSize: 16, color: Colors.black),
      ),
    );
  }
}
