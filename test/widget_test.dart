import 'package:flutter_test/flutter_test.dart';
import 'package:tempo_clock/app.dart';

void main() {
  testWidgets('clock app opens and shows main navigation', (tester) async {
    await tester.pumpWidget(const TempoClockApp());
    expect(find.text('TEMPO'), findsOneWidget);
    expect(find.text('الساعة'), findsOneWidget);
    expect(find.text('إيقاف'), findsOneWidget);
    expect(find.text('المؤقت'), findsOneWidget);
  });
}
