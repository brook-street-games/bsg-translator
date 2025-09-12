# BSGTranslator

## Overview

An iOS library for quick multi-language support using Google Cloud Translation API. Caching is utilized to limit API calls.

https://github.com/brook-street-games/bsg-translator/assets/72933425/ff2cfb8b-220d-4e50-bfc3-3e3d8a65af86

## Requirements

+ iOS 15+
+ Google Cloud Translation API Key

## Installation

### 1. Google Cloud

1. Follow the steps in [Cloud Translation Setup](https://cloud.google.com/translate/docs/setup) to get an API key.

### 2. Swift Package Manager

1. Navigate to ***File->Add Package Dependencies...***
3. Enter package URL: https://github.com/brook-street-games/bsg-translator.git
3. Select a dependency rule. **Up to Next Major Version** is recommended.
4. Select a project.
5. Select **Add Package**.

## Usage

### Gather Source Strings

Create a new file at ***File->New->File from Template...->Strings File***. This file should contain keys and source language translations for all text to be translated. Alternatively, a raw dictionary can be used.

**Sample.strings**

```swift
"apple" = "apple";
"banana" = "banana";
"blueberry" = "blueberry";
"coconut" = "coconut";
"cherry" = "cherry";
"grape" = "grape";
"kiwi" = "kiwi";
"lemon" = "lemon";
"orange" = "orange";
"peach" = "peach";
"pear" = "pear";
"pineapple" = "pineapple";
"strawberry" = "strawberry";
"watermelon" = "watermelon";
```

### Update Translations

```swift
// Import the framework.
import BSGTranslator

// Create an instance of Translator using the API key from installation.
let translator = Translator(apiKey: "API_KEY", sourceLanguage: "en", sourceType: .stringsFile(fileName: "Sample"))

do {
	// Translate source strings into the target language (defaults to iOS settings). This should be called once at the launch of the application, and again if another language is needed.
	try await translator.updateTranslations()
} catch {
	// Handle error.
}
```

### Access Translations

```swift
let translation = translator.getTranslatedValue(for: "coconut")
```
or

```swift
let translation = translator["coconut"]
```

## Customization

### Translation ID

A translation ID can be used to force a new API call when string values change, but keys stay the same.

```swift
// Force an update if the cached value has an ID of <2.
translator.updateTranslations(translationId: 2)
```

### Capitalization

The formatting of translations can be controlled with capitalization styles.
* **None**. Return the result unaltered.
* **First**. Capitalize the first letter of the first word.
* **All First**. Captitalize the first letter of each word.
* **All**. Capitalize all letters.
       
```swift
// Return "Noce Di Cocco".
let translation = translator.getTranslatedValue(for: "coconut", capitalization: .allFirst)
```

## Author

Brook Street Games
