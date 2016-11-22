//
//  GroupMembersTableViewController.swift
//  Commune
//
//  Created by Mukul Surajiwale on 11/19/16.
//  Copyright © 2016 Mukul Surajiwale. All rights reserved.
//

import UIKit
import Firebase

class GroupMembersTableViewController: UITableViewController {

	// MARK: - Properties
	var groupID: String? = nil
	var groupName: String? = nil
	var members: [User] = []
	var errorCount: Int = 0
	let usersRef = FIRDatabase.database().reference(withPath: "Users")
	
	//  Will run as soon as the view is loaded
    override func viewDidLoad() {
        super.viewDidLoad()
		let groupRef = FIRDatabase.database().reference(withPath: "Groups").child(groupID!).child("Members")
		
		// Get all the members of a group. Listen for updates from the database
		groupRef.observe(.value, with: { snapshot in
			var newMembers: [User] = []
			for child in snapshot.children.allObjects as! [FIRDataSnapshot] {
				print(child.key, child.value!)
				let newMember = User(uid: child.key, name: child.value as! String)
				newMembers.append(newMember)
			}
			self.members = newMembers
			self.tableView.reloadData()
		})
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return members.count
    }

	// Create the group member cells
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GroupMemberCell", for: indexPath)
		let member = members[indexPath.row]
		cell.textLabel?.text = member.name!
        return cell
    }

	// Allow a user to delete a member from the group.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let member = members[indexPath.row]
			// Remove reference from groups
			let groupMembersRef = FIRDatabase.database().reference(withPath: "Groups").child(groupID!).child("Members").child(member.uid!)
			groupMembersRef.removeValue()
			// Remove reference from users
			let userGroupsRef = FIRDatabase.database().reference(withPath: "Users").child(member.uid!).child("Groups").child(self.groupID!)
			userGroupsRef.removeValue()
        }
    }
	
	// User wants to add a new member to the group.
	@IBAction func addMemberButtonPressed(_ sender: Any) {
		let alert = UIAlertController(title: "Add Member", message: "Enter users email address", preferredStyle: .alert)
		let addAction = UIAlertAction(title: "Add", style: .default) { action in
			let memberEmail = alert.textFields![0]
			self.usersRef.observeSingleEvent(of: .value, with: { (snapshot) in
				for child in snapshot.children.allObjects as! [FIRDataSnapshot] {
					let dict = child.value as! NSDictionary
					if dict["Email"] != nil {
						if dict["Email"] as! String == memberEmail.text! {
							FIRDatabase.database().reference(withPath: "Groups").child(self.groupID!).child("Members").child(child.key).setValue(dict["Name"]!)
							FIRDatabase.database().reference(withPath: "Users").child(child.key).child("Groups").child(self.groupID!).setValue(self.groupName!)
							FIRDatabase.database().reference(withPath: "Groups").child(self.groupID!).child("MonetaryContributions").child(child.key).setValue(0.0)
							return
						}
					}
				}
				self.showErrorAlert(error: "User does not exist")
				return
			})
		}
		let cancelAction = UIAlertAction(title: "Cancel", style: .default)
		alert.addTextField()
		alert.addAction(addAction)
		alert.addAction(cancelAction)
		present(alert, animated: true, completion: nil)
	}
	
	// Helper function to display error message related alert view
	func showErrorAlert(error: String) -> Void {
		let alert = UIAlertController(title: "Error", message: error, preferredStyle: .alert)
		let okAction = UIAlertAction(title: "Ok", style: .default)
		alert.addAction(okAction)
		present(alert, animated: true, completion: nil)
	}
}
