//
//  BrowseViewController.swift
//  BioScope
//
//  Created by Timothy DenOuden on 7/1/17.
//  Copyright © 2017 Timothy DenOuden. All rights reserved.
//

import UIKit

class BrowseViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var searchView: UIView!
    
    private let reuseIdentifier = "CaptureCell"
    private let detailSegueIdentifier = "showCaptureDetail"
    private let sectionInsets = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
    private let itemsPerRow = CGFloat(2)
    private var cellWidth = CGFloat(0)
    private var captures = [Capture]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        CaptureStorageManager.firstRunSetup()
        
        searchView.layer.cornerRadius = searchView.layer.frame.height / 2
        
        collectionView.dataSource = self
        collectionView.delegate = self
        let flow = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        flow.sectionInset = sectionInsets
        let roomLeftForCells = (self.view.frame.width - (sectionInsets.left * (itemsPerRow + 1))).rounded(.down)
        cellWidth = (roomLeftForCells / itemsPerRow).rounded(.down)
        flow.itemSize = CGSize(width: cellWidth, height: cellWidth)
        flow.minimumInteritemSpacing = sectionInsets.left
        flow.minimumLineSpacing = sectionInsets.left
    }
    
    override func viewDidAppear(_ animated: Bool) {
        captures = CaptureStorageManager.getAllCaptures()
        collectionView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: detailSegueIdentifier, sender: captures[indexPath.row])
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return captures.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CaptureViewCell
        
        cell.imageView.image = captures[indexPath.row].squarePreviewWith(width: cellWidth)
        cell.contentView.layer.cornerRadius = 4
        cell.imageView.layer.cornerRadius = 4
        cell.imageView.layer.masksToBounds = true
        return cell
    }

    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == detailSegueIdentifier {
            let destination = segue.destination as! CaptureViewController
            destination.capture = sender as? Capture
        }
    }
}
