//
//  SampleView.swift
//
//  Created by JechtSh0t on 6/1/23.
//  Copyright © 2023 Brook Street Games LLC. All rights reserved.
//

import SwiftUI

///
/// UI for the sample application.
///
struct SampleView: View {
	
	// MARK: - Properties -
	
	@ObservedObject var viewModel: SampleViewModel
	
	// MARK: - UI -
	
	var body: some View {
		
		VStack(spacing: 20) {
			
			ScrollView {
				VStack(spacing: 20) {
					ForEach(viewModel.fruits) { fruit in
						FruitRow(fruit: fruit, viewModel: viewModel)
							.scaleEffect(viewModel.animatingFruitKeys.contains(fruit.key) ? 1.1 : 1.0)
							.animation(.spring(response: 0.5, dampingFraction: 0.5, blendDuration: 0), value: viewModel.animatingFruitKeys)
					}
				}
				.padding(.horizontal, 20)
			}
			.scrollIndicators(.hidden)
			
			ScrollView(.horizontal) {
				HStack {
					ForEach(viewModel.languages) { language in
						LanguageButton(language: language, viewModel: viewModel)
					}
				}
			}
			.scrollIndicators(.hidden)
		}
		.padding()
	}
}

extension SampleView {
	
	struct FruitRow: View {
		
		let fruit: Fruit
		@ObservedObject var viewModel: SampleViewModel
		
		var body: some View {
			
			HStack(spacing: 20) {
				Text(fruit.symbol)
					.font(Font.system(size: 24))
				Text(viewModel.displayValue(for: fruit))
					.font(Font.custom("Lexend", size: 24))
				Spacer()
			}
		}
	}
	
	struct LanguageButton: View {
		
		let language: Language
		@ObservedObject var viewModel: SampleViewModel
		private var isSelected: Bool { (viewModel.language == language) }
		
		var body: some View {
			
			Button(action: {
				viewModel.selectLanguage(language)
			}, label: {
				Text(viewModel.displayValue(for: language))
					.font(Font.custom("Lexend", size: 24))
					.foregroundColor(Color(uiColor: .systemBackground))
					.padding()
					.background {
						RoundedRectangle(cornerRadius: 10)
							.foregroundColor(Color(uiColor: isSelected ? .systemGreen : .label))
					}
			})
			.buttonStyle(PulseButtonStyle())
		}
	}
}

// MARK: - Preview -

struct SampleViewPreview: PreviewProvider {
	
	static var previews: some View {
		
		let viewModel = SampleViewModel()
		SampleView(viewModel: viewModel)
	}
}
