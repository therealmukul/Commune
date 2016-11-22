
//
//  Resource.swift
//  Commune
//
//  Created by Mukul Surajiwale on 11/21/16.
//  Copyright © 2016 Mukul Surajiwale. All rights reserved.
//

import UIKit

class Resource: NSObject {
	var name: String? = nil
	var details: String? = nil
	var groupID: String? = nil
	var resourceID: String? = nil
	
	init(name: String, details: String, groupID: String, resourceID: String) {
		self.name = name
		self.details = details
		self.groupID = groupID
		self.resourceID = resourceID
	}
	
}
