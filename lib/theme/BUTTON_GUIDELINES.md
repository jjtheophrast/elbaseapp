# Button Styling Guidelines

To ensure UI consistency across the application, all buttons must follow these specifications.

## Button Types

### ElevatedButton
Used as the primary action button (e.g., "Start new crawl").

```dart
ElevatedButton(
  onPressed: () {
    // Action
  },
  child: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(Icons.add, size: 18),
      const SizedBox(width: 8),
      Text('Button Text'),
    ],
  ),
)
```

### TextButton
Used for secondary actions.

```dart
TextButton(
  onPressed: () {
    // Action
  },
  child: Text('Button Text'),
)
```

### OutlinedButton
Used for tertiary actions.

```dart
OutlinedButton(
  onPressed: () {
    // Action
  },
  child: Text('Button Text'),
)
```

## Styling Specifications

All buttons should inherit styling from the theme. **DO NOT use explicit style overrides.**

| Property | Value |
|----------|-------|
| Height | 40px |
| Min Width | 120px |
| Border Radius | 100px (fully rounded) |
| Vertical Padding | 10px (top and bottom) |
| Horizontal Padding | 16px left, 24px right (with icon) |
| Text Style | Noto Sans, 14px, weight 500, height 1.43, letterSpacing 0.1 |
| Icon Size | 18px |
| Icon/Text Spacing | 8px |

## Implementation Best Practices

1. **DO NOT** use explicit style overrides on buttons.
   ```dart
   // WRONG
   ElevatedButton(
     style: ElevatedButton.styleFrom(...),  // Don't do this!
     ...
   )
   ```

2. For buttons with icons, use the proper row structure:
   ```dart
   Row(
     mainAxisSize: MainAxisSize.min,
     mainAxisAlignment: MainAxisAlignment.center,
     crossAxisAlignment: CrossAxisAlignment.center,
     children: [
       Icon(Icons.add, size: 18),
       const SizedBox(width: 8),
       Text('Button Text'),
     ],
   )
   ```

3. Ensure text has the proper style:
   ```dart
   Text(
     'Button Text',
     style: GoogleFonts.notoSans(
       fontSize: 14,
       fontWeight: FontWeight.w500,
       height: 1.43,
       letterSpacing: 0.1,
     ),
   )
   ```

## Examples

### With Icon Leading
```dart
ElevatedButton(
  onPressed: () {
    // Action
  },
  child: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(Icons.add, size: 18),
      const SizedBox(width: 8),
      Text('Start new crawl'),
    ],
  ),
)
```

### Text Only
```dart
ElevatedButton(
  onPressed: () {
    // Action
  },
  child: Text('Add new term'),
)
```

### Disabled Button
```dart
ElevatedButton(
  onPressed: null,  // This makes the button disabled
  child: Text('Submit'),
)
``` 