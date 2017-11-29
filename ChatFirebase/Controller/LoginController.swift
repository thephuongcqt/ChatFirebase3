//
//  LoginController.swift
//  ChatFirebase
//
//  Created by Nguyen The Phuong on 11/28/17.
//  Copyright © 2017 Nguyen The Phuong. All rights reserved.
//
import UIKit
import Firebase

class LoginController: UIViewController {
    
    let inputsContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        return view
    }()
    
    let loginRegisterButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor(r: 0, g: 101, b: 161)
        button.setTitle("Register", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 16)
        button.addTarget(self, action: #selector(handleLoginRegister), for: .touchUpInside)
        return button
    }()
    
    let nameTextField: UITextField = {
       let tf = UITextField()
        tf.placeholder = "Name"
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    let emailTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Email Address"
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    let passwordTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Password"
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.isSecureTextEntry = true
        return tf
    }()
    
    let nameSeperatorView: UIView = {
       let view = UIView()
        view.backgroundColor = .gray
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let emailSeperatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .gray
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = #imageLiteral(resourceName: "image_profile")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectProfileImageView)))
        imageView.isUserInteractionEnabled = true
        
        return imageView
    }()
    
    let loginRegisterSegmentedControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["Login", "Register"])
        sc.translatesAutoresizingMaskIntoConstraints = false
        sc.tintColor = .white
        sc.selectedSegmentIndex = 1
        sc.addTarget(self, action: #selector(handleLoginRegisterChange), for: .valueChanged)
        return sc
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        view.backgroundColor = UIColor(red: 62/255, green: 92/255, blue: 151/255, alpha: 1)
        view.backgroundColor = UIColor(r: 62, g: 92, b: 151)
        
        view.addSubview(inputsContainerView)
        view.addSubview(loginRegisterButton)
        view.addSubview(profileImageView)
        view.addSubview(loginRegisterSegmentedControl)
        
        setupInputsContainerView()
        setupLoginRegisterButton()
        setupProfileImageView()
        setupLoginRegisterSegmentedControl()
    }
    
    @objc func handleLoginRegister(){
        if(loginRegisterSegmentedControl.selectedSegmentIndex == 0){
            handleLogin()
        } else{
            handleRegister()
        }
    }
    
    func handleLogin(){
        guard let email = emailTextField.text, let password = passwordTextField.text else {
            return
        }
        FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user, error) in
            if error != nil{
                print(error!)
                return
            }
            self.dismiss(animated: true, completion: nil)
        })
    }
    
    func handleRegister(){
        guard let email = emailTextField.text, let password = passwordTextField.text, let name = nameTextField.text else {
            return
        }
        FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user, error) in
            if error != nil{
                print(error!)
                return
            }
            guard let uid = user?.uid else{
                return
            }
            //successfully authenticated user
            let imageName = NSUUID().uuidString
            let storageRef = FIRStorage.storage().reference().child("profile_images").child("\(imageName).png")
            if let uploadData = UIImagePNGRepresentation(self.profileImageView.image!){
                storageRef.put(uploadData, metadata: nil, completion: { (metadata, error) in
                    if error != nil{
                        print(error!) 
                        return
                    }
                    if let profileImageUrl = metadata?.downloadURL()?.absoluteString{
                        let values = ["name": name, "email": email, "profileImageUrl": profileImageUrl]
                        self.registerUserIntoDatabaseWidthUID(uid: uid, values: values)
                    }
                })
            }
            
            
            
        })
    }
    
    private func registerUserIntoDatabaseWidthUID(uid: String, values: [String : String]){
        let ref = FIRDatabase.database().reference(fromURL: "https://chatfirebase-1e377.firebaseio.com/")
        
        let userReference = ref.child("users").child(uid)
        userReference.updateChildValues(values, withCompletionBlock: { (error, ref) in
            if error != nil{
                print(error!)
                return
            }
            print("Save user successfully into Firebase db")
            self.dismiss(animated: true, completion: nil)
        })
    }
    
    @objc func handleLoginRegisterChange(){
        let title = loginRegisterSegmentedControl.titleForSegment(at: loginRegisterSegmentedControl.selectedSegmentIndex)
        loginRegisterButton.setTitle(title, for: .normal)
        
        //change height of inputsContainerView
        nameTextFieldHeightAnchor?.isActive = false
        emailTextFieldHeightAnchor?.isActive = false
        passwordTextFieldHeightAnchor?.isActive = false
        
        let index = loginRegisterSegmentedControl.selectedSegmentIndex
        
        inputsContainerViewHeightAnchor?.constant = index == 0 ? 100 : 150
        nameTextFieldHeightAnchor = nameTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: index == 0 ? 0 : 1/3)
        emailTextFieldHeightAnchor = emailTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: index == 0 ? 1/2 : 1/3)
        passwordTextFieldHeightAnchor = passwordTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: index == 0 ? 1/2 : 1/3)

        nameTextFieldHeightAnchor?.isActive = true
        emailTextFieldHeightAnchor?.isActive = true
        passwordTextFieldHeightAnchor?.isActive = true
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    
    func setupLoginRegisterSegmentedControl(){
        loginRegisterSegmentedControl.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loginRegisterSegmentedControl.bottomAnchor.constraint(equalTo: inputsContainerView.topAnchor, constant: -12).isActive = true
        loginRegisterSegmentedControl.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        loginRegisterSegmentedControl.heightAnchor.constraint(equalToConstant: 40).isActive = true
    }
    
    func setupProfileImageView(){
        let aspectRatio: CGFloat = {
            var ratio = profileImageView.image?.size.width ?? 0
            ratio /= profileImageView.image?.size.height ?? 1
            return ratio != 0 ? ratio : 1
        }()
        let newWidth: CGFloat = 150
        let newHeight = newWidth / aspectRatio
        
        
        profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        profileImageView.bottomAnchor.constraint(equalTo: loginRegisterSegmentedControl.topAnchor, constant: -12).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: newWidth).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: newHeight).isActive = true
    }
    
    var inputsContainerViewHeightAnchor: NSLayoutConstraint?
    var nameTextFieldHeightAnchor: NSLayoutConstraint?
    var emailTextFieldHeightAnchor: NSLayoutConstraint?
    var passwordTextFieldHeightAnchor: NSLayoutConstraint?
    
    func setupInputsContainerView(){
        inputsContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        inputsContainerView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        inputsContainerView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -24).isActive = true
        inputsContainerViewHeightAnchor = inputsContainerView.heightAnchor.constraint(equalToConstant: 150)
        inputsContainerViewHeightAnchor?.isActive = true
