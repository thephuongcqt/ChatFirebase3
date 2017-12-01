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
    
    var safeLeadingAnchor: NSLayoutXAxisAnchor{
        if #available(iOS 11.0, *) {
            return self.safeAreaLayoutGuide.leadingAnchor
        } else {
            return self.leadingAnchor
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
    
    var safeTrailingAnchor: NSLayoutXAxisAnchor {
        if #available(iOS 11.0, *){
            return self.safeAreaLayoutGuide.trailingAnchor
        }else {
            return self.trailingAnchor
        }
    }
    
    var safeBottomAnchor: NSLayoutYAxisAnchor {
        if #available(iOS 11.0, *) {
            return self.safeAreaLayoutGuide.bottomAnchor
        } else {
            return self.bottomAnchor
        }
    }
    
    var safeBottomPadding: CGFloat{
        if #available(iOS 11, *){
            return self.safeAreaInsets.bottom
        }
        return 0
    }
    
    var safeTopPadding: CGFloat{
        if #available(iOS 11, *){
            return self.safeAreaInsets.top
        }
        return 0
    }
    
    var safeLeftPadding: CGFloat{
        if #available(iOS 11, *){
            return self.safeAreaInsets.left
        }
        return 0
    }
    var safeRightPadding: CGFloat{
        if #available(iOS 11, *){
            return self.safeAreaInsets.right
        }
        return 0
    }
    
    var safeWidth: CGFloat{
        if #available(iOS 11, *){
            return self.safeAreaLayoutGuide.layoutFrame.width
        }
        return self.frame.width
    }
}
