//
//  NewGroupViewController.swift
//  Commune
//
//  Created by Mukul Surajiwale on 10/31/16.
//  Copyright © 2016 Mukul Surajiwale. All rights reserved.
//

import UIKit
import Firebase

class NewGroupViewController: UIViewController {
	
	// MARK: - Outlets
	@IBOutlet weak var groupNameTextField: UITextField!
	@IBOutlet weak var groupMembersTextField: UITextField!
	
	// MARK: - Properties
	var currentUser: FIRUser? = nil
	var usersRef: FIRDatabaseReference! = nil
	
	//  Will run as soon as the view is loaded
    override func viewDidLoad() {
        super.viewDidLoad()
		self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
		self.currentUser = FIRAuth.auth()?.currentUser
		self.usersRef = FIRDatabase.database().reference(withPath: "Users")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
	
	// User wants to create a new group.
	@IBAction func createGroupButtonPressed(_ sender: Any) {
		// Remove all whitespaces from the members to add list
		let trimmed = self.groupMembersTextField.text?.replacingOccurrences(of: " ", with: "")
		// Split the string by , into an array
		let membersToAddArray = trimmed?.components(separatedBy: ",")
		// Create a new Group object based on the data
		let newGroup = Group(name: self.groupNameTextField.text!, createdBy: self.currentUser!, members: membersToAddArray!)
		// Add the created group info the the database
		newGroup.addGroupToFirebase()
		navigationController?.popViewController(animated: true)
	}
}
