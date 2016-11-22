//
//  User.swift
//  Commune
//
//  Created by Mukul Surajiwale on 10/30/16.
//  Copyright © 2016 Mukul Surajiwale. All rights reserved.
//

import UIKit
import Foundation
import Firebase

class User: NSObject {
	
	var uid: String?
	var name: String?
	var email: String?
	
	init(uid: String, name: String, email: String) {
		self.uid = uid
		self.name = name
		self.email = email
	}
	
	init(uid: String, name: String) {
		self.uid = uid
		self.name = name
	}
	
}
