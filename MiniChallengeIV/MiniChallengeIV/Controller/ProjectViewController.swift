//
//  ProjectViewController.swift
//  MiniChallengeIV
//
//  Created by Murilo Teixeira on 29/04/20.
//  Copyright © 2020 Murilo Teixeira. All rights reserved.
//

import UIKit

class ProjectViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var focusedTimeLabel: UILabel!
    @IBOutlet weak var distractionTimeLabel: UILabel!
    @IBOutlet weak var breakTimeLabel: UILabel!
    
    
    var selectedProjectId: Int?
    var projectBO = ProjectBO()
    var projects: [Project] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getCurrentStatistics()
        reloadList()
        
        
        // Do any additional setup after loading the view.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        UIApplication.shared.sendAction(#selector(UIApplication.resignFirstResponder), to: nil, from: nil, for: nil)
        view.endEditing(true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        collectionView.reloadData()
    }
    
    @IBAction func addProjectButtonAction(_ sender: Any) {
        goToNewProjectViewController()
    }
    
    @IBAction func showStatistics(_ sender: Any) {
        performSegue(withIdentifier: "statistics", sender: nil)
    }
    
    /// Go to NewProjectViewController
    private func goToNewProjectViewController() {
        if let newProjectVC = UIStoryboard.loadView(from: .NewProject, identifier: .NewProjectID) as? NewProjectViewController {
            newProjectVC.modalTransitionStyle = .crossDissolve
            newProjectVC.modalPresentationStyle = .overCurrentContext
            newProjectVC.delegate = self
            
            if let selectedProjectId = selectedProjectId {
                newProjectVC.project = projects[selectedProjectId]
                self.selectedProjectId = nil
            }
            
            self.present(newProjectVC, animated: true)
        }
    }
    
    /// Description: Function to get Statistic Data per month and year to Show on Home screen
    private func getCurrentStatistics(){
        let currentDate = Date()
        let month = Calendar.current.component(.month, from: currentDate)
        let year = Calendar.current.component(.year, from: currentDate)
        
        StatisticBO().retrieveStatisticPerMonth(month: Int32(month), year: Int32(year)) { (results) in
            switch results {
            case .success(let statistic):
                
                self.focusedTimeLabel.text = convertTime(seconds: statistic?.focusTime ?? 0)
                self.distractionTimeLabel.text = convertTime(seconds: statistic?.lostFocusTime ?? 0)
                self.breakTimeLabel.text =  convertTime(seconds: statistic?.restTime ?? 0)
                
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    /// Description:  Convert Time in seconds to show on label
    /// - Parameter seconds: time in seconds to convert
    /// - Returns: returns the time to present. Example:  01h30
    func convertTime(seconds: Int) -> String {
        let min = (seconds / 60) % 60
        let hour = seconds / 3600
        return String(format:"%2ih%02i", hour, min)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "GoToTimer" {
            if let timerViewController = segue.destination as? TimerViewController {
                guard let index = selectedProjectId else {return}
                //pass projects id to timer
                timerViewController.timeTracker.projectUuid = projects[index].id
                timerViewController.id = projects[index].id
            }
        }
    }
    
    func deleteAlert(){
        let alert = UIAlertController(title: "Delete", message: "Project has deleted!", preferredStyle: .alert)
        
        let alertAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(alertAction)
        
        self.present(alert, animated: true)
    }
}

extension ProjectViewController: ReloadProjectListDelegate {
    func reloadList(){
        projectBO.retrieve(completion: { result in
            switch result {
            case .success(let projects):
                self.projects = projects
                collectionView.reloadData()
            case .failure(let error):
                print(error.localizedDescription)
            }
        })
        
    }
}

extension ProjectViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedProjectId = indexPath.row
        performSegue(withIdentifier: "GoToTimer", sender: self)
    }

    
    /// Menu configuration
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let proj = self.projects[indexPath.row]
        
        let edit = UIAction(title: "Edit", image: UIImage(systemName: "square.and.pencil"), handler: { (edit) in
            self.selectedProjectId = indexPath.item
            self.goToNewProjectViewController()
        })
        
        let delete = UIAction(title: "Delete", image: UIImage(systemName: "trash"), attributes: .destructive ,handler: { (delete) in
            
            
            self.projectBO.delete(uuid: proj.id) { (result) in
                switch result {
                case .success():
                    self.deleteAlert()
                    self.projects.remove(at: indexPath.row)
                    collectionView.reloadData()
                    break
                case .failure(let error):
                    print(error.localizedDescription)
                    break
                }
            }
        })
        
        return UIContextMenuConfiguration(identifier: nil,
                                          previewProvider: nil) { _ in
                                            UIMenu(title: "Actions", children: [edit, delete])
        }
    }
}


extension ProjectViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //        return ProjectDAO.list.count
        return projects.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? ProjectCollectionViewCell else {
            return ProjectCollectionViewCell()
        }
        
        cell.projectNameLabel.text = projects[indexPath.row].name
        cell.backgroundColor = projects[indexPath.row].color
        
        return cell
    }
}

extension ProjectViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 2, bottom: 0, right: 2)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let collectionViewWidth = collectionView.bounds.width
        return CGSize(width: collectionViewWidth * 0.47, height: collectionViewWidth * 0.47)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 14
    }
}
