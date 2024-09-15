// Module1/lesson2.dart
import 'package:flutter/material.dart';
import 'package:modules/Modules/Model/mod3les5.dart';
import 'package:modules/Modules/Module3/lesson5Quiz.dart';

class Lesson5Screen extends StatelessWidget {
  const Lesson5Screen({super.key});

  @override
  Widget build(BuildContext context) {
    final lesson = Lesson5.getLesson5();

    return Scaffold(
      appBar: AppBar(
        title: Center( 
          child: Text(
            lesson.title,
            style: TextStyles.appBarTitle, 
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  padding: EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    color: Colors.blueAccent, 
                    borderRadius: BorderRadius.circular(10), 
                  ),
                  child: Text(
                    lesson.title,
                    style: TextStyles.title, 
                  ),
                ),
              ),
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.all(16.0), 
                decoration: BoxDecoration(
                  color: Colors.white, 
                  borderRadius: BorderRadius.circular(8.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1), 
                      blurRadius: 5, 
                      offset: Offset(0, 2), 
                    ),
                  ],
                ),
                child: _buildContentText(lesson.content),
              ),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
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
                  child: Text('Take Quiz',
                  style: TextStyle(
                    color: Colors.white
                  ),),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    backgroundColor: Colors.blueAccent, 
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8), 
                    ),
                    textStyle: TextStyle(fontSize: 16,
                   ), 
                  ),
                ),
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
            style: TextStyles.boldContent,
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
        style: TextStyles.content,
      ),
    );
  }
}

class TextStyles {
  static const appBarTitle = TextStyle(fontSize: 20, fontWeight: FontWeight.bold); 
  static const title = TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white); 
  static const content = TextStyle(fontSize: 16, color: Colors.black);
  static const boldContent = TextStyle(fontWeight: FontWeight.bold);
}
