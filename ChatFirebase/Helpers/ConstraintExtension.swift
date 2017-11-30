//
//  ConstraintExtension.swift
//  ChatFirebase
//
//  Created by Nguyen The Phuong on 11/30/17.
//  Copyright © 2017 Nguyen The Phuong. All rights reserved.
//

import UIKit

extension UIViewController{
    
    // support programmatically for ios 9, 10, 11
    // support safeAreaLayoutGuide for ios 11
    // begin constraint function
    func getSafeAreaTopAnchor() -> NSLayoutAnchor<NSLayoutYAxisAnchor>{
        if #available(iOS 11, *){
            return view.safeAreaLayoutGuide.topAnchor
        } else{
            return view.topAnchor
        }
    }
    
    func getSafeAreaBottomAnchor() -> NSLayoutAnchor<NSLayoutYAxisAnchor>{
        if #available(iOS 11, *){
            return view.safeAreaLayoutGuide.bottomAnchor
        } else{
            return view.bottomAnchor
        }
    }
    
    func getSafeAreaLeadingAnchor() -> NSLayoutAnchor<NSLayoutXAxisAnchor>{
        if #available(iOS 11, *){
            return view.safeAreaLayoutGuide.leadingAnchor
        } else{
            return view.leadingAnchor
        }
    }
    
    func getSafeAreaLeftAnchor() -> NSLayoutAnchor<NSLayoutXAxisAnchor>{
        if #available(iOS 11, *){
            return view.safeAreaLayoutGuide.leftAnchor
        } else{
            return view.leftAnchor
        }
    }
    
    func getSafeAreaRightAnchor() -> NSLayoutAnchor<NSLayoutXAxisAnchor>{
        if #available(iOS 11, *){
            return view.safeAreaLayoutGuide.rightAnchor
        } else{
            return view.rightAnchor
        }
    }
    
    func getSafeAreaTrailingAnchor() -> NSLayoutAnchor<NSLayoutXAxisAnchor>{
        if #available(iOS 11, *){
            return view.safeAreaLayoutGuide.trailingAnchor
        } else{
            return view.trailingAnchor
        }
    }
    
    func getSafeAreaWidthAnchor() -> NSLayoutAnchor<NSLayoutDimension>{
        if #available(iOS 11, *){
            return view.safeAreaLayoutGuide.widthAnchor
        } else{
            return view.widthAnchor
        }
    }
    
    func getSafeAreaHeightAnchor() -> NSLayoutAnchor<NSLayoutDimension>{
        if #available(iOS 11, *){
            return view.safeAreaLayoutGuide.heightAnchor
        } else{
            return view.heightAnchor
        }
    }
    
    // end constraint function
    
    // begin constraint properties
    var safeHeightAnchor: NSLayoutAnchor<NSLayoutDimension> {
        return getSafeAreaHeightAnchor()
    }
    
    var safeWidthAnchor: NSLayoutAnchor<NSLayoutDimension> {
        return getSafeAreaWidthAnchor()
    }
    
    var safeLeadingAnchor: NSLayoutAnchor<NSLayoutXAxisAnchor> {
        return getSafeAreaLeadingAnchor()
    }
    
    var safeLeftingAnchor: NSLayoutAnchor<NSLayoutXAxisAnchor> {
        return getSafeAreaLeftAnchor()
    }
    
    var safetrailingAnchor: NSLayoutAnchor<NSLayoutXAxisAnchor> {
        return getSafeAreaTrailingAnchor()
    }
    
    var safeRightAnchor: NSLayoutAnchor<NSLayoutXAxisAnchor> {
        return getSafeAreaRightAnchor()
    }
    
    var safeTopAnchor: NSLayoutAnchor<NSLayoutYAxisAnchor>{
        return getSafeAreaTopAnchor()
    }
    
    var safeBottomAnchor: NSLayoutAnchor<NSLayoutYAxisAnchor>{
        return getSafeAreaBottomAnchor()
    }
    // end constraint properties
}


extension UIView {    
    var safeTopAnchor: NSLayoutYAxisAnchor {
        if #available(iOS 11.0, *) {
            return self.safeAreaLayoutGuide.topAnchor
        } else {
            return self.topAnchor
        }
    }
    
    var safeLeftAnchor: NSLayoutXAxisAnchor {
        if #available(iOS 11.0, *){
            return self.safeAreaLayoutGuide.leftAnchor
        }else {
            return self.leftAnchor
        }
    }
    
    var safeRightAnchor: NSLayoutXAxisAnchor {
        if #available(iOS 11.0, *){
            return self.safeAreaLayoutGuide.rightAnchor
        }else {
            return self.rightAnchor
        }
    }
    
    var safeBottomAnchor: NSLayoutYAxisAnchor {
        if #available(iOS 11.0, *) {
            return self.safeAreaLayoutGuide.bottomAnchor
        } else {
            return self.bottomAnchor
        }
    }
}
