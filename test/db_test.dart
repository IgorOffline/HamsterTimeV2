import 'package:flutter_test/flutter_test.dart';
import 'package:hamster_time_v2/main.dart';

void main() {
  testWidgets('More than 3 categories', (WidgetTester tester) async {
    final categories = dbSelectCategories();
    expect(categories.length > 3, true);
  });
}
