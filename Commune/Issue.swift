//
//  Issue.swift
//  Commune
//
//  Created by Mukul Surajiwale on 11/20/16.
//  Copyright © 2016 Mukul Surajiwale. All rights reserved.
//

import UIKit
import Firebase

class Issue: NSObject {
	var name: String? = nil
	var dueDate: String? = "NA"
	var desc: String? = nil
	var assignedTo: User? = User(uid: "NA", name: "NA")
	var issueID: String? = nil
	var creatorID: String? = nil
	var completed: String? = "False"
	var groupID: String? = nil
	
	
	init(name: String, description: String, dueDate: String, assignedTo: User) {
		self.name = name
		self.desc = description
		self.dueDate = dueDate
		self.assignedTo = assignedTo
	}
	
	init(name: String, description: String, assignedTo: User) {
		self.name = name
		self.desc = description
		self.assignedTo = assignedTo
	}
	
	init(name: String, description: String, dueDate: String) {
		self.name = name
		self.desc = description
		self.dueDate = dueDate
	}
	
	init(name: String, description: String) {
		self.name = name
		self.desc = description
	}
	
	init(name: String, description: String, dueDate: String, assignedTo: User, issueID: String, completed: String, groupID: String) {
		self.name = name
		self.desc = description
		self.dueDate = dueDate
		self.assignedTo = assignedTo
		self.issueID = issueID
		self.completed = completed
		self.groupID = groupID
	}
	
	init(name: String, description: String, assignedTo: User, issueID: String, completed: String, groupID: String) {
		self.name = name
		self.desc = description
		self.assignedTo = assignedTo
		self.issueID = issueID
		self.completed = completed
		self.groupID = groupID
	}
	
	init(name: String, description: String, dueDate: String, issueID: String, completed: String, groupID: String) {
		self.name = name
		self.desc = description
		self.dueDate = dueDate
		self.issueID = issueID
		self.completed = completed
		self.groupID = groupID
	}
	
	init(name: String, description: String, issueID: String, completed: String, groupID: String) {
		self.name = name
		self.desc = description
		self.issueID = issueID
		self.completed = completed
		self.groupID = groupID
	}
	
	
	func addIssueToDB(groupID: String) -> Void {
		let issuesRef = FIRDatabase.database().reference(withPath: "Groups").child(groupID).child("Issues")
		let issueRef = issuesRef.childByAutoId()
		
		issueRef.child("Name").setValue(self.name)
		issueRef.child("Description").setValue(self.desc)
		issueRef.child("DueDate").setValue(self.dueDate)
		issueRef.child("Completed").setValue(self.completed)
		issueRef.child("AssignedTo").setValue(["UserName" : assignedTo?.name, "UserID" : assignedTo?.uid])
		
		if assignedTo?.name != "NA" {
			let userRef = FIRDatabase.database().reference(withPath: "Users").child((assignedTo?.uid)!).child("Issues")
			userRef.child(issueRef.key).setValue(["Name" : self.name!, "Description" : self.desc!, "DueDate" : self.dueDate!, "Completed" : self.completed!, "GroupID" : groupID])
		}
		
	}
	
}
