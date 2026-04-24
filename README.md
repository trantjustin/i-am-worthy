# I Am Worthy

A tiny iPhone app that replaces your **Lock Screen date** with a short daily affirmation — *"Wed 23 Apr | I am worthy"*.

Built with SwiftUI and WidgetKit as an `.accessoryInline` Lock Screen widget. One new affirmation per day, chosen deterministically so every device shows the same message on the same date.

## Screenshots

<!-- Drop a Lock Screen photo and a customize-screen photo in docs/ and update the paths below. -->

| Lock Screen | Customize picker |
| :---: | :---: |
| [Lock Screen](docs/lockscreen.png) | [Customize picker](docs/customize.png) |

## Features

- `.accessoryInline` Lock Screen widget — sits in the date slot directly above the clock
- ~60 curated affirmations, deterministic by day (same message on every device)
- Daily rotation without background refresh — 7-day timeline pre-baked at midnight
- In-app preview of how the Lock Screen will look
- iPhone only, portrait only, iOS 17+

## Requirements

- macOS with Xcode 15 or later
- iOS 17.0+ device or simulator
- [XcodeGen](https://github.com/yonaskolb/XcodeGen) (`brew install xcodegen`) to regenerate the project from `project.yml`

## Getting Started

```bash
git clone <your-fork-url> IAm
cd IAm
xcodegen generate            # regenerate IAmWorthy.xcodeproj from project.yml
open IAmWorthy.xcodeproj
```

In Xcode, set your **Team** under *Signing & Capabilities* for both the `IAmWorthy` app target and the `IAmWorthyWidgetExtension` target, then build and run (⌘R).

To add the widget to your Lock Screen: long-press the Lock Screen → **Customize** → tap the Lock Screen → tap the **date** above the clock → choose **I Am**.

## Project Structure

```
IAm/
├── IAmWorthyApp/                 # Main app target (SwiftUI)
│   ├── IAmWorthyApp.swift        # @main App entry point
│   ├── ContentView.swift         # Lock Screen preview + instructions
│   └── Assets.xcassets/          # App icon, accent color
├── IAmWorthyWidget/              # Widget extension target
│   ├── IAmWorthyWidgetBundle.swift
│   ├── IAmWorthyWidget.swift     # TimelineProvider + .accessoryInline view
│   └── Info.plist
├── Shared/
│   └── Affirmations.swift        # Curated list + deterministic day selector
├── scripts/
│   ├── generate-app-icon.swift   # Programmatic AppIcon generator
│   └── upload-testflight.sh      # Archive + upload via ASC API key
├── project.yml                   # XcodeGen spec (source of truth)
├── ExportOptions.plist           # Release export config
└── IAmWorthy.xcodeproj/          # Generated — do not edit by hand
```

The Xcode project is generated from `project.yml`; edit the YAML and rerun `xcodegen generate` rather than editing the `.xcodeproj` directly.

## Adding or Editing Affirmations

All strings live in [`Shared/Affirmations.swift`](Shared/Affirmations.swift). Keep each line short — the combined `EEE d MMM | <message>` has to fit the inline date slot on the narrowest iPhone without truncation. Test both a short date (`Fri 1 May`) and a long one (`Wed 23 Sep`) before shipping.

## Credits

Affirmations curated and distilled from:

- [101 Inspirational Quotes — Live Love Simple](https://livelovesimple.com/101-inspirational-quotes/)
- [Inspirational Quotes — Brian Tracy](https://www.briantracy.com/blog/personal-success/inspirational-quotes/)

App and widget implementation by [@jtrant](https://github.com/jtrant).

## License

This project is licensed under the **GNU General Public License v3.0**. See [`LICENSE`](LICENSE) for the full text, or read a summary at [gnu.org/licenses/gpl-3.0](https://www.gnu.org/licenses/gpl-3.0.en.html).
