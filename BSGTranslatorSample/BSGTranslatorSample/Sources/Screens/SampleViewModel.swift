//
//  SampleViewModel.swift
//
//  Created by JechtShot on 6/1/23.
//  Copyright © 2023 Brook Street Games LLC. All rights reserved.
//

import BSGTranslator
import SwiftUI

///
/// Data and functionality for the sample application.
///
@MainActor
@Observable
final class SampleViewModel {
	
	// MARK: - Constants -
	
	private struct Constants {
		static let fruitAnimationHalfDuration: TimeInterval = 0.1
		static let fruitAnimationDelay: TimeInterval = 0.02
	}
	
	// MARK: - Properties -
	
	/// The language with translation in progress.
	var pendingLanguage: Language?
	/// The display language.
	var language: Language
	/// Used to control ripple animation.
	var animatingFruitKeys = Set<String>()
	/// Determines if an alert should be presented.
    var alertIsPresented: Bool = false
	/// Translates text between languages.
    private var translator = Translator(
        apiKey: "API_KEY",
        sourceLanguage: "en",
        sourceType: .stringsFile(fileName: "Sample")
    )
	
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
        self.language = languages[0]
		debugPrint("Disk cache directory: \(Translator.Constants.diskCacheDirectory)")
	}
}

// MARK: - View Actions -

extension SampleViewModel {
	
	func languageSelected(_ language: Language) {
        Task { @MainActor in
            do {
                guard language != self.language, language != pendingLanguage else { return }
                self.pendingLanguage = language
                translator.targetLanguage = language.code
                try await translator.updateTranslations()
                debugPrint("Translation success.")
                self.language = language
                pendingLanguage = nil
                animateFruit()
            } catch {
                debugPrint("Translation failure. \(error)")
                pendingLanguage = nil
                alertIsPresented = true
            }
        }
	}
}

// MARK: - Display -

extension SampleViewModel {
	
    func displayValue(for fruit: Fruit) -> String {
        translator[fruit.key, .allFirst]
	}
}

// MARK: - Animation -

extension SampleViewModel {
	
	private func animateFruit() {
		withAnimation {
			for fruit in fruits {
				guard let index = fruits.firstIndex(where: { $0 == fruit }) else { continue }
                Task { @MainActor in
                    let delay = Double(index) * Constants.fruitAnimationDelay
                    try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                    animatingFruitKeys.insert(fruit.key)
                    try await Task.sleep(nanoseconds: UInt64((delay + Constants.fruitAnimationHalfDuration) * 1_000_000_000))
                    animatingFruitKeys.remove(fruit.key)
                }
			}
		}
	}
}
