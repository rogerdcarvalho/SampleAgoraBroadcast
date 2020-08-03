//
//  UIView.swift
//  SampleAgoraBroadcast
//
//  Created by Roger Carvalho on 03/08/2020.
//  Copyright © 2020 Roger Carvalho. All rights reserved.
//
import UIKit


extension UIView {
    /**
     Turns a square view into a rounded view.
     */
    func makeCircular() {
        DispatchQueue.main.async {
            self.layer.cornerRadius = self.frame.size.width / 2
            self.clipsToBounds = true
            self.layer.borderWidth = 2.0
            self.layer.borderColor = UIColor.white.cgColor
        }
    }
}
