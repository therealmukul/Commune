
//
//  ResourceTableViewController.swift
//  Commune
//
//  Created by Mukul Surajiwale on 11/21/16.
//  Copyright © 2016 Mukul Surajiwale. All rights reserved.
//

import UIKit
import Firebase

class ResourceTableViewController: UITableViewController {
	
	// MARK: - Properties
	var groupID: String? = nil
	var resources: [Resource] = []

	//  Will run as soon as the view is loaded
    override func viewDidLoad() {
        super.viewDidLoad()
		
		let resourceRef = FIRDatabase.database().reference(withPath: "Groups").child(self.groupID!).child("Resources")
		
		// Get all resources for the group. Attach a listener to receive real time updates
		resourceRef.observe(.value, with: { snapshot in
			var newResources: [Resource] = []
			for child in snapshot.children.allObjects as! [FIRDataSnapshot] {
				let dict = child.value! as! NSDictionary
				let newResource = Resource(name: dict.value(forKey: "Name") as! String, details: dict.value(forKey: "Details") as! String, groupID: self.groupID!, resourceID: child.key)
				newResources.insert(newResource, at: 0)
			}
			self.resources = newResources
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
        return resources.count
    }

	// MARK: - Actions
	
	// Allow the user to add a new shared resource
	@IBAction func addResourceButtonPressed(_ sender: Any) {
		let alert = UIAlertController(title: "New Resource", message: "Enter Resource name and description.", preferredStyle: .alert)
		let addAction = UIAlertAction(title: "Add", style: .default) { action in
			let resourceName = alert.textFields![0] as UITextField
			let resourceDescription = alert.textFields![1] as UITextField
			
			let resourceRef = FIRDatabase.database().reference(withPath: "Groups").child(self.groupID!).child("Resources")
			resourceRef.childByAutoId().setValue(["Name" : resourceName.text, "Details" : resourceDescription.text])
			
		}
		
		let cancelAction = UIAlertAction(title: "Cancel", style: .default)
		alert.addTextField()
		alert.addTextField()
		alert.addAction(addAction)
		alert.addAction(cancelAction)
		present(alert, animated: true, completion: nil)
	}
	
	// Create each resource table view cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ResourceCell", for: indexPath)
        let resource = self.resources[indexPath.row]
		cell.textLabel?.text = resource.name
		cell.detailTextLabel?.text = resource.details

        return cell
    }
	
	// Allow the user to delete a resource
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
			let resource = resources[indexPath.row]
			let resourceRef = FIRDatabase.database().reference(withPath: "Groups").child(self.groupID!).child("Resources")
			resourceRef.child(resource.resourceID!).removeValue()
        }
    }
}
