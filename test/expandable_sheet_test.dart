import 'package:flutter_test/flutter_test.dart';

import 'package:expandable_sheet/expandable_sheet.dart';

void main() {
  test('ExpandableSheetController initializes with initialHeight', () {
    final controller = ExpandableSheetController(initialHeight: 150);
    expect(controller.height, 150);
    controller.dispose();
  });

  test('ExpandableSheetController updates height and visibility', () {
    final controller = ExpandableSheetController();
    controller.height = 200;
    expect(controller.height, 200);

    controller.show();
    expect(controller.visible, true);

    controller.hide();
    expect(controller.visible, false);

    controller.dispose();
  });
}
