//
//  GroupInfoViewController.swift
//  Commune
//
//  Created by Mukul Surajiwale on 11/19/16.
//  Copyright © 2016 Mukul Surajiwale. All rights reserved.
//

import UIKit
import Firebase

class GroupInfoViewController: UIViewController {

	// MARK: - Properties
	var groupName: String? = nil
	var groupID: String? = nil
	
	// MARK: - Outlets
	@IBOutlet weak var groupNameLabel: UILabel!
	@IBOutlet weak var groupIDLabel: UILabel!
	
	//  Will run as soon as the view is loaded
    override func viewDidLoad() {
        super.viewDidLoad()
		groupNameLabel.text = groupName
		groupIDLabel.text = groupID
		self.groupIDLabel.isHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
	
	// MARK: - Actions
	
	// Take user to the members view
	@IBAction func showMembersButtonPressed(_ sender: Any) {
		let vc = storyboard?.instantiateViewController(withIdentifier: "GroupMembersViewController") as! GroupMembersTableViewController
		vc.groupID = self.groupID
		vc.groupName = self.groupName
		navigationController?.pushViewController(vc, animated: true)
	}
	
	// Take user to the issues view
	@IBAction func showIssuesButtonPressed(_ sender: Any) {
		let vc = storyboard?.instantiateViewController(withIdentifier: "IssuesViewController") as! IssuesTableViewController
		vc.groupID = self.groupID
		navigationController?.pushViewController(vc, animated: true)
	}
	
	// Take user to the resources view
	@IBAction func showResourcesButtonPressed(_ sender: Any) {
		let vc = storyboard?.instantiateViewController(withIdentifier: "ResourcesViewController") as! ResourceTableViewController
		vc.groupID = self.groupID
		navigationController?.pushViewController(vc, animated: true)
	}
	
	// Remove user the group
	@IBAction func leaveGroupButtonPressed(_ sender: Any) {
		let user = FIRAuth.auth()?.currentUser
		
		// Remove the group reference from the Users node
		let userGroupsRef = FIRDatabase.database().reference(withPath: "Users").child((user?.uid)!).child("Groups")
		userGroupsRef.child(self.groupID!).removeValue()
		
		// Remove the group reference from the Groups node
		let groupMembers = FIRDatabase.database().reference(withPath: "Groups").child(self.groupID!).child("Members")
		groupMembers.observeSingleEvent(of: .value, with: { snapshot in
			for child in snapshot.children.allObjects as! [FIRDataSnapshot] {
				if child.key == user?.uid {
					groupMembers.child(child.key).removeValue()
				}
			}
		})
		navigationController?.popViewController(animated: true)
	}
}
