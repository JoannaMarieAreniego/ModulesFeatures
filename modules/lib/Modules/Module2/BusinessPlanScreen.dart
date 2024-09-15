import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modules/Modules/Model/mod2Exam.dart';
import 'package:modules/Modules/Module2/ExamScreen.dart';
import 'package:modules/Modules/Module2/lesson1.dart';
import 'package:modules/Modules/Module2/lesson2.dart';
import 'package:modules/Modules/Module2/lesson3.dart';
import 'package:modules/Modules/Module2/lesson4.dart';
import 'package:modules/Modules/Module2/lesson5.dart';

class BusinessPlanScreen extends StatefulWidget {
  const BusinessPlanScreen({super.key});

  @override
  _BusinessPlanScreenState createState() => _BusinessPlanScreenState();
}

class _BusinessPlanScreenState extends State<BusinessPlanScreen> {
  bool lesson2Unlocked = false;
  bool lesson3Unlocked = false;
  bool lesson4Unlocked = false;
  bool lesson5Unlocked = false;
  bool examStarted = false;

  @override
  void initState() {
    super.initState();
    _fetchProgress();
  }

  Future<void> _fetchProgress() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        print("No user is currently signed in!");
        return;
      }

      String uid = currentUser.uid;
      DocumentReference progressDocRef =
          FirebaseFirestore.instance.collection('module2_progress').doc(uid);

      DocumentSnapshot progressSnapshot = await progressDocRef.get();

      if (!progressSnapshot.exists) {
        await progressDocRef.set({
          '1Start': true,
          '1Score': 0,
          '1Complete': false,
          '2Start': false,
          '2Complete': false,
          '2Score': 0,
          '3Start': false,
          '3Complete': false,
          '3Score': 0,
          '4Start': false,
          '4Complete': false,
          '4Score': 0,
          '5Start': false,
          '5Complete': false,
          '5Score': 0,
          'ExamStart': false,
          'ExamComplete': false,
          'ExamScore': 0,
        });

        print("Created new document for UID $uid with default values.");
        progressSnapshot = await progressDocRef.get();
      }

      bool lesson1Complete = progressSnapshot['1Complete'] ?? false;
      int lesson1Score = progressSnapshot['1Score'] ?? 0;
      bool lesson2Start = progressSnapshot['2Start'] ?? false;
      bool lesson2Complete = progressSnapshot['2Complete'] ?? false;
      int lesson2Score = progressSnapshot['2Score'] ?? 0;
      bool lesson3Start = progressSnapshot['3Start'] ?? false;
      bool lesson3Complete = progressSnapshot['3Complete'] ?? false;
      int lesson3Score = progressSnapshot['3Score'] ?? 0;
      bool lesson4Start = progressSnapshot['4Start'] ?? false;
      bool lesson4Complete = progressSnapshot['4Complete'] ?? false;
      int lesson4Score = progressSnapshot['4Score'] ?? 0;
      bool lesson5Start = progressSnapshot['5Start'] ?? false;
      bool lesson5Complete = progressSnapshot['5Complete'] ?? false;
      int lesson5Score = progressSnapshot['5Score'] ?? 0;
      bool examStart = progressSnapshot['ExamStart'] ?? false;
      bool examComplete = progressSnapshot['ExamComplete'] ?? false;

      if (lesson1Complete && lesson1Score >= 8 && !lesson2Start) {
        await progressDocRef.update({'2Start': true});
        lesson2Start = true;
      }

      if (lesson2Complete && lesson2Score >= 8 && !lesson3Start) {
        await progressDocRef.update({'3Start': true});
        lesson3Start = true;
      }

      if (lesson3Complete && lesson3Score >= 8 && !lesson4Start) {
        await progressDocRef.update({'4Start': true});
        lesson4Start = true;
      }

      if (lesson4Complete && lesson4Score >= 8 && !lesson5Start) {
        await progressDocRef.update({'5Start': true});
        lesson5Start = true;
      }

      if (lesson5Complete && lesson5Score >= 8 && !examStart) {
        await progressDocRef.update({'ExamStart': true});
        examStart = true;
      }

      setState(() {
        lesson2Unlocked = lesson2Start;
        lesson3Unlocked = lesson3Start;
        lesson4Unlocked = lesson4Start;
        lesson5Unlocked = lesson5Start;
        examStarted = examStart;
      });

      print("Progress data fetched and UI updated.");
    } catch (e) {
      print("Error fetching progress: $e");
    }
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('Module 2: Business Plan Development'),
    ),
    body: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Colors.blueAccent, Colors.purpleAccent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding: EdgeInsets.all(20),
                child: const Icon(
                  Icons.lightbulb_outline,
                  size: 100,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Business Plan Development',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'This module consists of several lessons to help you understand how to develop a comprehensive business plan. '
              'Complete each lesson before proceeding to the Q&A section at the end.',
              style: TextStyle(
                fontSize: 16,
              ),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 20),

            _buildLessonButton(context, 'Lesson 1: Defining Your Business Model',
                () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Lesson1Screen()),
              );
            }, true),
            _buildLessonButton(context, 'Lesson 2: Market Research and Analysis',
                () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Lesson2Screen()),
              );
            }, lesson2Unlocked),
            _buildLessonButton(context, 'Lesson 3: Financial Planning',
                () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Lesson3Screen()),
              );
            }, lesson3Unlocked),
            _buildLessonButton(context, 'Lesson 4: Business Operations Plan',
                () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Lesson4Screen()),
              );
            }, lesson4Unlocked),
            _buildLessonButton(context, 'Lesson 5: Writing Your Business Plan',
                () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Lesson5Screen()),
              );
            }, lesson5Unlocked),
            const SizedBox(height: 20),
            // Exam Button
            Center(
              child: ElevatedButton(
                onPressed: examStarted
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ExamScreen(
                              examQuestions: examQuestions,
                            ),
                          ),
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: examStarted
                      ? Colors.purple
                      : Colors.grey, // Purple when unlocked, grey when locked
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  textStyle: TextStyle(
                    fontSize: 18,
                  ),
                ),
                child: Text(
                  'Start Exam',
                  style: TextStyle(
                    color: examStarted
                        ? Colors.white
                        : Colors.grey, // White text on purple, grey on disabled
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    ),
  );
}

Widget _buildLessonButton(BuildContext context, String lessonTitle,
    VoidCallback? onTap, bool isUnlocked) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 10.0),
    child: OutlinedButton(
      onPressed: isUnlocked ? onTap : null,
      style: OutlinedButton.styleFrom(
        side: BorderSide(
          color: isUnlocked
              ? Colors.purple
              : Colors.grey,
          width: 0.5,
        ),
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 30), // Adjusted padding
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        textStyle: TextStyle(
            fontSize: 18, color: isUnlocked ? Colors.black : Colors.grey),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              lessonTitle,
              style: TextStyle(color: isUnlocked ? Colors.black : Colors.grey),
            ),
          ),
          if (!isUnlocked)
            Icon(
              Icons.lock,
              color: Colors.grey,
            ),
        ],
      ),
    ),
  );
}

}
