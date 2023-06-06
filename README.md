# BSGTranslator

## Overview

An iOS framework for quick multi-language support using Google Translate API. Strings can be translated directly from a .strings file, or passed in manually. An API key is required, and clients will be charged only after reaching a freemium threshold. For more information, check out [Google Translate API](https://rapidapi.com/googlecloud/api/google-translate1/). This framework utilizes caching to limit API calls.

## Installation

#### Requirements

+ iOS 13+
+ Google Translate API

#### Google Translate API

1. Create a [RapidAPI](https://rapidapi.com/) account.
2. Visit **API Hub** from the dashboard and subscribe to [Google Translate API](https://rapidapi.com/googlecloud/api/google-translate1/).
3. Navigate to ***My Apps->Add New App*** from the dashboard and create a new application.
4. Copy the API key for the new application.

#### Swift Package Manager

1. Navigate to ***File->Add Packages***.
3. Enter Package URL: https://github.com/brook-street-games/bsg-translator.git
3. Select a dependency rule. **Up to Next Major** is recommended.
4. Select a project.
5. Select **Add Package**.

## Usage

#### Create a Strings File

Create a new file at ***File->New->File->Strings File***. This file should contain keys and input language translations for all text to be translated.

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

#### Get Translations

```swift
// Import the framework.
import BSGTranslator

// Grab the API key from installation.
let apiKey = "API_KEY"

// Create an instance of Translator.
let translator = Translator(apiKey: apiKey, inputLanguage: "en", inputType: .stringsFile(fileName: "Sample"))

// Add a delegate.
translator.delegate = self

// Translate input strings into output language (defaults to iOS settings).
translator.updateTranslations()

// Handle the result.
func translator(_ translator: Translator, didCompleteTranslation result: Result<TranslationSet, TranslationError>) {
	
	switch result {
		
	case .success:
		// Start accessing translations.
	case .failure(let error):
		// Handle error.
	}
}
```

#### Access Translations

```swift
label.text = translator.translate("pineapple")
```

## Customization

#### Translation ID

A translation ID can be used to force a new API call when string values change. For example, if an application is being translated to Italian, and the english translation for pineapple was changed from "pineapple" to "spikey fruit" in a new version, users with the previous version would still return the cached value "ananas". Passing a translation ID of 2 (assuming nil or a lower value was previously passed) would force a translation and correctly return "frutto appuntito".

```swift
translator.updateTranslations(translationId: 2)
```

#### Async/Await

Instead of supplying a delegate, async/await can be used.

```swift
Task {
	do {
		try await translator.updateTranslations()
		// Handle completion.
	} catch {
		// Handle error.
	}
}
```

#### Capitalization

* **None**. No adjustment.
* **First**. Capitalize the first letter of the first word.
* **All First**. Captitalize the first letter of each word.
* **All**. Capitalize all letters.
       
```swift
label.text = translator.translate("pineapple", capitalization: .all)
```

## Author

Brook Street Games LLC
