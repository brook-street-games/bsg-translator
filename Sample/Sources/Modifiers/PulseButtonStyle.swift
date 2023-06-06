//
//  PulseButtonStyle.swift
//
//  Created by JechtSh0t on 6/2/23.
//  Copyright © 2023 Brook Street Games LLC. All rights reserved.
//

import SwiftUI

///
/// Style for a button that pulses when tapped.
///
struct PulseButtonStyle: ButtonStyle {
	
	func makeBody(configuration: Self.Configuration) -> some View {
		configuration.label
			.scaleEffect(configuration.isPressed ? 0.9 : 1.0)
	  }
}
