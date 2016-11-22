//
//  OptionsViewController.swift
//  Commune
//
//  Created by Mukul Surajiwale on 11/19/16.
//  Copyright © 2016 Mukul Surajiwale. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit

class OptionsViewController: UIViewController {

	// MARK: - Outlets
	@IBOutlet weak var usernameLabel: UILabel!
	@IBOutlet weak var userEmailLabel: UILabel!
	
	// MARK: - Properties
	var currentUserUID: String? = nil
	
	// Will run as soon as the view is loaded
    override func viewDidLoad() {
        super.viewDidLoad()
		
		self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
		
		// Make sure that the current user is authenticated.
		FIRAuth.auth()?.addStateDidChangeListener { auth, user in
			if user != nil {
				// user is already logged in. Check to see if they are logged in via FB or email.
				if user?.displayName != nil {
					// Logged in via FB
					self.usernameLabel.text = user?.displayName
					self.userEmailLabel.text = user?.email
					self.currentUserUID = user?.uid
				} else {
					// Logged in via custom email
					let usersRef = FIRDatabase.database().reference(withPath: "Users")
					usersRef.queryOrdered(byChild: "Email").queryEqual(toValue: user?.email).observeSingleEvent(of: .value, with: { snapshot in
						for child in snapshot.children.allObjects as! [FIRDataSnapshot] {
							let dict = child.value as! NSDictionary
							let name = dict["Name"]!
							self.usernameLabel.text = name as? String
							self.userEmailLabel.text = dict["Email"] as? String
							self.currentUserUID = child.key
						}
					})
				}
			} else {
				// Go back to the login view if the user is authenticated
				let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
				let vc: UIViewController = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
				self.present(vc, animated: true, completion: nil)
			}
		}
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
	
	// MARK: - Actions
	
	// Log the user out of the application
	@IBAction func logoutButtonPressed(_ sender: Any) {
		try! FIRAuth.auth()!.signOut()
		FBSDKLoginManager().logOut()
		let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
		let vc: UIViewController = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
		self.present(vc, animated: true, completion: nil)
	}
	
	// Take the user to the Groups View
	@IBAction func viewGroupsButtonPressed(_ sender: Any) {
		let vc = storyboard?.instantiateViewController(withIdentifier: "GroupsViewController") as! GroupsViewController
		vc.currentUserUID = self.currentUserUID!
		navigationController?.pushViewController(vc, animated: true)
		
	}
}
