//
//  NewMessageController.swift
//  ChatFirebase
//
//  Created by Nguyen The Phuong on 11/29/17.
//  Copyright © 2017 Nguyen The Phuong. All rights reserved.
//

import UIKit
import Firebase

class NewMessageController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    var users = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.leadingAnchor.constraint(equalTo: safeLeadingAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: safeTopAnchor).isActive = true
        tableView.widthAnchor.constraint(greaterThanOrEqualTo: safeWidthAnchor).isActive = true
        tableView.heightAnchor.constraint(equalTo: safeHeightAnchor).isActive = true
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        
        tableView.register(UserCell.self, forCellReuseIdentifier: "CellId")
        fetchUser()
    }
    
    func fetchUser(){
        FIRDatabase.database().reference().child("users").observe(.childAdded, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject]{
                let user = User()
                user.setValuesForKeys(dictionary)
                user.id = snapshot.key
                self.users.append(user)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }, withCancel: nil)
    }
    
    @objc func handleCancel(){
        self.dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UserCell(style: .subtitle, reuseIdentifier: "cellId")
//        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as! UserCell
        let user = users[indexPath.item]
        cell.textLabel?.text = user.name
        cell.detailTextLabel?.text = user.email
        if let profileImageUrl = user.profileImageUrl{
            cell.profileImageView.loadImageUsingCacheWithUrlString(urlString: profileImageUrl)
        }
        
        return cell
    }
    
    var messagesController: MessageController?
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismiss(animated: true) {
            let user = self.users[indexPath.item]
            self.messagesController?.showChatControllerForUser(user: user)
        }
    }
}


