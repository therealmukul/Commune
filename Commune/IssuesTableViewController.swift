//
//  IssuesTableViewController.swift
//  Commune
//
//  Created by Mukul Surajiwale on 11/19/16.
//  Copyright © 2016 Mukul Surajiwale. All rights reserved.
//

import UIKit
import Firebase

class IssuesTableViewController: UITableViewController {
	
	// MARK: - Properties
	var groupID: String? = nil
	var issues: [Issue] = []
	
	//  Will run as soon as the view is loaded
    override func viewDidLoad() {
        super.viewDidLoad()

		let issuesRef = FIRDatabase.database().reference(withPath: "Groups").child(groupID!).child("Issues")
		
		// Get all the issues for a group. Attach a listener to check fro updates
		issuesRef.observe(.value, with: { snapshot in
			var newIssues: [Issue] = []
			for child in snapshot.children.allObjects as! [FIRDataSnapshot] {
				let dict = child.value! as! NSDictionary
				if dict.count < 5 {
					continue
				} else {
					if dict["DueDate"] != nil {
						if dict["AssignedTo"] != nil {
							// Has name, description, due date, and assigned user
							let userDict = dict["AssignedTo"] as! NSDictionary
							
							let user = User(uid: userDict.value(forKey: "UserID") as! String, name: userDict.value(forKey: "UserName") as! String)
							let newIssue = Issue(name: dict.value(forKey: "Name") as! String, description: dict.value(forKey: "Description") as! String,
							                     dueDate: dict.value(forKey: "DueDate") as! String, assignedTo: user, issueID: child.key,
							                     completed: dict.value(forKey: "Completed") as! String, groupID: child.key)
							newIssues.insert(newIssue, at: 0)
						} else {
							// Has name, description, and due date
							let newIssue = Issue(name: dict.value(forKey: "Name") as! String, description: dict.value(forKey: "Description") as! String,
							                     dueDate: dict.value(forKey: "DueDate") as! String, issueID: child.key,
							                     completed: dict.value(forKey: "Completed") as! String, groupID: child.key)
							newIssues.insert(newIssue, at: 0)
						}
					} else {
						if dict["AssignedTo"] != nil {
							// Has name, description, and an assinged user
							let userDict = dict["AssignedTo"] as! NSDictionary
							let user = User(uid: userDict.value(forKey: "UserID") as! String, name: userDict.value(forKey: "UserName") as! String)
							let newIssue = Issue(name: dict.value(forKey: "Name") as! String, description: dict.value(forKey: "Description") as! String,
							                     assignedTo: user, issueID: child.key, completed: dict.value(forKey: "Completed") as! String, groupID: child.key)
							newIssues.insert(newIssue, at: 0)
						} else {
							// Has name and description
							let newIssue = Issue(name: dict.value(forKey: "Name") as! String, description: dict.value(forKey: "Description") as! String,
							                     issueID: child.key, completed: dict.value(forKey: "Completed") as! String, groupID: child.key)
							newIssues.insert(newIssue, at: 0)
						}
					}
				}
			}
			self.issues = newIssues
			self.tableView.reloadData()
		})
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

	// MARK: - Actions
	
	// Take user to the add issue view
	@IBAction func addNewIssueButtonPressed(_ sender: Any) {
		let vc = storyboard?.instantiateViewController(withIdentifier: "NewIssueViewController") as! NewIssueViewController
		vc.groupID = self.groupID
		navigationController?.pushViewController(vc, animated: true)
	}
	
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return issues.count
    }

	// Create the issue table view cells
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "IssueCell", for: indexPath)
		let issue = issues[indexPath.row]
		
		// If the issue is marked as completed then make the text light gray
		if issue.completed == "True" {
			cell.textLabel?.textColor = UIColor.lightGray
			cell.detailTextLabel?.textColor = UIColor.lightGray
		} else {
			cell.textLabel?.textColor = UIColor.black
			cell.detailTextLabel?.textColor = UIColor.black
		}
		cell.textLabel?.text = issue.name!
		cell.detailTextLabel?.text = issue.desc!
        return cell
    }

	// Take a user to the issues detail view
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		let row = indexPath.row
		let vc = storyboard?.instantiateViewController(withIdentifier: "IssueDetailViewController") as! IssueDetailViewController
		let issue = issues[row]
		vc.issueID = issue.issueID
		vc.groupID = self.groupID
		navigationController?.pushViewController(vc, animated: true)
	}
	
	// Customize the swipe to delete option
	override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
		let deleteButton = UITableViewRowAction(style: .default, title: "Complete", handler: { (action, indexPath) in
			self.tableView.dataSource?.tableView!(self.tableView, commit: .delete, forRowAt: indexPath)
			return
		})
		deleteButton.backgroundColor = UIColor.green
		return [deleteButton]
	}
	
    // Allow a user to mark an issue as complete
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
			let issue = issues[indexPath.row]
			let groupIssuesRef = FIRDatabase.database().reference(withPath: "Groups").child(groupID!).child("Issues").child(issue.issueID!)
			groupIssuesRef.updateChildValues(["Completed" : "True"])
			if issue.assignedTo?.name != "NA" {
				let userIssuesRef = FIRDatabase.database().reference(withPath: "Users").child((issue.assignedTo?.uid)!).child("Issues").child(issue.issueID!)
				userIssuesRef.updateChildValues(["Completed" : "True"])
			}
			
			let alert = UIAlertController(title: "Monetary Contribution", message: "If it cost anything to complete this issue, then enter the amount an press 'Yes'", preferredStyle: .alert)
			let addAction = UIAlertAction(title: "Add", style: .default) { action in
				let valueTextField = alert.textFields![0]
				let value = Float(valueTextField.text!)
				let user = FIRAuth.auth()?.currentUser
				
				FIRDatabase.database().reference(withPath: "Groups").child(self.groupID!).child("MonetaryContributions").child((user?.uid)!).observeSingleEvent(of: .value, with: { (snapshot) in
					let contribution = snapshot.value as! Float
					FIRDatabase.database().reference(withPath: "Groups").child(self.groupID!).child("MonetaryContributions").child((user?.uid)!).setValue(value! + contribution)
				})

			}
			let cancelAction = UIAlertAction(title: "No", style: .default)
			alert.addTextField()
			alert.addAction(addAction)
			alert.addAction(cancelAction)
			present(alert, animated: true, completion: nil)
        }
    }
}
