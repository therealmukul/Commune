//
//  Group.swift
//  Commune
//
//  Created by Mukul Surajiwale on 10/30/16.
//  Copyright © 2016 Mukul Surajiwale. All rights reserved.
//

import UIKit
import Firebase

class Group: NSObject {
	
	let name: String
	var createdBy: FIRUser? = nil
	var members: [String] = []
	var groupID: String? = nil
	var groupsRef = FIRDatabase.database().reference(withPath: "Groups")
	var groupCreated = false
	
	// Contructor
	init(name: String, createdBy: FIRUser, members: Array<String>) {
		self.name = name
		self.createdBy = createdBy
		self.members = members
	}
	
	// Constructor for group item
	init(name: String, groupID: String) {
		self.name = name
		self.groupID = groupID
	}
	
	// Add a new group the databaswe
	func addGroupToFirebase() -> Void {
		print(members)
		
		// Add group reference
		let groupRef = groupsRef.childByAutoId()
		groupRef.setValue(["CreatorUid" : createdBy?.uid, "Name" : name])
		
		// Add the group to the user
		let usersRef = FIRDatabase.database().reference(withPath: "Users")
		
		// Check to see if the user is logged in through Facebook or email.
		if createdBy?.displayName != nil {
			groupRef.child("Members").setValue([(createdBy?.uid)! : (createdBy?.displayName)!])
			groupRef.child("MonetaryContributions").setValue([(createdBy?.uid)! : 0.0])
			usersRef.child((createdBy?.uid)!).child("Groups").child(groupRef.key).setValue(self.name)
			addMembers(members: members, usersRef: usersRef, groupRef: groupRef)
		} else {
			usersRef.queryOrdered(byChild: "Email").queryEqual(toValue: createdBy?.email).observeSingleEvent(of: .value, with: { snapshot in
				if !snapshot.exists() {
					print("USER NOT FOUND")
				}
				for child in snapshot.children.allObjects as! [FIRDataSnapshot] {
					let dict = child.value as! NSDictionary
					groupRef.child("Members").setValue([child.key : dict["Name"]!])
					groupRef.child("MonetaryContributions").setValue([child.key : 0.0])
					usersRef.child(child.key).child("Groups").child(groupRef.key).setValue(self.name)
				}
				self.addMembers(members: self.members, usersRef: usersRef, groupRef: groupRef)
			})
		}
	}
	
	// Query the databse to find all the matching users and then add them to the group.
	func addMembers(members: Array<String>, usersRef: FIRDatabaseReference, groupRef: FIRDatabaseReference) -> Void {
		for member in members {
			usersRef.observeSingleEvent(of: .value, with: { (snapshot) in
				var found = false
				for child in snapshot.children.allObjects as! [FIRDataSnapshot] {
					let dict = child.value as! NSDictionary
					if dict["Email"] != nil {
						if dict["Email"] as! String == member {
							groupRef.child("Members").child(child.key).setValue(dict["Name"]!)
							groupRef.child("MonetaryContributions").child(child.key).setValue(0.0)
							usersRef.child(child.key).child("Groups").child(groupRef.key).setValue(self.name)
							found = true
						}
					}
				}
				
				if found == false {
					print("User not found")
				}
			})
		}
	}
	
	
}
