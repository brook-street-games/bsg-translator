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
	
	// MARK: - Constants -
	
	struct Constants {
        static let alertMessage = "You need an API_KEY to translate text. See instructions in the README to get one."
		static let alertTitle = "Woah"
	}
	
	// MARK: - Properties -
	
	@State var viewModel: SampleViewModel
	
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
        .alert(Constants.alertTitle, isPresented: $viewModel.alertIsPresented, actions: {
			EmptyView()
		}, message: {
			Text(Constants.alertMessage)
		})
	}
}

// MARK: - Views -

extension SampleView {
	
	struct FruitRow: View {
		
		let fruit: Fruit
		@Bindable var viewModel: SampleViewModel
		
		var body: some View {
			HStack(spacing: 20) {
				Text(fruit.symbol)
					.font(Font.system(size: 24))
                Text(viewModel.displayValue(for: fruit))
                    .id(viewModel.language.code)  
					.font(Font.custom("Lexend", size: 24))
				Spacer()
			}
		}
	}
	
	struct LanguageButton: View {
		
		let language: Language
		@Bindable var viewModel: SampleViewModel
		private var isSelected: Bool { viewModel.language == language && viewModel.pendingLanguage == nil }
		private var isLoading: Bool { viewModel.pendingLanguage == language }
		
		var body: some View {
			Button(action: {
				viewModel.languageSelected(language)
			}, label: {
                Text(language.name)
					.opacity(isLoading ? 0 : 1)
					.font(Font.custom("Lexend", size: 24))
					.foregroundColor(Color(uiColor: .systemBackground))
					.padding()
					.background {
						RoundedRectangle(cornerRadius: 10)
							.foregroundColor(Color(uiColor: isSelected ? .systemGreen : .label))
					}
					.overlay {
						ProgressView()
							.opacity(isLoading ? 1 : 0)
							.tint(Color(uiColor: .systemBackground))
					}
			})
			.buttonStyle(PulseButtonStyle())
		}
	}
}

// MARK: - Preview -

#Preview {
    let viewModel = SampleViewModel()
    SampleView(viewModel: viewModel)
}
