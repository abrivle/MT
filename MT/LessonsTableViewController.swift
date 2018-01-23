//
//  LessonsTableViewController.swift
//  MT
//
//  Created by ILYA Abramovich on 24.12.2017.
//  Copyright © 2017 ILYA Abramovich. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class LessonsTableViewController: UITableViewController, LessonCellDelegate {
    
    var courseTitle = ""
    var lessons = [""]
    var lessonsStatus = [String]()
    
    var isLessonLoading = false
    var task: URLSessionDownloadTask?
    
    // Create destination file url
    private let documentsDirectoryURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    private var tempFileName = ""
    private var rowNumber: Int?
    
    private let playerViewController = PlayerViewController()
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
//        self.navigationController?.navigationBar.titleTextAttributes = [ NSAttributedStringKey.font: UIFont(name: "Brush Script MT", size: 16)!]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = courseTitle
        lessons.remove(at: 0)
        checkURLs()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        task?.cancel()
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lessons.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "lessonCell", for: indexPath) as! LessonTableViewCell
        cell.nextButton.buttonCustomType = 1
        
        cell.delegate = self
        cell.delegateOfVC = self
        
        if rowNumber == indexPath.row {
            cell.view.alpha = 0.5
            cell.downloadingCancelButton.isEnabled = true
            cell.progressBar.isHidden = false
        } else {
            cell.view.alpha = 0
            cell.downloadingCancelButton.isEnabled = false
            cell.progressBar.isHidden = true
        }
        
        cell.lessonTitle.text = "Lesson №\(indexPath.row + 1)"
        cell.lessonStatus.text = lessonsStatus[indexPath.row]
        cell.lessonUrl = lessons[indexPath.row]
        cell.tag = indexPath.row
        
        return cell
    }
    
    func didTapNext(_ tag: Int, completionHandler: @escaping () -> ()) {
        rowNumber = tag
        
        if let url = URL(string: lessons[tag]) {
            tempFileName = url.lastPathComponent
        }
        
        completionHandler()
    }
    
    // Cancel downloading
    func didTapCancel(_ tag: Int, completionHandler: @escaping () -> ()) {
        // Do something...
        completionHandler()
    }
    
    func play(fileName: String, tag: Int) {
        let docURL = documentsDirectoryURL.appendingPathComponent(fileName)
        let player = AVPlayer(url: docURL)
        
//        let nav = UINavigationController()
//        nav.viewControllers = [playerViewController]
        
        playerViewController.player = player
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem
        playerViewController.title = "Lesson №\(tag + 1)"
        
        // Set Right Bar Button
        switch lessonsStatus[tag] {
        case "Available offline":
            setRemoveButton()
        case "Available online":
            setSaveButton()
        default:
            break
        }
        //self.present(nav, animated: true, completion: nil)
        self.navigationController?.pushViewController(playerViewController, animated: true)
        player.play()
    }
    
    private func setRemoveButton() {
        let downloadButton = UIBarButtonItem(image: #imageLiteral(resourceName: "RemoveIcon"), style: .plain, target: self, action: #selector(removeFile))
        downloadButton.tintColor = Constants.buttonColor
        playerViewController.navigationItem.rightBarButtonItem = downloadButton
    }
    
    private func setSaveButton() {
        let downloadButton = UIBarButtonItem(image: #imageLiteral(resourceName: "SaveIcon"), style: .plain, target: self, action: #selector(saveFile))
        downloadButton.tintColor = Constants.buttonColor
        playerViewController.navigationItem.rightBarButtonItem = downloadButton
    }
    
    // For bar remove button action
    @objc private func removeFile() {
        try? FileManager.default.removeItem(at: documentsDirectoryURL.appendingPathComponent(tempFileName))
        checkURLs()
        tableView.reloadRows(at: [IndexPath(row: rowNumber!, section: 0)], with: .automatic)
        setSaveButton()
    }
    
    // For bar save button action
    @objc private func saveFile() {
        do {
            try FileManager.default.copyItem(at: documentsDirectoryURL.appendingPathComponent("temp.mp3"), to: documentsDirectoryURL.appendingPathComponent(tempFileName))
            checkURLs()
            tableView.reloadRows(at: [IndexPath(row: rowNumber!, section: 0)], with: .automatic)
            setRemoveButton()
        } catch {
            print(error)
        }
    }
    
    private func checkURLs() {
        lessonsStatus = []
        for lesson in lessons {
            if let url = URL(string: lesson) {
                let destinationUrl = documentsDirectoryURL.appendingPathComponent(url.lastPathComponent)
                
                if FileManager.default.fileExists(atPath: destinationUrl.path) {
                    lessonsStatus.append("Available offline")
                } else {
                    lessonsStatus.append("Available online")
                }
            } else {
                lessonsStatus.append("Wrong URL")
            }
        }
    }
 
}
