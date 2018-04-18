//
//  CaptureDetailsCollectionViewController.swift
//  BioScope
//
//  Created by Timothy DenOuden on 10/13/17.
//  Copyright © 2017 Timothy DenOuden. All rights reserved.
//

import UIKit

class CaptureDetailsCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    private let headerIdentifier = "header"
    private let tagIdentifier = "tag"
    
    public var capture: Capture!
    private let sectionInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    private let itemsPerRow = CGFloat(4)
    private var cellWidth = CGFloat(0)
    private var cellHeight = CGFloat(0)
    private let captureDetailsEditSegueIdentifier = "showCaptureDetailsEdit"
    
    @IBAction func rightBarButtonItemDidPress(_ sender: Any) {
        performSegue(withIdentifier: captureDetailsEditSegueIdentifier, sender: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let flow = self.collectionViewLayout as! UICollectionViewFlowLayout
        flow.sectionInset = sectionInsets
        //let roomLeftForCells = (self.view.frame.width - (sectionInsets.left * (itemsPerRow + 1))).rounded(.down)
        //cellWidth = (roomLeftForCells / itemsPerRow).rounded(.down)
        cellWidth = 64
        cellHeight = cellWidth + 28
        flow.itemSize = CGSize(width: cellWidth, height: cellHeight)
        flow.minimumInteritemSpacing = sectionInsets.left
        flow.minimumLineSpacing = sectionInsets.left
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if(!capture.hasValidTitle()) {
            performSegue(withIdentifier: captureDetailsEditSegueIdentifier, sender: nil)
        }
        self.collectionView?.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == captureDetailsEditSegueIdentifier) {
            let newVC = segue.destination as! CaputureDetailsEditTableViewController
            newVC.capture = capture
        }
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return capture.tags.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        var reusableView : CaptureDetailsCollectionReusableView!
        if(kind == UICollectionElementKindSectionHeader) {
            reusableView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerIdentifier, for: indexPath) as! CaptureDetailsCollectionReusableView
            if(capture.hasValidTitle()) {
                reusableView.titleLabel.alpha = 1.0
                reusableView.titleLabel.text = capture.title
            }
            else {
                reusableView.titleLabel.alpha = 0.5
                reusableView.titleLabel.text = "No Title... yet!"
            }
            if let descriptionText = capture.imageDescription {
                if(descriptionText.count > 0) {
                    reusableView.decriptionLabel.alpha = 1.0
                    reusableView.decriptionLabel.text = descriptionText
                }
                else {
                    reusableView.decriptionLabel.alpha = 0.5
                    reusableView.decriptionLabel.text = "No description."
                }
            }
            else {
                reusableView.decriptionLabel.alpha = 0.5
                reusableView.decriptionLabel.text = "No description."
            }
            reusableView.tagActionButton.addTarget(self, action: #selector(CaptureDetailsCollectionViewController.tagActionButtonDidPress(sender:)), for: .touchUpInside)
            reusableView.tagActionButton.layer.masksToBounds = false
            reusableView.tagActionButton.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.8).cgColor
            reusableView.tagActionButton.layer.shadowOffset = CGSize(width: 0.0, height: 4.0)
            reusableView.tagActionButton.layer.shadowOpacity = 0.5
            reusableView.tagActionButton.layer.shadowPath = UIBezierPath(ovalIn: reusableView.tagActionButton.bounds).cgPath
        }
        return reusableView
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: tagIdentifier, for: indexPath) as! TagViewCell
        
        cell.imageView.layer.cornerRadius = cellWidth / 2
        cell.labelView.text = capture.tags[indexPath.row]
    
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: self.view.frame.width, height: 300)
    }
    
    @objc func tagActionButtonDidPress(sender: UIButton?) {
        let alert = UIAlertController(title: "New Tag", message: nil, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Add", style: UIAlertActionStyle.default, handler: { (_) in
            if let text = alert.textFields![0].text {
                if(text.count > 0) {
                    self.capture.tags.append(text)
                }
            }
            self.collectionView?.reloadData()
        }))
        alert.addTextField(configurationHandler: {(textField: UITextField!) in
            textField.placeholder = "'Cell'"
        })
        self.present(alert, animated: true, completion: nil)
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}
