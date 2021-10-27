# BSGTranslator

## Description
BSGTranslator uses Google Translate API to help iOS applications support multiple languages as smoothly as possible.

## Requirements

+ iOS 13+
+ Google Translate API key

## Installation

### Create RapidAPI Application

1. Create a [RapidAPI](https://rapidapi.com/) account.
2. Visit API Hub from the dashboard and subscribe to Google Translate API. Note this is a freemium API, which means conmsumers will be charged after reaching a certain threshold. This framework utilizes caching to try to be as stringent as possible with API calls.
3. Navigate to My Apps->Add New App from the dashboard and create a new application.
4. Copy the API key for the new application.

### Add Swift Package Manager Dependency

1. File->Add Packages
3. Enter project URL (https://github.com/brook-street-games/bsg-translator.git) and click Next
4. Select (Branch, main) and click Add Package

## Usage

### Create a Translator Instance

```swift
// Gets input strings directly from a *Test.strings* file.
var translator = Translator(apiKey: "API_KEY", inputLanguage: "en", inputType: .stringsFile(fileName: "Test"))
/// Conform to TranslatorDelegate to handle delegate methods
translator.delegate = self
```

### Get Translations

```swift
// Translates input strings into Italian.
translator.getTranslations(targetLanguage: "it")
// Optionally specify a translation ID. This will only fire an API call to update if the last update was performed with a transaction ID < 2.
translator.getTranslations(targetLanguage: "it", translationId: 2)
```

### Access Translations

```swift
// Get translation in Italian.
label.text = translator.translate("test-key")
// Optionally specify a capitalization style.
label.text = translator.translate("test-key", capitalization: .allFirst)
```

## Author

Brook Street Games LLC
