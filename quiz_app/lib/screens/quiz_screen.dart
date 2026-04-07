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
  bool isLoading = true;

  String selectedCategory = "All";
  int currentIndex = 0;
  String? selectedOption;

  bool isAnswered = false; // 🔥 NEW
  bool isCorrect = false;  // 🔥 NEW

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() async {
    allQuestions = await QuestionService.loadQuestions();
    setState(() {
      isLoading = false;
    });
  }

  List<String> getCategories() {
    return allQuestions.map((q) => q.category).toSet().toList();
  }

  List<Question> getFilteredQuestions() {
    if (selectedCategory == "All") return allQuestions;

    return allQuestions
        .where((q) => q.category == selectedCategory)
        .toList();
  }

  @override
  Widget build(BuildContext context) {

    if (isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final filtered = getFilteredQuestions();
    final question = filtered[currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text("Quiz App"),
        backgroundColor: primaryBlue,
      ),

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
                        isAnswered = false;    // 🔥 NEW
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
                  Text(
                    question.question,
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 20),

                  ...question.options.map((opt) {
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
                          color: isAnswered // 🔄 UPDATED (color logic)
                              ? (opt == question.answer
                                  ? Colors.green
                                  : (opt == selectedOption
                                      ? Colors.red
                                      : Colors.white))
                              : (isSelected
                                  ? primaryBlue
                                  : Colors.white),
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
                                      ? Colors.white
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
                        currentIndex++;
                        selectedOption = null;
                        isAnswered = false;
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
                        isCorrect =
                            selectedOption == question.answer;
                      });
                    },
                    child: Text("Confirm"),
                  ),
          )
        ],
      ),
    );
  }
}