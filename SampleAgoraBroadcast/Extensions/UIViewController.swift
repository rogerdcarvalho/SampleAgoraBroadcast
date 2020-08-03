//
//  UIViewController.swift
//  SampleAgoraBroadcast
//
//  Created by Roger Carvalho on 03/08/2020.
//  Copyright © 2020 Roger Carvalho. All rights reserved.
//

import Foundation
import UIKit
extension UIViewController {

    /**
     Displays an alert box.
     - parameter message: The message to be shown
     */
    func displayAlert(message: String) {
        
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Notice",
                                      message: message,
                                      preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Close",
                                      style: UIAlertAction.Style.default,
                                      handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
    /**
     Asks the user for 1 or more inputs
     - parameter title: The title of the dialog box
     - parameter message: The message of the dialog box
     - parameter numberOfTextfields: The number of inputs supported
     - parameter placeholderText: The placeholder text for each of the inputs
     - parameter action: The action that should be called once the user has entered data
     */
    func displayInput(title: String,
                      message: String,
                      text: [String]?,
                      numberOfTextFields: Int?,
                      placeholderText: [String]?,
                      action: @escaping ([String]) -> Void) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        var textField: UITextField?
        var textFields = [UITextField]()
        

        let numberOfTextFields = numberOfTextFields ?? 1
        for index in 0...(numberOfTextFields - 1) {
            alert.addTextField { (renderedTextField) in
                renderedTextField.text = text?[index]
                renderedTextField.placeholder = placeholderText?[index]
                textField = renderedTextField
                textField?.autocapitalizationType = UITextAutocapitalizationType.words
                textFields.append(textField!)
            }
        }
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
            var results = [String]()
            for textField in textFields {
                if let result = textField.text {
                    results.append(result)
                } else {
                    results.append("")
                }
            }
            action(results)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
}
