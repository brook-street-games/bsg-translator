//
//  SampleViewModel.swift
//
//  Created by JechtSh0t on 6/1/23.
//  Copyright © 2023 Brook Street Games LLC. All rights reserved.
//

import SwiftUI
import BSGTranslator

///
/// Data and functionality for the sample application.
///
class SampleViewModel: ObservableObject {
	
	// MARK: - Constants -
	
	private struct Constants {
		
		static let fruitAnimationHalfDuration: TimeInterval = 0.1
		static let fruitAnimationDelay: TimeInterval = 0.02
	}
	// MARK: - Properties -
	
	/// The currently selected language.
	@Published var language: Language
	/// Used to control ripple animation.
	@Published var animatingFruitKeys = Set<String>()
	/// Translates text between languages.
	private lazy var translator = Translator(apiKey: "API_KEY", inputLanguage: "en", inputType: .stringsFile(fileName: "Sample"), delegate: self)
	
	let fruits = [
		Fruit(key: "apple", symbol: "🍎"),
		Fruit(key: "banana", symbol: "🍌"),
		Fruit(key: "blueberry", symbol: "🫐"),
		Fruit(key: "coconut", symbol: "🥥"),
		Fruit(key: "cherry", symbol: "🍒"),
		Fruit(key: "grape", symbol: "🍇"),
		Fruit(key: "kiwi", symbol: "🥝"),
		Fruit(key: "lemon", symbol: "🍋"),
		Fruit(key: "orange", symbol: "🍊"),
		Fruit(key: "peach", symbol: "🍑"),
		Fruit(key: "pear", symbol: "🍐"),
		Fruit(key: "pineapple", symbol: "🍍"),
		Fruit(key: "strawberry", symbol: "🍓"),
		Fruit(key: "watermelon", symbol: "🍉")
	]
	
	let languages = [
		Language(alpha2: "en", name: "English"),
		Language(alpha2: "es", name: "Spanish"),
		Language(alpha2: "it", name: "Italian"),
		Language(alpha2: "de", name: "German"),
		Language(alpha2: "ja", name: "Japanese"),
		Language(alpha2: "ar", name: "Arabic")
	]
	
	// MARK: - Initializers -
	
	init() {
		language = languages[0]
	}
}

// MARK: - User Intent -

extension SampleViewModel {
	
	func selectLanguage(_ language: Language) {
		
		guard language != self.language else { return }
		
		self.language = language
		translator.updateTranslations(targetLanguage: language.alpha2)
	}
}

// MARK: - Translator -

extension SampleViewModel: TranslatorDelegate {
	
	func translator(_ translator: Translator, didReceiveTranslationSet translationSet: TranslationSet) {
		
		print("Translation success.")
		animateFruit()
	}
	
	func translator(_ translator: Translator, didEncounterError error: TranslationError) {
		print("Translation error: \(error).")
	}
}

// MARK: - Display -

extension SampleViewModel {
	
	func displayValue(for fruit: Fruit) -> String {
		translator.translate(fruit.key)
	}
	
	func displayValue(for language: Language) -> String {
		translator.translate(language.name)
	}
}

// MARK: - Animation -

extension SampleViewModel {
	
	private func animateFruit() {
		
		withAnimation {
			for fruit in fruits {
				
				guard let index = fruits.firstIndex(where: { $0 == fruit }) else { continue }
				let delay = Double(index) * Constants.fruitAnimationDelay
				
				DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
					self.animatingFruitKeys.insert(fruit.key)
					DispatchQueue.main.asyncAfter(deadline: .now() + delay + Constants.fruitAnimationHalfDuration) {
						self.animatingFruitKeys.remove(fruit.key)
					}
				}
			}
		}
	}
}
