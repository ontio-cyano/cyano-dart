# Cyano in Dart

Yet another Cyano implementation, written in Flutter&Dartlang. It's compliant with the [Cyano Enhancement Proposals](https://github.com/ontio-cyano/CEPs).

## Getting Started

1. Install flutter, [link](https://flutter.dev/docs/get-started/install)
2. Setup VSCode, [link](https://flutter.dev/docs/get-started/editor?tab=vscode)
3. Use VSCode to open your clone, accept the suggestions to resolve dependencies
4. Press `F5` to debug

## Android

It only runs on iOS now and can be ported to Android easily. For an Android porting, these requirements need to be satisfied:

1. Crypto related methods
2. Because Android does not have a default keyboard, so a soft keyboard is important for keeping input security
3. Keyboard behaves weird in WebViews on Android, see [here](https://github.com/flutter/flutter/issues/19718)

