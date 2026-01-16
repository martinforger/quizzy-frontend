import 'package:flutter_test/flutter_test.dart';
import 'package:quizzy/presentation/app.dart';
import 'package:quizzy/presentation/screens/splash/splash_screen.dart';
import 'package:quizzy/injection_container.dart' as di;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await di.init();
  });

  tearDown(() async {
    await di.getIt.reset();
  });

  testWidgets('QuizzyApp has a splash screen on startup', (WidgetTester tester) async {
    // Obtain the shared preferences instance
    final sharedPreferences = await SharedPreferences.getInstance();

    // Build our app and trigger a frame.
    await tester.pumpWidget(QuizzyApp(sharedPreferences: sharedPreferences));

    // Verify that the SplashScreen is present.
    expect(find.byType(SplashScreen), findsOneWidget);
    
    // Allow the splash screen timer to complete
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
  });
}
