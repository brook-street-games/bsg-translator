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
	
	/// The language with translation in progress.
	@Published var pendingLanguage: Language?
	/// The display language.
	@Published var language: Language!
	/// Used to control ripple animation.
	@Published var animatingFruitKeys = Set<String>()
	/// Determines if an alert should be presented.
	@Published var alertIsPresented: Bool = false
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
		Language(code: "en", name: "English"),
		Language(code: "es", name: "Spanish"),
		Language(code: "it", name: "Italian"),
		Language(code: "de", name: "German"),
		Language(code: "ja", name: "Japanese"),
		Language(code: "ar", name: "Arabic")
	]
	
	// MARK: - Initializers -
	
	init() {
		selectLanguage(languages[0])
		debugPrint("Disk cache directory: \(Translator.Constants.diskCacheDirectory)")
	}
}

// MARK: - User Intent -

extension SampleViewModel {
	
	func selectLanguage(_ language: Language) {
		
		guard language != self.language, language != pendingLanguage else { return }
		self.pendingLanguage = language
		translator.outputLanguage = language.code
		
		translator.updateTranslations()
	}
}

// MARK: - Translator -

extension SampleViewModel: TranslatorDelegate {
	
	func translator(_ translator: Translator, didUpdateTranslations result: Result<TranslationSet, TranslationError>) {
		
		switch result {
			
		case .success:
			print("Translation success.")
			if let pendingLanguage { language = pendingLanguage }
			animateFruit()
			
		case .failure(let error):
			print("Translation failure. \(error)")
			if case .invalidResponse(let statusCode) = error, statusCode == 403 {
				alertIsPresented = true
			}
		}
		
		pendingLanguage = nil
	}
	
	func translator(_ translator: Translator, didEncounterLogEvent logEvent: String) {
		print(logEvent)
	}
}

// MARK: - Display -

extension SampleViewModel {
	
	func displayValue(for fruit: Fruit) -> String {
		translator.translate(fruit.key, capitalization: .allFirst)
	}
	
	func displayValue(for language: Language) -> String {
		language.name
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