//        inputsContainerView.heightAnchor.constraint(equalToConstant: 150).isActive = true
        
        inputsContainerView.addSubview(nameTextField)
        inputsContainerView.addSubview(nameSeperatorView)
        inputsContainerView.addSubview(emailTextField)
        inputsContainerView.addSubview(emailSeperatorView)
        inputsContainerView.addSubview(passwordTextField)
        
        nameTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        nameTextField.topAnchor.constraint(equalTo: inputsContainerView.topAnchor).isActive = true
        nameTextField.leadingAnchor.constraint(equalTo: inputsContainerView.leadingAnchor, constant: 12).isActive = true
        nameTextFieldHeightAnchor =  nameTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/3)
        nameTextFieldHeightAnchor?.isActive = true
        
        nameSeperatorView.leadingAnchor.constraint(equalTo: inputsContainerView.leadingAnchor).isActive = true
        nameSeperatorView.topAnchor.constraint(equalTo: nameTextField.bottomAnchor).isActive = true
        nameSeperatorView.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        nameSeperatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        emailTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        emailTextField.topAnchor.constraint(equalTo: nameSeperatorView.bottomAnchor).isActive = true
        emailTextField.leadingAnchor.constraint(equalTo: inputsContainerView.leadingAnchor, constant: 12).isActive = true
        emailTextFieldHeightAnchor = emailTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/3)
        emailTextFieldHeightAnchor?.isActive = true
        
        emailSeperatorView.leadingAnchor.constraint(equalTo: inputsContainerView.leadingAnchor).isActive = true
        emailSeperatorView.topAnchor.constraint(equalTo: emailTextField.bottomAnchor).isActive = true
        emailSeperatorView.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        emailSeperatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        passwordTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        passwordTextField.topAnchor.constraint(equalTo: emailSeperatorView.bottomAnchor).isActive = true
        passwordTextField.leadingAnchor.constraint(equalTo: inputsContainerView.leadingAnchor, constant: 12).isActive = true
        passwordTextFieldHeightAnchor =  passwordTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/3)
        passwordTextFieldHeightAnchor?.isActive = true
    }
    
    func setupLoginRegisterButton(){
        loginRegisterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loginRegisterButton.topAnchor.constraint(equalTo: inputsContainerView.bottomAnchor, constant: 12).isActive = true
        loginRegisterButton.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        loginRegisterButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
}

extension UIColor{
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat){
        self.init(red: r/255, green: g/255, blue: b/255, alpha: 1)
    }
}
