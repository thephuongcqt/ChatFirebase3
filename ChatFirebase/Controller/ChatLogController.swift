//
//  ChatLogController.swift
//  ChatFirebase
//
//  Created by Nguyen The Phuong on 11/29/17.
//  Copyright © 2017 Nguyen The Phuong. All rights reserved.
//

import UIKit
import Firebase
import MobileCoreServices
import AVFoundation

class ChatLogController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    lazy var collectionView: UICollectionView = {
        let collection = UICollectionView(frame: self.view.frame, collectionViewLayout: UICollectionViewFlowLayout())
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.backgroundColor = .white
        return collection
    }()
    lazy var bottomPadding: CGFloat = {
        var padding = view.safeBottomPadding + ChatInputContainerView.inputsHeight
        print("padding", padding)
        return padding
    }()
    
    var user: User?{
        didSet{
            navigationItem.title = user?.name
            messages.removeAll()
            observeMessages()
        }
    }
    
    var messages = [Message]()
    
    
    
    // MARK: Input accessory
    
    lazy var inputContainerView: ChatInputContainerView = {
        let chatInputContainerView = ChatInputContainerView()
        chatInputContainerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: ChatInputContainerView.inputsHeight + view.safeBottomPadding)
        chatInputContainerView.chatLogController = self
        return chatInputContainerView
    }()
    
    override var inputAccessoryView: UIView? {
        get {
            return inputContainerView
        }
    }
    
    override var canBecomeFirstResponder : Bool {
        return true
    }
    
    // MARK: Controller lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupKeyboardGestureRecognizer()
        navigationItem.title = user?.name
        view.addSubview(collectionView)
        view.backgroundColor = .white
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.alwaysBounceVertical = true
        collectionView.register(ChatMessageCell.self, forCellWithReuseIdentifier: "cellId")
        
        collectionView.leadingAnchor.constraint(equalTo: safeLeadingAnchor).isActive = true
        collectionView.topAnchor.constraint(equalTo: safeTopAnchor).isActive = true
        collectionView.widthAnchor.constraint(equalTo: safeWidthAnchor).isActive = true
        collectionView.heightAnchor.constraint(equalTo: safeHeightAnchor).isActive = true
        
//        collectionView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: ChatInputContainerView.inputsHeight + 8, right: 0)
//        if #available(iOS 11, *){
//            collectionView.contentInsetAdjustmentBehavior = .always
//        } else{
//            self.automaticallyAdjustsScrollViewInsets = false
//        }
        collectionView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)

        collectionView.keyboardDismissMode = .interactive
        
        setupKeyboardObservers()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    // MARK: handle pick image
    
    @objc func handleUploadTap() {
        let imagePickerController = UIImagePickerController()
        
        imagePickerController.allowsEditing = true
        imagePickerController.delegate = self
        imagePickerController.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String  ]
        
        present(imagePickerController, animated: true, completion: nil)
    }
    
    fileprivate func uploadToFirebaseStorageUsingImage(_ image: UIImage, completion: @escaping (_ imageUrl: String) -> ()) {
        let imageName = UUID().uuidString
        let ref = FIRStorage.storage().reference().child("message_images").child(imageName)
        
        if let uploadData = UIImageJPEGRepresentation(image, 0.2) {
            ref.put(uploadData, metadata: nil, completion: { (metadata, error) in
                
                if error != nil {
                    print("Failed to upload image:", error!)
                    return
                }
                
                if let imageUrl = metadata?.downloadURL()?.absoluteString {
                    completion(imageUrl)
//                    self.sendMessageWithImageUrl(imageUrl: imageUrl, image: image)
                }
                
            })
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let videoUrl = info[UIImagePickerControllerMediaURL] as? URL{
            handleVideoSelectedFor(url: videoUrl)
        } else{
            handleImageSelectedFor(info: info)
        }
        dismiss(animated: true, completion: nil)
    }
    
    private func handleVideoSelectedFor(url: URL){
        let fileName = NSUUID().uuidString + ".mov"
        let uploadTask = FIRStorage.storage().reference().child("message_movies").child(fileName).putFile(url, metadata: nil, completion: { (metadata, error) in
            if error != nil{
                print(error!)
                return
            }
            
            if let videoUrl = metadata?.downloadURL()?.absoluteString{
                print(videoUrl)
                if let thumbnailImage = self.thumbnailImageFor(fileUrl: url){
                    
                    self.uploadToFirebaseStorageUsingImage(thumbnailImage, completion: { (imageUrl) in
                        let properties: [String: Any] = ["imageUrl" : imageUrl,"videoUrl" : videoUrl, "imageWidth" : thumbnailImage.size.width, "imageHeight": thumbnailImage.size.height]
                        self.sendMessageWith(properties: properties)
                    })
                }
                
            }
        })
        
        uploadTask.observe(.progress) { (snapshot) in
            if let completedUnitCount = snapshot.progress?.completedUnitCount, let totalUnitCount = snapshot.progress?.totalUnitCount{
                let uploadPercentage : Float64 = Float64(completedUnitCount) * 100 / Float64(totalUnitCount)
                self.navigationItem.title = "Uploading: " + String(format:"%.0f", uploadPercentage) + "%"
            }
        }
        uploadTask.observe(.success) { (snapshot) in
            self.navigationItem.title = self.user?.name
        }
    }
    
    private func thumbnailImageFor(fileUrl: URL) -> UIImage?{
        let asset = AVAsset(url: fileUrl)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        do{
            let thumbnailCGImage = try imageGenerator.copyCGImage(at: CMTimeMake(1, 60), actualTime: nil)
            return UIImage(cgImage: thumbnailCGImage)
        } catch let err{
            print(err)
        }
        return nil
    }
    
    private func handleImageSelectedFor(info: [String: Any]){
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            selectedImageFromPicker = editedImage
        } else if let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            uploadToFirebaseStorageUsingImage(selectedImage, completion: { (imageUrl) in
                self.sendMessageWithImageUrl(imageUrl: imageUrl, image: selectedImage)
            })
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: setup keyboard observer
    func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardDidShow), name: .UIKeyboardDidShow, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
