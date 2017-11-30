//
//  ChatLogController.swift
//  ChatFirebase
//
//  Created by Nguyen The Phuong on 11/29/17.
//  Copyright © 2017 Nguyen The Phuong. All rights reserved.
//

import UIKit
import Firebase

class ChatLogController: UICollectionViewController, UITextFieldDelegate, UICollectionViewDelegateFlowLayout {
    let inputsHeight: CGFloat = 50
    var user: User?{
        didSet{
            navigationItem.title = user?.name
            messages.removeAll()
            observeMessages()
        }
    }
    
    var messages = [Message]()
    
    func observeMessages(){
        guard let uid = FIRAuth.auth()?.currentUser?.uid else{
            return
        }
        let userMessagesRef = FIRDatabase.database().reference().child("user-messages").child(uid)
        userMessagesRef.observe(.childAdded, with: { (snapshot) in
            let messageId = snapshot.key
            let messagesRef = FIRDatabase.database().reference().child("messages").child(messageId)
            messagesRef.observeSingleEvent(of: .value, with: { (snapshot) in
                guard let dictionary = snapshot.value as? [String: Any] else{
                    return
                }
                let message = Message()
                message.setValuesForKeys(dictionary)
                if message.getChatPartnerId() == self.user?.id{
                    self.messages.append(message)
                    DispatchQueue.main.async {
                        self.collectionView?.reloadData()
                    }
                }
                
            }, withCancel: nil)
        }, withCancel: nil)
    }
    
    lazy var inputTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter message..."
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self
        return textField
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupKeyboardGestureRecognizer()
        navigationItem.title = user?.name
        
        collectionView?.alwaysBounceVertical = true
        collectionView?.backgroundColor = .white
        collectionView?.register(ChatMessageCell.self, forCellWithReuseIdentifier: "cellId")
        var heightInset = inputsHeight
        if #available(iOS 11, *){
            heightInset += 32
        }
        collectionView?.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: heightInset, right: 0)
        collectionView?.scrollIndicatorInsets = UIEdgeInsets(top: 8, left: 0, bottom: heightInset, right: 0)
        
        setupInputComponents()
    }
    
    func setupInputComponents(){
        let containerView = UIView()
        
        containerView.backgroundColor = .white
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(containerView)
        containerView.leadingAnchor.constraint(equalTo: getSafeAreaLeadingAnchor()).isActive = true
        containerView.bottomAnchor.constraint(equalTo: getSafeAreaBottomAnchor()).isActive = true
        containerView.widthAnchor.constraint(equalTo: getSafeAreaWidthAnchor()).isActive = true
        containerView.heightAnchor.constraint(equalToConstant: inputsHeight ).isActive = true
        
        let sendButton = UIButton()
        sendButton.setTitle("Send", for: .normal)
        sendButton.setTitleColor(.blue, for: .normal)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.addTarget(self, action: #selector(handleButtonSend), for: .touchUpInside)
        
        containerView.addSubview(sendButton)
        
        sendButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
        sendButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        sendButton.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
        
        containerView.addSubview(inputTextField)
        
        inputTextField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8).isActive = true
        inputTextField.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: 8).isActive = true
        inputTextField.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        inputTextField.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
        let separatorLineView = UIView()
        separatorLineView.backgroundColor = .gray
        separatorLineView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(separatorLineView)
        
        separatorLineView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
        separatorLineView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
        separatorLineView.bottomAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        separatorLineView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
    }
    
    @objc func handleButtonSend(){
        
        let ref = FIRDatabase.database().reference().child("messages")
        let childRef = ref.childByAutoId()
        let toId = user!.id!
        let fromId = FIRAuth.auth()!.currentUser!.uid
        let timestamp = Int(NSDate().timeIntervalSince1970)
        let values: [String: Any] = ["text": inputTextField.text!, "toId": toId, "fromId": fromId, "timestamp": timestamp]
//        childRef.updateChildValues(values)
        childRef.updateChildValues(values) { (error, ref) in
            if error != nil{
                print(error!)
                return
            }
            self.inputTextField.text = nil
            let userMessageRef = FIRDatabase.database().reference().child("user-messages").child(fromId)
            let messageId = childRef.key
            userMessageRef.updateChildValues([messageId: 1])
            let recipientUserMessagesRef = FIRDatabase.database().reference().child("user-messages").child(toId)
            recipientUserMessagesRef.updateChildValues([messageId: 1])
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let text = textField.text, text.isEmpty {
            return true
        }
        handleButtonSend()
        return true
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("this is message count", messages.count)
        return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellId", for: indexPath) as! ChatMessageCell
        let message = messages[indexPath.item]
        
        setupCell(cell: cell, message: message)
        
        let estimateWidthMessage = message.text!.estimateCGrect(withConstrainedWidth: 200, font: UIFont.systemFont(ofSize: 16)).width + 32
        cell.bubbleWidthAnchor?.constant = estimateWidthMessage
        return cell
    }
    
    func setupCell(cell: ChatMessageCell, message: Message){
        cell.textView.text = message.text
        
        if let profileImageUrl = self.user?.profileImageUrl{
            cell.profileImageView.loadImageUsingCacheWithUrlString(urlString: profileImageUrl)
        }
        
        if message.fromId == FIRAuth.auth()?.currentUser?.uid{
            // outcoming blue
            cell.bubbleView.backgroundColor = UIColor().bubbleBlue
            cell.textView.textColor = .white
            cell.profileImageView.isHidden = true
            
            cell.bubbleRightAnchor?.isActive = true
            cell.bubbleLeftAnchor?.isActive = false
        } else{
            //incoming gray
            cell.bubbleView.backgroundColor = UIColor(r: 240, g: 240, b: 240)
            cell.textView.textColor = .black
            cell.profileImageView.isHidden = false
            
            cell.bubbleRightAnchor?.isActive = false
            cell.bubbleLeftAnchor?.isActive = true
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height: CGFloat = 80
        
        if let text = messages[indexPath.item].text{
            height = text.height(withConstrainedWidth: 200, font: UIFont.systemFont(ofSize: 16)) + 20
        }
        return CGSize(width: view.frame.width, height: height)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    
//    private func estimateFrameForText(text: String) -> CGRect{
//        let size = CGSize(width: 200, height: 1000)
//        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
//        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedStringKey: UIFont.systemFont(ofSize: 16)], context: nil)
//    }
}
