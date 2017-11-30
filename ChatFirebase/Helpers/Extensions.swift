//
//  Extensions.swift
//  ChatFirebase
//
//  Created by Nguyen The Phuong on 11/29/17.
//  Copyright © 2017 Nguyen The Phuong. All rights reserved.
//

import UIKit

let imageCache = NSCache<NSString, UIImage>()

extension UIImageView{
    func loadImageUsingCacheWithUrlString(urlString: String){
        self.image = nil
        //check image is cached or not
        if let cachedImage = imageCache.object(forKey: urlString as NSString){
            self.image = cachedImage
            return
        }
        
        let url = URL(string: urlString)
        URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
            if error != nil{
                print(error!)
                return
            }
            DispatchQueue.main.async {
                if let downloadImage = UIImage(data: data!){
                    imageCache.setObject(downloadImage, forKey: urlString as NSString)
                    self.image = downloadImage
                }
                
            }
        }).resume()
    }
}

extension UIViewController{
    func setupKeyboardGestureRecognizer(){
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyBoard))
        view.addGestureRecognizer(gestureRecognizer)
    }
    
    @objc func dismissKeyBoard(){
        view.endEditing(true)
    }
    
}

extension UITableViewCell {
    var tableView: UITableView? {
        var view = self.superview
        while (view != nil && view!.isKind(of: UITableView.self) == false) {
            view = view!.superview
        }
        return view as? UITableView
    }
}

extension String {
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)
        return ceil(boundingBox.height)
    }
    
    func width(withConstraintedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)
        
        return ceil(boundingBox.width)
    }
    
    func estimateCGrect(withConstrainedWidth width: CGFloat, font: UIFont) -> CGRect{
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)
        return boundingBox
    }
    
    func estimateCGrect(withConstraintedHeight height: CGFloat, font: UIFont) -> CGRect{
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)
        
        return boundingBox
    }
}

extension UIColor{
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat){
        self.init(red: r/255, green: g/255, blue: b/255, alpha: 1)
    }
    
    var bubbleBlue: UIColor{
        return UIColor(r: 0, g: 137, b: 249)
    }
}

