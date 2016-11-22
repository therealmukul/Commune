//
//  NewIssueViewController.swift
//  Commune
//
//  Created by Mukul Surajiwale on 11/20/16.
//  Copyright © 2016 Mukul Surajiwale. All rights reserved.
//

import UIKit
import Firebase

class NewIssueViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
	
	var groupID: String? = nil
	var selectedUser: User? = User(uid: "NA", name: "NA")
	var members: [User] = []
	
	
	@IBOutlet weak var nameTextField: UITextField!
	@IBOutlet weak var descriptionTextField: UITextView!
	@IBOutlet weak var dueDatePicker: UIDatePicker!
	@IBOutlet weak var membersPicker: UIPickerView!
	@IBOutlet weak var segmentControl: UISegmentedControl!
	
	
    override func viewDidLoad() {
        super.viewDidLoad()
		dueDatePicker.datePickerMode = UIDatePickerMode.date
		
		let groupRef = FIRDatabase.database().reference(withPath: "Groups").child(groupID!).child("Members")
		
		groupRef.observe(.value, with: { snapshot in
			
			var newMembers: [User] = []
			newMembers.append(User(uid: "NA", name: "NA"))
			for child in snapshot.children.allObjects as! [FIRDataSnapshot] {
				print(child.key, child.value!)
				let newMember = User(uid: child.key, name: child.value as! String)
				newMembers.append(newMember)
			}
			
			self.members = newMembers
			self.membersPicker.reloadAllComponents()
		})

		
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	// MARK: - Actions
	
	// Allow the user to se a due date or not
	@IBAction func dueDateSegmentControlSelected(_ sender: Any) {
		if self.segmentControl.selectedSegmentIndex == 0 {
			self.dueDatePicker.isHidden = false
			self.membersPicker.frame.origin = CGPoint(x: 0, y: 370)
		} else {
			self.dueDatePicker.isHidden = !self.dueDatePicker.isHidden
			self.membersPicker.frame.origin = CGPoint(x: 0, y: 206)
		}
	}
	
	// All the user to create the issue
	@IBAction func createIssueButtonPressed(_ sender: Any) {
		if self.segmentControl.selectedSegmentIndex == 0 {
			// Has due date
			let dateFormatter = DateFormatter()
			dateFormatter.dateFormat = "MM/dd/yy"
			let dateString = dateFormatter.string(from: self.dueDatePicker.date)
			print(self.selectedUser!)
			print(self.selectedUser?.name, self.selectedUser?.uid)
			let issue = Issue(name: self.nameTextField.text!, description: self.descriptionTextField.text, dueDate: dateString, assignedTo: self.selectedUser!)
			issue.addIssueToDB(groupID: self.groupID!)
		} else {
			// Has no due date
			print(self.nameTextField.text!, self.descriptionTextField.text, self.selectedUser!)
			let issue = Issue(name: self.nameTextField.text!, description: self.descriptionTextField.text, assignedTo: self.selectedUser!)
			issue.addIssueToDB(groupID: self.groupID!)
		}
		let vc = storyboard?.instantiateViewController(withIdentifier: "IssuesViewController") as! IssuesTableViewController
		vc.groupID = self.groupID
		navigationController?.popViewController(animated: true)
	}
	
	// MARK: - Picker date source and delagate
	func numberOfComponents(in pickerView: UIPickerView) -> Int {
		return 1
	}
	
	func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		return members.count
	}
	
	func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
		return members[row].name
	}
	
	func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		self.selectedUser = members[row]
	}
}
