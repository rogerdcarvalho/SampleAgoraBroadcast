//
//  ModeSelectionViewController.swift
//  SampleAgoraBroadcast
//
//  Created by Roger Carvalho on 03/08/2020.
//  Copyright © 2020 Roger Carvalho. All rights reserved.
//

import UIKit

class ModeSelectionViewController: UIViewController {

    
    //MARK: - Outlets

    @IBOutlet weak var speakerButton: UIStackView!
    @IBOutlet weak var audienceButton: UIStackView!
    @IBOutlet weak var speakerImage: UIImageView!
    @IBOutlet weak var audienceImage: UIImageView!
    
    //MARK: - Actions

     /// Action for Speaker Button
     @objc private func selectSpeaker(){
        performSegue(withIdentifier: AppSegue.ModeToBroadcast.rawValue, sender: self)
     }
     
     /// Action for Audience Button
     @objc private func selectAudience(){
         performSegue(withIdentifier: AppSegue.ModeToAudience.rawValue, sender: self)
     }
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        prepareUI()

    }
    
    //MARK: - Local Functions
    
    /**
     Sets up the UI for use
     */
    private func prepareUI(){
        // Make images in Button Stackviews Round
        speakerImage.makeCircular()
        audienceImage.makeCircular()
        
        // Set logo on Navigtation Bar
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        imageView.contentMode = .scaleAspectFit
        let image = UIImage(named: "Logo")
        imageView.image = image
        navigationItem.titleView = imageView
        
        // Make Button Stackviews clickable
        let speakerTap = UITapGestureRecognizer(target: self, action: #selector(ModeSelectionViewController.selectSpeaker))
        speakerButton.addGestureRecognizer(speakerTap)
        
        let audienceTap = UITapGestureRecognizer(target: self, action: #selector(ModeSelectionViewController.selectAudience))
               audienceButton.addGestureRecognizer(audienceTap)

    }
}

