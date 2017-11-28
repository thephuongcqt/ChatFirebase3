//
//  ViewController.swift
//  ChatFirebase
//
//  Created by Nguyen The Phuong on 11/28/17.
//  Copyright © 2017 Nguyen The Phuong. All rights reserved.
//

import UIKit
import Firebase

class ViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        
        if FIRAuth.auth()?.currentUser?.uid == nil{
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
            handleLogout()
        }
    }

    @objc func handleLogout(){
        
        do{
            try FIRAuth.auth()?.signOut()
        } catch let logoutError{
            print(logoutError)
            return
        }
        
        let loginController = LoginController()
        present(loginController, animated: true, completion: nil)
    }
}

