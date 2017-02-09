//
//  PAAboutPageViewController.swift
//  PAPhotoArchivingTimelineView
//
//  Created by Tony Forsythe on 12/10/16.
//  Copyright © 2016 Tony Forsythe. All rights reserved.
//

import UIKit

class PAAboutPageViewController: UIViewController {

    let aboutTextView = UITextView()
    let dismissButton = UIButton()
    let generator = TFTextViewTextGenerator()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.setupViews()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    private func setupViews() {
        
        var frm = self.view.frame
        
        frm.PASetOriginToZero()
        
        aboutTextView.frame = frm
        aboutTextView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(aboutTextView)
        
        aboutTextView.text = self.getAboutString()
        
        aboutTextView.alignToTopOfParent(with: 0.0)
        aboutTextView.alignToLeftOfParent(with: 0.0)
        aboutTextView.alignToRightOfParent(with: 0.0)
        aboutTextView.setHeight(self.view.frame.height - 50.0)
        
        frm.size.height = 50.0
        frm.size.width = 100.0
        
        dismissButton.frame = frm
        dismissButton.translatesAutoresizingMaskIntoConstraints = false
        
        dismissButton.PASetTitleString("Dismiss", font: Font.PABoldFontWithSize(size: 20.0), color: Color.PADarkBlue, state: .normal)
        dismissButton.addTarget(self, action: #selector(self.didTapDismiss(sender:)), for: .touchUpInside)
        
        self.view.addSubview(dismissButton)
        
        dismissButton.centerHorizontally()
        dismissButton.setHeight(50.0)
        dismissButton.alignToBottomOfParent(with: 0.0)
        
        
        
        
    }
    
    func didTapDismiss( sender : UIButton ) {
        
        self.dismiss(animated: true, completion: nil)
    }
    private func getAboutString() -> String {
        
        let g = self.generator
        
        
        g.addPiece(with: "Author", value: "Anthony Forsythe")
        g.addPiece(with: "Last Updated", and: Date())
        g.addPiece(with: "Assignment Overview", value: "The was the final project for CS3380 at the University of Missouri - Columbia in the Fall 2016 semester")
        g.addPiece(with: "Project Overview", value: "The PhotoArchiving project, as it exists outside of CS3380, aims to archive the photographs of a family and to conserve their oral tradition. Many families have a box, or sometimes boxes, of photographs that have been passed from generation to generation. These photographs can span centuries of a family’s history and an incredibly important but often overlooked part of these photographs are the stories associated with them. Audio that adds a richness, depth, and intimacy that is so often lost over time. This application is basically a reader and player for information and multimedia stored in Firebase. There are three basic data entities: the Repository, the Photograph, and the Story. ")
        
        
        
        return self.generator.getString()
    }
}