//
//        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @objc func handleKeyboardDidShow(notification: NSNotification){
        if messages.count > 0{
            let keyboardFrame = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
            var bottom = (keyboardFrame?.height) ?? (bottomPadding)
            bottom -= (view.safeBottomPadding - 8)
            
//            if #available(iOS 11, *){
//                collectionView.contentInsetAdjustmentBehavior = .always
//            } else{
//                self.automaticallyAdjustsScrollViewInsets = false
//            }
//
//            collectionView.contentInset.top = 8
            collectionView.contentInset.bottom = bottom
            
            if let height = keyboardFrame?.height, height > bottomPadding{
                DispatchQueue.main.async {
                    if self.messages.count > 0{
                        let indexPath = IndexPath(item: self.messages.count - 1, section: 0)
                        self.collectionView.scrollToItem(at: indexPath, at: .top, animated: true)
                    }
                }
            }
        }
    }
    
    @objc func handleKeyboardWillShow(_ notification: Notification) {
        let keyboardFrame = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
        let keyboardDuration = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue
        
//        containerViewBottomAnchor?.constant = -keyboardFrame!.height
        UIView.animate(withDuration: keyboardDuration!, animations: {
            self.view.layoutIfNeeded()
        }) 
    }
    
    @objc func handleKeyboardWillHide(_ notification: Notification) {
        let keyboardDuration = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue
        
//        containerViewBottomAnchor?.constant = 0
        UIView.animate(withDuration: keyboardDuration!, animations: {
            self.view.layoutIfNeeded()
        }) 
    }
    
    // MARK: Handle send messages
    @objc func handleButtonSend(){
        let properties: [String: Any] = ["text": inputContainerView.inputTextField.text!]
        sendMessageWith(properties: properties)
    }
    
    fileprivate func sendMessageWithImageUrl(imageUrl: String, image: UIImage) {
        let properties: [String: Any] = ["imageUrl": imageUrl, "imageWidth" : image.size.width, "imageHeight": image.size.height]
        sendMessageWith(properties: properties)
    }
    
    
    
    func sendMessageWith(properties: [String: Any]){
        let ref = FIRDatabase.database().reference().child("messages")
        let childRef = ref.childByAutoId()
        let toId = user!.id!
        let fromId = FIRAuth.auth()!.currentUser!.uid
        let timestamp = Int(NSDate().timeIntervalSince1970)
        var values: [String: Any] = ["toId": toId, "fromId": fromId, "timestamp": timestamp]
        
        for (key, value) in properties{
            values[key] = value
        }
        
        childRef.updateChildValues(values) { (error, ref) in
            if error != nil{
                print(error!)
                return
            }
            self.inputContainerView.inputTextField.text = nil
            
            let userMessagesRef = FIRDatabase.database().reference().child("user-messages").child(fromId).child(toId)
            
            let messageId = childRef.key
            userMessagesRef.updateChildValues([messageId: 1])
            
            let recipientUserMessagesRef = FIRDatabase.database().reference().child("user-messages").child(toId).child(fromId)
            recipientUserMessagesRef.updateChildValues([messageId: 1])
        }
    }
    
    // MARK: UICollectionViewController method
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("this is message count", messages.count)
        return messages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellId", for: indexPath) as! ChatMessageCell
        cell.chatLogController = self
        let message = messages[indexPath.item]
        cell.message = message
        cell.textView.text = message.text
        
        setupCell(cell, message: message)
        
        if let text = message.text{
            cell.textView.isHidden = false
            let estimateWidthMessage = text.estimateCGrect(withConstrainedWidth: 200, font: UIFont.systemFont(ofSize: 16)).width + 32
            cell.bubbleWidthAnchor?.constant = estimateWidthMessage
        } else if message.imageUrl != nil{
            cell.textView.isHidden = true
            cell.bubbleWidthAnchor?.constant = 200
        }
        cell.playButton.isHidden = message.videoUrl == nil
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height: CGFloat = 80
        let message = messages[indexPath.item]
        if let text = message.text{
            height = text.height(withConstrainedWidth: 200, font: UIFont.systemFont(ofSize: 16)) + 20
        } else if let imageWidth = message.imageWidth?.floatValue, let imageHeight = message.imageHeight?.floatValue {
            height  = CGFloat(200 * imageHeight / imageWidth)
        }
        return CGSize(width: view.safeWidth, height: height)
    }
    
    fileprivate func setupCell(_ cell: ChatMessageCell, message: Message) {
        if let profileImageUrl = self.user?.profileImageUrl {
            cell.profileImageView.loadImageUsingCacheWithUrlString(urlString: profileImageUrl)
        }
        
        if message.fromId == FIRAuth.auth()?.currentUser?.uid {
            //outgoing blue
            cell.bubbleView.backgroundColor = UIColor().bubbleBlue
            cell.textView.textColor = UIColor.white
            cell.profileImageView.isHidden = true
            
            cell.bubbleViewRightAnchor?.isActive = true
            cell.bubbleViewLeftAnchor?.isActive = false
            
        } else {
            //incoming gray
            cell.bubbleView.backgroundColor = UIColor(r: 240, g: 240, b: 240)
            cell.textView.textColor = UIColor.black
            cell.profileImageView.isHidden = false
            
            cell.bubbleViewRightAnchor?.isActive = false
            cell.bubbleViewLeftAnchor?.isActive = true
        }
        
        if let messageImageUrl = message.imageUrl {
            cell.messageImageView.loadImageUsingCacheWithUrlString(urlString: messageImageUrl)
            cell.messageImageView.isHidden = false
            cell.bubbleView.backgroundColor = UIColor.clear
        } else {
            cell.messageImageView.isHidden = true
        }
    }
    
    // MARK: observe messages
    
    func observeMessages(){
        guard let uid = FIRAuth.auth()?.currentUser?.uid, let toId = user?.id else{
            return
        }
        let userMessagesRef = FIRDatabase.database().reference().child("user-messages").child(uid).child(toId)
        userMessagesRef.observe(.childAdded, with: { (snapshot) in
            let messageId = snapshot.key
            let messagesRef = FIRDatabase.database().reference().child("messages").child(messageId)
            messagesRef.observeSingleEvent(of: .value, with: { (snapshot) in
                guard let dictionary = snapshot.value as? [String: Any] else{
                    return
                }
                let message = Message(dictionary: dictionary)
                self.messages.append(message)
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                    // scroll to the last index
                    if self.messages.count > 0{
                        let indexPath = IndexPath(item: self.messages.count - 1, section: 0)
                        self.collectionView.scrollToItem(at: indexPath, at: .bottom, animated: true)
                    }
                }
            }, withCancel: nil)
        }, withCancel: nil)
    }
    
    // MARK: My custom zooming logic
    
    var startingFrame: CGRect?
    var blackBackgroundView: UIView?
    var startingImageView: UIImageView?
    
    func performZoomInFor(startingImageView: UIImageView){
//        let startingFrame = startingImageView.superview?.convert(startingImageView.frame, to: nil)
        self.startingImageView = startingImageView
        self.startingImageView?.isHidden = true
        startingFrame = startingImageView.convert(startingImageView.frame, to: nil)
        let zoomingImageView = UIImageView(frame: startingFrame!)
        zoomingImageView.backgroundColor = .red
        zoomingImageView.image = startingImageView.image
        zoomingImageView.isUserInteractionEnabled = true
        zoomingImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomOut)))
        
        if let keyWindow = UIApplication.shared.keyWindow{
            blackBackgroundView = UIView(frame: keyWindow.frame)
            blackBackgroundView?.backgroundColor = .black
            blackBackgroundView?.alpha = 0
            
            keyWindow.addSubview(blackBackgroundView!)
            keyWindow.addSubview(zoomingImageView)
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                
                self.blackBackgroundView!.alpha = 1
                self.inputContainerView.alpha = 0
                let height = keyWindow.frame.width * self.startingFrame!.height / self.startingFrame!.width
                zoomingImageView.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: height)
                zoomingImageView.center = keyWindow.center
                
            }, completion: { (completed) in
                //do no thing
            })
            
//            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
//                self.blackBackgroundView!.alpha = 1
//                self.inputContainerView.alpha = 0
//                let height = keyWindow.frame.width * self.startingFrame!.height / self.startingFrame!.width
//                zoomingImageView.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: height)
//                zoomingImageView.center = keyWindow.center
//            }, completion: nil)
        }
    }
    
    @objc func handleZoomOut(tapGesture: UITapGestureRecognizer){
        if let zoomOutImageView = tapGesture.view{
            // need to animate back out to controller
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                
                self.inputContainerView.alpha = 1
                zoomOutImageView.layer.cornerRadius = 16
                zoomOutImageView.layer.masksToBounds = true
                self.blackBackgroundView?.alpha = 0
                zoomOutImageView.frame = self.startingFrame!
                
            }, completion: { (completed) in
                zoomOutImageView.removeFromSuperview()
                self.startingImageView?.isHidden = false
            })
        }
    }
    
}
