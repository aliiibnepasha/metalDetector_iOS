# 🛠️ Xcode Localization Setup - Step by Step

## IMPORTANT: Follow these steps in Xcode

### Step 1: Add Localizations to Project

1. **Open your project in Xcode**
2. **Click on your project name** (Metal Detector IOS) in the left sidebar (Project Navigator)
3. **Select your app target** (Metal Detector IOS) under "TARGETS"
4. Click on **"Info"** tab
5. Scroll down to **"Localizations"** section
6. Click the **"+"** button to add languages
7. **Add ALL these languages one by one:**

   ```
   ✅ English (en) - Already exists as Base
   ✅ French (fr)
   ✅ Polish (pl)
   ✅ Vietnamese (vi)
   ✅ Chinese Simplified (zh-Hans)
   ✅ Chinese Traditional (zh-Hant)
   ✅ Indonesian (id)
   ✅ German (de)
   ✅ Spanish (es)
   ✅ Italian (it)
   ✅ Portuguese (pt)
   ✅ Turkish (tr)
   ✅ Japanese (ja)
   ✅ Korean (ko)
   ✅ Thai (th)
   ✅ Arabic (ar)
   ✅ Hindi (hi)
   ✅ Filipino (fil)
   ✅ Malay (ms)
   ```

### Step 2: Add Localizable.strings File to Xcode

1. **Right-click** on "Metal Detector IOS" folder in Project Navigator
2. Select **"New File..."**
3. Choose **"Resource"** → **"Strings File"**
4. Name it: **`Localizable.strings`**
5. **IMPORTANT**: After creating:
   - Select the file `Localizable.strings`
   - Open **File Inspector** (right panel - View → Inspectors → File)
   - Under **"Localization"** section, you'll see checkboxes
   - **Check ALL the languages** you want to support (or click "Localize..." button first)
   - Xcode will automatically create `.lproj` folders for each language

### Step 3: Copy Localization Content

1. The file `Metal Detector IOS/Localization/Localizable.strings` contains all the keys
2. **Copy this file's content** to each language's Localizable.strings in Xcode
3. Or manually copy the file structure

### Step 4: Structure After Setup

After setup, Xcode will create this structure:

```
Metal Detector IOS/
├── en.lproj/
│   └── Localizable.strings (English)
├── fr.lproj/
│   └── Localizable.strings (French)
├── pl.lproj/
│   └── Localizable.strings (Polish)
├── vi.lproj/
│   └── Localizable.strings (Vietnamese)
├── zh-Hans.lproj/
│   └── Localizable.strings (Chinese Simplified)
├── zh-Hant.lproj/
│   └── Localizable.strings (Chinese Traditional)
├── id.lproj/
│   └── Localizable.strings (Indonesian)
├── de.lproj/
│   └── Localizable.strings (German)
├── es.lproj/
│   └── Localizable.strings (Spanish)
├── it.lproj/
│   └── Localizable.strings (Italian)
├── pt.lproj/
│   └── Localizable.strings (Portuguese)
├── tr.lproj/
│   └── Localizable.strings (Turkish)
├── ja.lproj/
│   └── Localizable.strings (Japanese)
├── ko.lproj/
│   └── Localizable.strings (Korean)
├── th.lproj/
│   └── Localizable.strings (Thai)
├── ar.lproj/
│   └── Localizable.strings (Arabic)
├── hi.lproj/
│   └── Localizable.strings (Hindi)
├── fil.lproj/
│   └── Localizable.strings (Filipino)
└── ms.lproj/
    └── Localizable.strings (Malay)
```

### Step 5: Translate Strings

For each language file (except English which is already done), translate the values:

**Example for French (fr.lproj/Localizable.strings):**

```strings
"metal_detector" = "Détecteur de Métaux";
"gold_detector" = "Détecteur d'Or";
"setting" = "Paramètres";
// ... etc
```

### Step 6: Verify Setup

1. **Build your project** (⌘ + B)
2. **Run the app**
3. **Change language** from Language screen - app should update immediately

## ⚠️ Important Notes

- **Base Language**: English (en) is your base/fallback language
- **File Format**: Each line in Localizable.strings should be: `"key" = "value";`
- **Semicolon Required**: Don't forget the semicolon at the end of each line
- **Comments**: Lines starting with `//` or `/* */` are comments
- **Missing Translations**: If a key is missing in a language, it will fallback to English

## 🚀 Next Steps

After setting up in Xcode:
1. Translate all strings in each language file
2. Test by changing language in the app
3. All views should update automatically using LocalizationManager




