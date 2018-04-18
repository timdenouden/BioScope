//
//  CaptureDetailsEditTableTableViewController.swift
//  BioScope
//
//  Created by Timothy DenOuden on 11/4/17.
//  Copyright © 2017 Timothy DenOuden. All rights reserved.
//

import UIKit

class CaputureDetailsEditTableViewController: UITableViewController, UITextViewDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var saveButton: UIButton!
    
    var capture : Capture!
    let captureDetailsFromSaveSegueIdentifier = "showCaptureDetailsFromSave"
    
    @IBAction func saveButtonDidPress(_ sender: Any) {
        capture.title = titleTextField.text!
        capture.imageDescription = descriptionTextView.text
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func deleteButtonDidPress(_ sender: Any) {
        let alert = UIAlertController(title: nil, message: "Are you sure you want to delete this capture?", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Delete Label", style: .destructive, handler: { _ in
            if let baseVC = self.navigationController?.viewControllers[0] {
                self.navigationController?.popToViewController(baseVC, animated: true)
            }
            
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    
    @IBAction func titleTextFieldDidEdit(_ sender: Any) {
        updateSaveButton()
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        descriptionTextView.becomeFirstResponder()
        let indexPath = IndexPath(row: 0, section: 1)
        self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
        return true
    }
    
    public func textViewDidChange(_ textView: UITextView) {
        updateSaveButton()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleTextField.delegate = self
        descriptionTextView.delegate = self
        titleTextField.text = capture.title
        descriptionTextView.text = capture.imageDescription
        updateSaveButton()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    private func updateSaveButton() {
        if(titleTextField.text!.count > 0) {
            saveButton.alpha = 1.0
            saveButton.isEnabled = true
        }
        else {
            saveButton.alpha = 0.5
            saveButton.isEnabled = false
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(indexPath.section == 0) {
            titleTextField.becomeFirstResponder()
        }
        else if(indexPath.section == 1) {
            descriptionTextView.becomeFirstResponder()
        }
    }
    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == captureDetailsFromSaveSegueIdentifier) {
            let newVC = segue.destination as! CaptureDetailsCollectionViewController
            newVC.capture = capture
        }
    }

}
