import 'package:flutter/material.dart';
import '../models/question.dart';
import '../services/question_service.dart';
import '../utils/constants.dart';

class QuizScreen extends StatefulWidget {
  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<Question> allQuestions = [];
  List<Question> filteredQuestions = []; // 🔥 NEW
  bool isLoading = true;

  String selectedCategory = "All";
  int currentIndex = 0;
  String? selectedOption;

  bool isAnswered = false; // 🔥 NEW
  bool isCorrect = false; // 🔥 NEW

  List<String> shuffledOptions = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() async {
    allQuestions = await QuestionService.loadQuestions();

    prepareQuestions(); // 🔥 ADD THIS
    prepareOptions(); // ✅ ADD

    setState(() {
      isLoading = false;
    });
  }

  void prepareQuestions() {
    // 🔥 NEW
    if (selectedCategory == "All") {
      filteredQuestions = List.from(allQuestions);
    } else {
      filteredQuestions = allQuestions
          .where((q) => q.category == selectedCategory)
          .toList();
    }

    filteredQuestions.shuffle(); // 🎯 RANDOMIZE ONCE

    currentIndex = 0;

    prepareOptions();
  }

  void prepareOptions(){
    shuffledOptions = List.from(filteredQuestions[currentIndex].options);
      shuffledOptions.shuffle(); // 🔥 THIS LINE WAS MISSING

  }

  List<String> getCategories() {
    return allQuestions.map((q) => q.category).toSet().toList();
  }

  List<Question> getFilteredQuestions() {
    if (selectedCategory == "All") return allQuestions;

    return allQuestions.where((q) => q.category == selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (filteredQuestions.isEmpty) {
      return Scaffold(body: Center(child: Text("No questions available")));
    }

    if (currentIndex >= filteredQuestions.length) {
      return Scaffold(body: Center(child: Text("Quiz Finished")));
    }
    final question = filteredQuestions[currentIndex];

    return Scaffold(
      appBar: AppBar(title: Text("CSEB"), backgroundColor: primaryBlue),

      body: Column(
        children: [
          // 🔹 CATEGORY FILTER
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: ["All", ...getCategories()].map((cat) {
                return Padding(
                  padding: EdgeInsets.all(6),
                  child: ChoiceChip(
                    label: Text(cat),
                    selected: selectedCategory == cat,
                    selectedColor: primaryBlue,
                    onSelected: (_) {
                      setState(() {
                        selectedCategory = cat;
                        currentIndex = 0;
                        selectedOption = null; // 🔥 NEW (reset)
                        isAnswered = false; // 🔥 NEW

                        prepareQuestions(); // 🔥 ADD THIS
                        prepareOptions(); // ✅ ADD
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),

          // 🔹 QUESTION + OPTIONS
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(question.question, style: TextStyle(fontSize: 18)),
                  SizedBox(height: 20),

                  ...shuffledOptions.map((opt) {
                    final isSelected = selectedOption == opt;

                    return GestureDetector(
                      onTap: () {
                        if (isAnswered) return; // 🔥 NEW (lock after confirm)

                        setState(() {
                          selectedOption = opt;
                        });
                      },
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: 6),
                        padding: EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color:
                              isAnswered // 🔄 UPDATED (color logic)
                              ? (opt == question.answer
                                    ? Colors.green
                                    : (opt == selectedOption
                                          ? Colors.red
                                          : Colors.white))
                              : (isSelected ? primaryBlue : Colors.white),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: primaryBlue),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                opt,
                                style: TextStyle(
                                  color: isAnswered
                                      ? (opt == question.answer
                                            ? Colors
                                                  .white // green bg
                                            : (opt == selectedOption
                                                  ? Colors
                                                        .white // red bg
                                                  : Colors
                                                        .black)) // ❗ white bg → black text
                                      : (isSelected
                                            ? Colors.white
                                            : Colors.black),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),

                  // 🔥 NEW → RESULT TEXT
                  if (isAnswered)
                    Column(
                      children: [
                        SizedBox(height: 10),
                        Text(
                          isCorrect ? "✅ Correct!" : "❌ Wrong!",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isCorrect ? Colors.green : Colors.red,
                          ),
                        ),
                        if (!isCorrect)
                          Text(
                            "Correct Answer: ${question.answer}",
                            style: TextStyle(fontSize: 16),
                          ),
                      ],
                    ),
                ],
              ),
            ),
          ),

          // 🔥 UPDATED BUTTON SECTION
          Padding(
            padding: EdgeInsets.all(16),
            child: isAnswered
                // 👉 SHOW NEXT BUTTON AFTER CONFIRM
                ? ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBlue,
                      minimumSize: Size(double.infinity, 50),
                    ),
                    onPressed: () {
                      setState(() {
                        if (currentIndex < filteredQuestions.length - 1) {
                          currentIndex++;
                          selectedOption = null;
                          
                          isAnswered = false;

                          prepareOptions();
                        } else {
                          currentIndex =
                              filteredQuestions.length; // show finished
                        }
                      });
                    },
                    child: Text("Next"),
                  )
                // 👉 SHOW CONFIRM BUTTON BEFORE ANSWER
                : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBlue,
                      minimumSize: Size(double.infinity, 50),
                    ),
                    onPressed: () {
                      if (selectedOption == null) return;

                      setState(() {
                        isAnswered = true;
                        isCorrect = selectedOption == question.answer;
                      });
                    },
                    child: Text("Confirm"),
                  ),
          ),
        ],
      ),
    );
  }
}
