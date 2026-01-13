import 'package:quizzy/domain/kahoots/entities/kahoot.dart';
import 'package:quizzy/domain/kahoots/entities/kahoot_question.dart';
import 'kahoot_builder.dart';

class KahootMother {
  static Kahoot random() {
    return KahootBuilder()
        .withId("random-id-${DateTime.now().millisecondsSinceEpoch}")
        .withTitle("Random Kahoot")
        .build();
  }

  static Kahoot published() {
    return KahootBuilder()
        .withStatus("published")
        .withVisibility("public")
        .build();
  }

  static Kahoot draft() {
    return KahootBuilder()
        .withStatus("draft")
        .build();
  }
  
  static Kahoot withQuestions(int count) {
    // Generate simple mock questions
    final questions = List.generate(count, (index) => KahootQuestion(
      id: "q-$index",
      text: "Question $index",
      type: "quiz",
      timeLimit: 20,
      points: 1000,
    ));

    return KahootBuilder()
        .withQuestions(questions)
        .build();
  }
}
