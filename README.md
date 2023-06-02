# BSGTranslator

## Overview

A framework for quickly supporting multiple languages using Google Translate API. This is a freemium API, which means conmsumers will be charged after reaching a certain threshold. This framework utilizes caching to be as stringent as possible with API calls.

## Installation

#### Requirements

+ iOS 13+
+ Google Translate API

#### Google Translate API

1. Create a [RapidAPI](https://rapidapi.com/) account.
2. Visit **API Hub** from the dashboard and subscribe to Google Translate API.
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

Example **Fruit.strings** file.

```swift
"banana" = "Banana";
"orange" = "Orange";
"pineapple" = "Pineapple";
```

#### Get Translations

```swift
// Import the framework.
import BSGTranslator

// Grab the API key from installation.
let apiKey = "API_KEY"

// Create an instance of Translator.
let translator = Translator(apiKey: apiKey, inputLanguage: "en", inputType: .stringsFile(fileName: "Fruit"), delegate: self)

// Translate input strings into Italian.
translator.getTranslations(targetLanguage: "it")

// Conform to TranslatorDelegate to handle the result. If this is the first time translating for a target language, this method will likely take a few seconds to get called while the API call goes out. Subsequent calls will retrieve translations from cache.
func translator(_ translator: Translator, didReceiveTranslationSet translationSet: TranslationSet) {
	// Handle translation completion.
}
```

#### Access Translations

```swift
label.text = translator.translate("banana")
```

## Customization

#### Translation ID

A translation ID can be used to force a new API call when string values change. For example, if the english translation for banana was changed to "Yellow Fruit" in a new version of an application, users with the previous version would still return the cached value "Banana" for the key "banana". Passing a translation ID of 2 (assuming nil or a lower value was previously passed) would force a translation and correctly return "Frutta Gialla".

```swift
translator.getTranslations(targetLanguage: "it", translationId: 2)
```

#### Capitalization

* **None**. The translation is returned with no adjustment.
* **First**. The first letter of the first word is capitalized.
* **All First**. The first letter of every word is capitalized.
* **All**. All letters are capitalized.
       
```swift
label.text = translator.translate("banana", capitalization: .all)
```

## Author

Brook Street Games LLC
