//
//  Language.swift
//
//  Created by JechtSh0t on 6/2/23.
//  Copyright © 2023 Brook Street Games LLC. All rights reserved.
//

struct Language: Identifiable, Equatable {
	
	let alpha2: String
	let name: String
	
	var id: String { return alpha2 }
}
