//
//  Language.swift
//
//  Created by JechtShot on 6/2/23.
//  Copyright © 2023 Brook Street Games LLC. All rights reserved.
//

struct Language: Identifiable, Equatable {
	
	let code: String
	let name: String
	
	var id: String { return code }
}
