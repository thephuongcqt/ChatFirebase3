//
//  ChattInputContainerView.swift
//  ChatFirebase
//
//  Created by Nguyen The Phuong on 12/2/17.
//  Copyright © 2017 Nguyen The Phuong. All rights reserved.
//

import UIKit

class ChatInputContainerView: UIView, UITextFieldDelegate{
    
    static let inputsHeight: CGFloat = 50
    
    var chatLogController: ChatLogController?{
        didSet{
            sendButton.addTarget(chatLogController, action: #selector(ChatLogController.handleButtonSend), for: .touchUpInside)
            uploadImageView.addGestureRecognizer(UITapGestureRecognizer(target: chatLogController, action: #selector(ChatLogController.handleUploadTap)))
        }
    }    
    
    let sendButton = UIButton(type: .system)
    let uploadImageView: UIImageView = {
        let uploadImageView = UIImageView()
        uploadImageView.isUserInteractionEnabled = true
        uploadImageView.image = #imageLiteral(resourceName: "upload_image_icon")
        uploadImageView.translatesAutoresizingMaskIntoConstraints = false
        return uploadImageView
    }()
    
    lazy var inputTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter message..."
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self
        return textField
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        
        let separatorLineView = UIView()
        addSubview(uploadImageView)
        
        //x,y,w,h
        uploadImageView.leadingAnchor.constraint(equalTo: safeLeadingAnchor, constant: 8).isActive = true
        uploadImageView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        uploadImageView.widthAnchor.constraint(equalToConstant: 44).isActive = true
        uploadImageView.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        
        sendButton.setTitle("Send", for: UIControlState())
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(sendButton)
        //x,y,w,h
        sendButton.trailingAnchor.constraint(equalTo: safeTrailingAnchor).isActive = true
        sendButton.topAnchor.constraint(equalTo: topAnchor).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        sendButton.heightAnchor.constraint(equalToConstant: ChatInputContainerView.inputsHeight).isActive = true
        
        addSubview(self.inputTextField)
        //x,y,w,h
        inputTextField.leadingAnchor.constraint(equalTo: uploadImageView.trailingAnchor).isActive = true
        inputTextField.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: 8).isActive = true
        inputTextField.topAnchor.constraint(equalTo: topAnchor).isActive = true
        inputTextField.heightAnchor.constraint(equalToConstant: ChatInputContainerView.inputsHeight).isActive = true
        
        separatorLineView.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        separatorLineView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(separatorLineView)
        //x,y,w,h
        separatorLineView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        separatorLineView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        separatorLineView.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
        separatorLineView.heightAnchor.constraint(equalToConstant: 1).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        chatLogController?.handleButtonSend()
        return true
    }
}
