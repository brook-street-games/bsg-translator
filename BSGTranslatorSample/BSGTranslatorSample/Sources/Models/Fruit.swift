//
//  Fruit.swift
//
//  Created by JechtShot on 6/2/23.
//  Copyright © 2023 Brook Street Games LLC. All rights reserved.
//

struct Fruit: Identifiable, Equatable {
	
	let key: String
	let symbol: String
	
	var id: String { return key }
}
