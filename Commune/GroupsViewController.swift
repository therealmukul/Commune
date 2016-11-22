//
//  GroupsViewController.swift
//  Commune
//
//  Created by Mukul Surajiwale on 10/29/16.
//  Copyright © 2016 Mukul Surajiwale. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import Firebase

class GroupsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
	
	// MARK: - Outlets
	@IBOutlet weak var tableView: UITableView!
	
	// MARK: - Properties
	var currentUserUID: String? = nil
	var items: [Group] = []

	//  Will run as soon as the view is loaded
    override func viewDidLoad() {
        super.viewDidLoad()
		self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
		let groupsRef = FIRDatabase.database().reference(withPath: "Users").child(currentUserUID!).child("Groups")
		
		// Attach listener to get all the users groups and see if new ones are added.
		groupsRef.observe(.value, with: { snapshot in
			var newItems: [Group] = []
			for child in snapshot.children.allObjects as! [FIRDataSnapshot] {
				print(child.key, child.value!)
				let groupItem = Group(name: child.value! as! String, groupID: child.key)
				newItems.append(groupItem)
			}
			self.items = newItems
			self.tableView.reloadData()
		})
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
	// MARK: - Actions
	
	// Take user back to their main menu
	@IBAction func backButtonPressed(_ sender: Any) {
		let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
		let vc: UIViewController = storyboard.instantiateViewController(withIdentifier: "OptionsNavigationViewController")
		self.present(vc, animated: true, completion: nil)
	}
	
	// MARK - Table View Data Source
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return items.count
	}
	
	// Create each individual table cell
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "GroupCell", for: indexPath)
		let group = items[indexPath.row]
		cell.textLabel?.text = group.name
		return cell
	}
	
	// When a user selects on a group take them to the groups info view
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		let row = indexPath.row
		let vc = storyboard?.instantiateViewController(withIdentifier: "GroupInfoViewController") as! GroupInfoViewController
		vc.groupName = items[row].name
		vc.groupID = items[row].groupID
		navigationController?.pushViewController(vc, animated: true)
	}
	
	// Allow the user to delete a group
	func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
		let group = self.items[indexPath.row]
		let groupRef = FIRDatabase.database().reference(withPath: "Groups").child(group.groupID!)
		
		if editingStyle == .delete {
			let alert = UIAlertController(title: "Delete Group", message: "Are you sure you want to delete this group?", preferredStyle: .alert)
			let addAction = UIAlertAction(title: "Yes", style: .default) { action in
				let userGroupRef = FIRDatabase.database().reference(withPath: "Users").child(self.currentUserUID!).child("Groups")
				userGroupRef.child(group.groupID!).removeValue()
				groupRef.removeValue()
			}
			
			let cancelAction = UIAlertAction(title: "No", style: .default)
			alert.addAction(addAction)
			alert.addAction(cancelAction)
			present(alert, animated: true, completion: nil)
		}
	}
}
