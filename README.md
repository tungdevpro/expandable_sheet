# expandable_sheet

Hi there, in my spare time, i wrote this package to solve some problems that i encountered :)) 

A lightweight Flutter widget for a draggable, resizable bottom sheet that snaps
between a minimum, initial, and maximum height.

## Features

- Drag to resize between `minHeight`, `initialHeight`, and `maxHeight`
- Snaps to the nearest extent when the drag ends
- Optionally expand to fill the available height (`expandToFullHeight`)
- Hides automatically when the inner content is scrolled past its top edge
- Callbacks for when the sheet is hidden or reaches its max height
- Customizable background and drag-handle color

## Getting started

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  expandable_sheet: ^0.0.1
```

Then import it:

```dart
import 'package:expandable_sheet/expandable_sheet.dart';
```

## Usage

```dart
ExpandableSheet(
  minHeight: 100,
  initialHeight: 250,
  maxHeight: 500,
  onSheetHidden: () => print('Sheet hidden'),
  onSheetMaxHeight: () => print('Sheet fully expanded'),
  contentBuilder: (scrollController) {
    return ListView.builder(
      controller: scrollController,
      itemCount: 20,
      itemBuilder: (context, index) => ListTile(title: Text('Item $index')),
    );
  },
)
```

### Parameters

| Parameter            | Type                              | Default     | Description                                              |
|-----------------------|-----------------------------------|-------------|------------------------------------------------------------|
| `minHeight`           | `double`                          | `100`       | Smallest height the sheet can be dragged to               |
| `maxHeight`           | `double`                          | `500`       | Largest height the sheet can be dragged to                |
| `initialHeight`       | `double`                          | `100`       | Height the sheet snaps to between min and max             |
| `enableMaxHeight`     | `bool`                            | `false`     | If `true`, uses `maxHeight` as-is instead of the available layout height |
| `expandToFullHeight`  | `bool`                            | `false`     | Forces the sheet to stay expanded at `maxHeight`           |
| `onSheetHidden`       | `VoidCallback?`                   | `null`      | Called when the sheet snaps down to `minHeight`            |
| `onSheetMaxHeight`    | `VoidCallback?`                   | `null`      | Called when the sheet snaps up to `maxHeight`              |
| `contentBuilder`      | `Widget Function(ScrollController)` | required  | Builds the sheet's scrollable content                      |
| `backgroundColor`     | `Color`                           | `Colors.white` | Background color of the sheet                          |
| `handleColor`         | `Color`                           | `Color(0xFFD9D9D9)` | Color of the drag handle                          |

`ExpandableSheet` manages its own internal `ExpandableSheetController` to track
height and visibility; it is not currently exposed as a constructor parameter.

## Additional information

Contributions and issues are welcome via the project's GitHub repository.
