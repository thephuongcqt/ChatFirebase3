//
//  ViewController.swift
//  ChatFirebase
//
//  Created by Nguyen The Phuong on 11/28/17.
//  Copyright © 2017 Nguyen The Phuong. All rights reserved.
//

import UIKit
import Firebase

class MessageController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(tableView)
        
        tableView.leadingAnchor.constraint(equalTo: safeLeadingAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: safeTopAnchor).isActive = true
        tableView.widthAnchor.constraint(greaterThanOrEqualTo: safeWidthAnchor).isActive = true
        tableView.heightAnchor.constraint(equalTo: safeHeightAnchor).isActive = true
        
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        let image = #imageLiteral(resourceName: "new_message_icon")
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(handleNewMessage))
        
        checkIfUserLoggedIn()
        
        tableView.register(UserCell.self, forCellReuseIdentifier: "cellId")
        tableView.delegate = self
        tableView.dataSource = self
//        observeMessage()
    }
    
    func observeUserMessages(){
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {
            return
        }
        let ref = FIRDatabase.database().reference().child("user-messages").child(uid)
        ref.observe(.childAdded, with: { (snapshot) in
            let messageId = snapshot.key
            let messageReference = FIRDatabase.database().reference().child("messages").child(messageId)
            messageReference.observeSingleEvent(of: .value, with: { (snapshot) in
                
                print(snapshot)
                if let dictionary = snapshot.value as? [String: Any]{
                    let message = Message()
                    message.setValuesForKeys(dictionary)
                    
                    if let chatPartnerId = message.getChatPartnerId() {
                        self.messagesDictionary[chatPartnerId] = message
                        self.messages = Array(self.messagesDictionary.values)
                        self.messages.sort(by: { (message1, message2) -> Bool in
                            if let time1 = message1.timestamp?.intValue, let time2 = message2.timestamp?.intValue{
                                return time1 > time2
                            }
                            return false
                        })
                    }
                    self.timer?.invalidate()
                    self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
                }
                
            }, withCancel: nil)
            
        }, withCancel: nil)
    }
    
    var timer: Timer?
    
    @objc func handleReloadTable(){
        DispatchQueue.main.async {
            print("We reloaded the table ")
            self.tableView.reloadData()
        }
    }
    
    var messages = [Message]()
    var messagesDictionary = [String: Message]()
    
    func observeMessage(){
        let ref = FIRDatabase.database().reference().child("messages")
        ref.observe(.childAdded, with: { (snapshot) in
            print(snapshot)
            if let dictionary = snapshot.value as? [String: Any]{
                let message = Message()
                message.setValuesForKeys(dictionary)
                
                if let toId = message.toId {
                    self.messagesDictionary[toId] = message
                    self.messages = Array(self.messagesDictionary.values)
                    self.messages.sort(by: { (message1, message2) -> Bool in
                        if let time1 = message1.timestamp?.intValue, let time2 = message2.timestamp?.intValue{
                            return time1 > time2
                        }
                        return false
                    })
                }
                
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }, withCancel: nil)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cellId")
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as! UserCell
        let message = messages[indexPath.row]
        cell.message = message
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let message = messages[indexPath.row]
        guard let chatPartnerId = message.getChatPartnerId() else{
            return
        }
        let ref = FIRDatabase.database().reference().child("users").child(chatPartnerId)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: Any]{
                let user = User()
                user.setValuesForKeys(dictionary)
                user.id = chatPartnerId
                
                
                self.showChatControllerForUser(user: user)
            }
            
        }, withCancel: nil)
    }
    
    @objc func handleNewMessage(){
        let newMessageController = NewMessageController()
        newMessageController.messagesController = self
        let navController = UINavigationController(rootViewController: newMessageController)
        present(navController, animated: true, completion: nil)
    }
    
    func checkIfUserLoggedIn(){
        if FIRAuth.auth()?.currentUser?.uid == nil{
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
            handleLogout()
        } else{
            fetchUserAndSetupNavBarTitle()
        }
    }
    
    func fetchUserAndSetupNavBarTitle(){
        guard let uid = FIRAuth.auth()?.currentUser?.uid else{
            return
        }
        FIRDatabase.database().reference().child("users").child(uid).observeSingleEvent(of: .value, andPreviousSiblingKeyWith: { (snapshot, string) in
            if let dictionary = snapshot.value as? [String: Any]{
//                self.navigationItem.title = dictionary["name"] as? String
                let user = User()
                user.setValuesForKeys(dictionary)
                self.setupNavBarWithUser(user: user)
                            }
        }, withCancel: nil)
    }
    
    func setupNavBarWithUser(user: User){
        messages.removeAll()
        messagesDictionary.removeAll()
        tableView.reloadData()
        observeUserMessages()
        
        self.navigationItem.title = user.name
        
        let titleView = UIButton()
        titleView.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        titleView.addSubview(containerView)
        
        let profileImageView = UIImageView()
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.cornerRadius = 20
        profileImageView.layer.masksToBounds = true
//        profileImageView.clipsToBounds = true
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        if let profileImageUrl = user.profileImageUrl{
            profileImageView.loadImageUsingCacheWithUrlString(urlString: profileImageUrl)
        }
        
        containerView.addSubview(profileImageView)

//        setup constraint
        profileImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        let nameLabel = UILabel()
        nameLabel.text = user.name
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(nameLabel)

        nameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 8).isActive = true
        nameLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        nameLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
        nameLabel.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
        containerView.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
        containerView.centerXAnchor.constraint(equalTo: titleView.centerXAnchor).isActive = true
        containerView.heightAnchor.constraint(equalTo: titleView.heightAnchor).isActive = true
    
//        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(showChatControllerForUser(user: nil)))
//        nameLabel.isUserInteractionEnabled = true
//        profileImageView.isUserInteractionEnabled = true
        titleView.isUserInteractionEnabled = true
//        nameLabel.addGestureRecognizer(tapGestureRecognizer)
//        profileImageView.addGestureRecognizer(tapGestureRecognizer)
//        titleView.addTarget(self, action: #selector(showChatController), for: .touchUpInside)
//        titleView.addGestureRecognizer(tapGestureRecognizer)
        self.navigationItem.titleView = titleView
    }
    
    @objc func showChatControllerForUser(user: User){
        let chatLogController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        chatLogController.user = user
        
        navigationController?.pushViewController(chatLogController, animated: true)
    }

    @objc func handleLogout(){
        
        do{
            try FIRAuth.auth()?.signOut()
        } catch let logoutError{
            print(logoutError)
            return
        }
        
        let loginController = LoginController()
        loginController.messageController = self
        present(loginController, animated: true, completion: nil)
    }
}

