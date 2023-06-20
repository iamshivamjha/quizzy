import 'package:flutter/material.dart';
import '../models/constants.dart';
import '../models/question_model.dart';
import '../widgets/question_widget.dart';
import '../widgets/next_button.dart';
import '../widgets/option_card.dart';
import '../widgets/result_box.dart';
import '../models/db_connect.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var db = DBconnect();
  late Future _questions;
  bool isLoading = true;

  Future<List<Question>> getData() async {
    return db.fetchQuestions();
  }

  @override
  void initState() {
    _questions = getData();
    super.initState();
  }

  // List<Question> _questions = [
  //   Question(
  //     id: '10',
  //     title: 'What is 2 + 2 ?',
  //     options: {'5': false, '30': false, '4': true, '10': false},
  //   ),
  //   Question(
  //     id: '11',
  //     title: 'What is 10 + 20 ?',
  //     options: {'5': false, '30': true, '15': false, '7': false},
  //   )
  // ];

  int index = 0;
  int score = 0;
  bool isPressed = false;
  bool isAlreadySelected = false;

  void nextQuestion(int questionLength) {
    if (index == questionLength - 1) {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => ResultBox(
                result: score,
                questionLength: questionLength,
                onPressed: startOver,
              ));
    } else {
      if (isPressed) {
        setState(() {
          index++;
          isPressed = false;
          isAlreadySelected = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Please select an option'),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.symmetric(vertical: 20.0),
        ));
      }
    }
  }

  void checkAnswerAndUpdate(bool value) {
    if (isAlreadySelected) {
      return;
    } else {
      setState(() {
        isPressed = true;
        isAlreadySelected = true;
        if (value == true) {
          score++;
        } else {
          score--;
        }
      });
    }
  }

  void startOver() {
    setState(() {
      index = 0;
      score = 0;
      isPressed = false;
      isAlreadySelected = false;
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _questions as Future<List<Question>>,
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return Center(
              child: Text('${snapshot.error}'),
            );
          } else if (snapshot.hasData) {
            var extractedData = snapshot.data as List<Question>;
            return Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('lib/assets/pexels-btgl-♡-3894157.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Scaffold(
                backgroundColor: background,
                appBar: AppBar(
                  title: const Text('Quiz App'),
                  backgroundColor: background,
                  shadowColor: Colors.transparent,
                  actions: [
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(
                        'Score: $score',
                        style: const TextStyle(fontSize: 18.0),
                      ),
                    ),
                  ],
                ),
                body: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Column(
                    children: [
                      QuestionWidget(
                        question: extractedData[index].title,
                        indexAction: index,
                        totalQuestions: extractedData.length,
                      ),
                      const Divider(color: neutral),
                      const SizedBox(
                        height: 25.0,
                      ),
                      for (int i = 0;
                          i < extractedData[index].options.length;
                          i++)
                        GestureDetector(
                          onTap: () => checkAnswerAndUpdate(
                              extractedData[index].options.values.toList()[i]),
                          child: OptionCard(
                            option: extractedData[index].options.keys.toList()[i],
                            color: isPressed
                                ? extractedData[index]
                                            .options
                                            .values
                                            .toList()[i] ==
                                        true
                                    ? correct
                                    : incorrect
                                : neutral,
                          ),
                        ),
                    ],
                  ),
                ),
                floatingActionButton: GestureDetector(
                  onTap: () => nextQuestion(extractedData.length),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 25.0),
                    child: NextButton(),
                  ),
                ),
                floatingActionButtonLocation:
                    FloatingActionButtonLocation.centerFloat,
              ),
            );
          }
        } else if(isLoading){
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                CircularProgressIndicator(),
                SizedBox(height: 20.0),
                Text(
                  'PLEASE WAIT TILL THE QUESTIONS ARE LOADING',
                  style: TextStyle(
                    color: Colors.black,
                    decoration: TextDecoration.none,
                    fontSize: 18.0,

                  ),
                ),
              ],
            ),
          );
        } else {
          Future.delayed(const Duration(seconds: 5), () {
            setState(() {
              isLoading =  false;
            });
          });
        }
        return const Center(
          child: Text('No Data'),
        );
      },
    );
  }
}
