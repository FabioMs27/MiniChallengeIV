//
//  NewProjectViewController.swift
//  MiniChallengeIV
//
//  Created by Murilo Teixeira on 29/04/20.
//  Copyright © 2020 Murilo Teixeira. All rights reserved.
//

import UIKit

protocol NewProjectViewControllerDelegate: AnyObject {
    func reloadList()
}

class NewProjectViewController: UIViewController {

    @IBOutlet weak var projectNameLabel: UITextField!
    @IBOutlet weak var deleteButton: UIButton!

    let projectBO = ProjectBO()
    
    var projectBean: ProjectBean?
    var projectName = String()
    var projectColor: UIColor?
    
    weak var delegate: NewProjectViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let projectBean = projectBean {
            projectNameLabel.text = projectBean.name
            deleteButton.isHidden = false
        }
        else {
            deleteButton.isHidden = true
        }
    }
    
    @IBAction func onClickColor(_ sender: UIButton) {
        if let color = sender.backgroundColor {
            projectColor = color
        }
    }
    
    @IBAction func onClickDelete(_ sender: Any) {
        projectBO.delete(uuid: projectBean!.uuid) { success, error in
            if success {
                delegate?.reloadList()
                dismiss(animated: true)
            }
            else {
                showOkAlert(title: "Error", message: error ?? "")
            }
        }
        
    }
    
    @IBAction func onClickSave(_ sender: Any) {
        delegate?.reloadList()
        saveProject()
    }
    
    @IBAction func cancelButtonAction(_ sender: Any) {
        dismiss(animated: true)
    }
    
    private func saveProject() {
        
        guard projectBean == nil else {
            projectBean?.name = projectNameLabel.text ?? ""
            projectBean?.color = projectColor
            projectBO.update(project: projectBean!) { success, error in
                if success {
                    dismiss(animated: true)
                }
                else {
                    self.showOkAlert(title: "Error", message: error ?? "")
                }
            }
            return
        }
        
        projectBO.create(name: projectNameLabel.text ?? "", color: projectColor) { success, error in
            if success {
                dismiss(animated: true)
            }
            else {
                self.showOkAlert(title: "Error", message: error ?? "")
                
            }
        }
        
    }
    
    func showOkAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true)
    }
}
