# 📱 Metal Detector iOS - Localization Setup Guide

## Step 1: Xcode Project Settings

### 1.1 Add Localizations to Your Project

1. **Open your Xcode project**
2. **Select your project** in the Project Navigator (top item)
3. **Select your app target** (Metal Detector IOS)
4. Go to **Info** tab
5. Under **Localizations** section, click the **+** button
6. **Add all these languages** one by one:

   - English (en) - Base
   - French (fr) - francias
   - Polish (pl) - polski
   - Vietnamese (vi) - vietnamese
   - Chinese Simplified (zh-Hans) - China
   - Chinese Traditional (zh-Hant) - Hongkong
   - Indonesian (id) - indonesia
   - German (de) - Deutsh
   - Spanish (es) - espanol
   - Italian (it) - italiano
   - Portuguese (pt) - portugues
   - Turkish (tr) - turkce
   - Japanese (ja) - japan
   - Korean (ko) - korean
   - Thai (th) - thailand
   - Arabic (ar) - Arabic
   - Hindi (hi) - Hindi
   - Filipino (fil) - Philipino
   - Malay (ms) - malay

### 1.2 Create Localizable.strings Files

1. **Right-click** on "Metal Detector IOS" folder in Project Navigator
2. Select **New File...**
3. Choose **Resource** → **Strings File**
4. Name it: **Localizable.strings**
5. **IMPORTANT**: In the File Inspector (right panel):
   - Under **Localization**, check ALL languages you want to support
   - This will create separate files for each language

### 1.3 Add Localization Files to Project

After creating Localizable.strings:
- Xcode will automatically create folders like:
  - `en.lproj/Localizable.strings`
  - `fr.lproj/Localizable.strings`
  - `pl.lproj/Localizable.strings`
  - etc.

## Step 2: File Structure

Your project structure should look like:

```
Metal Detector IOS/
├── Localization/
│   ├── Localizable.strings (en) - Base
│   ├── Localizable.strings (fr) - French
│   ├── Localizable.strings (pl) - Polish
│   ├── Localizable.strings (vi) - Vietnamese
│   ├── Localizable.strings (zh-Hans) - Chinese Simplified
│   ├── Localizable.strings (zh-Hant) - Chinese Traditional
│   ├── Localizable.strings (id) - Indonesian
│   ├── Localizable.strings (de) - German
│   ├── Localizable.strings (es) - Spanish
│   ├── Localizable.strings (it) - Italian
│   ├── Localizable.strings (pt) - Portuguese
│   ├── Localizable.strings (tr) - Turkish
│   ├── Localizable.strings (ja) - Japanese
│   ├── Localizable.strings (ko) - Korean
│   ├── Localizable.strings (th) - Thai
│   ├── Localizable.strings (ar) - Arabic
│   ├── Localizable.strings (hi) - Hindi
│   ├── Localizable.strings (fil) - Filipino
│   └── Localizable.strings (ms) - Malay
└── ...
```

## Step 3: Add Language Files

I've created all the Localizable.strings files in the `Localization/` folder. You need to:

1. **Add these files to Xcode**:
   - Drag the `Localization/` folder into your Xcode project
   - Check "Copy items if needed"
   - Check your app target

2. **For each file**, in File Inspector:
   - Select the file
   - Check the appropriate language in Localization section

## Step 4: Using Localization in Code

Replace hardcoded strings with:

```swift
// Instead of:
Text("Metal Detector")

// Use:
Text(NSLocalizedString("metal_detector", comment: ""))
// Or with helper:
Text(LocalizedString.metalDetector)
```

## Step 5: Change Language Programmatically

Use the `LocalizationManager` class to change app language dynamically.

```swift
// Set language
LocalizationManager.shared.setLanguage("fr") // French

// Get current language
let currentLang = LocalizationManager.shared.currentLanguage

// Get localized string
let text = LocalizationManager.shared.localizedString("metal_detector")
```

## Notes

- **Base language**: English (en) - this is your default/fallback language
- **Language codes**: Use ISO 639-1 codes (en, fr, pl, etc.)
- **Testing**: Change device language in Settings → General → Language & Region to test







