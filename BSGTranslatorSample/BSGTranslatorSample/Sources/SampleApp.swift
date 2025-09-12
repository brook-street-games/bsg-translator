//
//  SampleApp.swift
//
//  Created by JechtShot on 6/1/23.
//  Copyright © 2023 Brook Street Games LLC. All rights reserved.
//

import SwiftUI

@main
struct SampleApp: App {
	
	var body: some Scene {
		WindowGroup {
			SampleView(viewModel: SampleViewModel())
		}
	}
}
