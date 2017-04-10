//
//  PAMainImageViewController.swift
//  PAPhotoArchivingTimelineView
//
//  Created by Tony Forsythe on 11/25/16.
//  Copyright © 2016 Tony Forsythe. All rights reserved.
//

import UIKit

class PAMainImageViewController: UIViewController {

    var mainImage : UIImage? {
        didSet {
            guard let img = self.mainImage else { return }
            
            self.mainImageScrollView.contentSize = img.size
            self.mainImageView.image = img
        }
    }
    
    let mainImageScrollView : UIScrollView = UIScrollView()
    let mainImageView : UIImageView = UIImageView()
    let dismissBar = UIView()
    let dismissButton = UIButton()
    var isSetup = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.setupScrollView()
        self.setupDismissControll()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func DidTapDismissButton() {
        
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    private func setupDismissControll() {
        
        //  Setup the main view
        self.view.addSubview(dismissBar)
        
        dismissBar.backgroundColor = UIColor.black
        
        dismissBar.translatesAutoresizingMaskIntoConstraints = false
        
        let dismissBarHeight : CGFloat = 60.0
        
        NSLayoutConstraint.activate([
            dismissBar.heightAnchor.constraint(equalToConstant: dismissBarHeight),
            dismissBar.leftAnchor.constraint(equalTo: self.view.leftAnchor),
            dismissBar.rightAnchor.constraint(equalTo: self.view.rightAnchor),
            dismissBar.topAnchor.constraint(equalTo: self.view.topAnchor)
            ])
        
        
        let btn = self.dismissButton
        
        
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(self.DidTapDismissButton), for: .touchUpInside)
        btn.setTitle("Dismiss", for: .normal)
        
        self.dismissBar.addSubview(btn)
        btn.sizeToFit()
        
        let bar = self.dismissBar
        
        NSLayoutConstraint.activate([
            btn.leftAnchor.constraint(equalTo: bar.leftAnchor),
            btn.topAnchor.constraint(equalTo: bar.topAnchor),
            btn.bottomAnchor.constraint(equalTo: bar.bottomAnchor)
            ])
        
    }
    
    private func setupScrollView() {
        
        self.view.addSubview(self.mainImageScrollView)
        self.mainImageScrollView.addSubview(self.mainImageView)
        
        self.view.translatesAutoresizingMaskIntoConstraints = false
        self.mainImageScrollView.translatesAutoresizingMaskIntoConstraints = false
        self.mainImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.view.leftAnchor.constraint(equalTo: self.mainImageScrollView.leftAnchor),
            self.view.topAnchor.constraint(equalTo: self.mainImageScrollView.topAnchor),
            self.view.bottomAnchor.constraint(equalTo: self.mainImageScrollView.bottomAnchor),
            self.view.rightAnchor.constraint(equalTo: self.mainImageScrollView.rightAnchor)
            ])
        
        let s = self.mainImageScrollView
        let i = self.mainImageView
        
        NSLayoutConstraint.activate([
            s.leftAnchor.constraint(equalTo: i.leftAnchor),
            s.rightAnchor.constraint(equalTo: i.rightAnchor),
            s.topAnchor.constraint(equalTo: s.topAnchor),
            s.bottomAnchor.constraint(equalTo: s.bottomAnchor)
            ])
        
        
        if let img = self.mainImage {
            s.contentSize = img.size
            i.image = img
        }
        
        isSetup = true
    }
}
