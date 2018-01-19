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
    
    var task: URLSessionDownloadTask?
    
    // Create destination file url
    let documentsDirectoryURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    var tempFileName = ""
    var tempURL: URL?
    var rowNumber: Int?
    var isLessonLoading = false
    
    let playerViewController = PlayerViewController()
    
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
        let lessonStatus = lessonsStatus[indexPath.row]
        cell.nextButton.buttonCustomType = 1
        
        cell.delegate = self
        cell.lessonTitle.text = "Lesson №\(indexPath.row + 1)"
        cell.lessonStatus.text = lessonStatus
        cell.tag = indexPath.row
        
        return cell
    }
    
    func didTapNext(_ tag: Int, completionHandler: @escaping () -> ()) {
        rowNumber = tag
        
        // If during the download of one lesson, clicking on the download of another lesson will be shown Aleret Controller
        guard isLessonLoading == false
            else {
                let alert = UIAlertController(title: "Loading lesson", message: "Wait until the download is complete", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                completionHandler()
                return
        }
        
        guard let url = URL(string: lessons[tag])
            else {
                let alert = UIAlertController(title: "Wrong URL", message: nil, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                completionHandler()
                return
        }
        
        tempFileName = url.lastPathComponent
        tempURL = url
        
        // Check Lesson Status
        switch lessonsStatus[tag] {
        case "Available offline":
            play(fileName: url.lastPathComponent, tag: tag)
            completionHandler()
        case "Available online":
            
            // Remove old temp.mp3
            try? FileManager.default.removeItem(at: documentsDirectoryURL.appendingPathComponent("temp.mp3"))
            
            // Download new temp.mp3
            downloadFile(from: url, fileName: "temp.mp3") { [weak self] in
                self?.play(fileName: "temp.mp3", tag: tag)
                completionHandler()
            }
        default:
            completionHandler()
            break
        }
        
    }
    
    func didTapCancel(_ tag: Int, completionHandler: @escaping () -> ()) {
        task!.cancel()
        isLessonLoading = false
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
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
    
    func setRemoveButton() {
        let downloadButton = UIBarButtonItem(image: #imageLiteral(resourceName: "RemoveIcon"), style: .plain, target: self, action: #selector(removeFile))
        downloadButton.tintColor = Constants.buttonColor
        playerViewController.navigationItem.rightBarButtonItem = downloadButton
    }
    
    func setSaveButton() {
        let downloadButton = UIBarButtonItem(image: #imageLiteral(resourceName: "SaveIcon"), style: .plain, target: self, action: #selector(saveFile))
        downloadButton.tintColor = Constants.buttonColor
        playerViewController.navigationItem.rightBarButtonItem = downloadButton
    }
    
    // For bar remove button action
    @objc func removeFile() {
        try? FileManager.default.removeItem(at: documentsDirectoryURL.appendingPathComponent(tempFileName))
        checkURLs()
        tableView.reloadRows(at: [IndexPath.init(row: rowNumber!, section: 0)], with: .automatic)
        setSaveButton()
    }
    
    // For bar save button action
    @objc func saveFile() {
        do {
            try FileManager.default.copyItem(at: documentsDirectoryURL.appendingPathComponent("temp.mp3"), to: documentsDirectoryURL.appendingPathComponent(tempFileName))
            checkURLs()
            tableView.reloadRows(at: [IndexPath.init(row: rowNumber!, section: 0)], with: .automatic)
            setRemoveButton()
        } catch {
            downloadFile(from: tempURL!, fileName: tempFileName) { [weak self] in
                self?.tableView.reloadRows(at: [IndexPath.init(row: (self?.rowNumber)!, section: 0)], with: .automatic)
                self?.setRemoveButton()
            }
        }
    }
    
    func checkURLs() {
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
    
    func downloadFile(from url: URL, fileName: String, completionHandler: @escaping () -> ()) {
        
        // Checking internet connection
        guard Reachability.isConnectedToNetwork() else {
            let alert = UIAlertController(title: "No internet connection", message: "An internet connection is required to download the lesson. You can save lesson to device after downloading for offline access", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            completionHandler()
            return
        }
        
        let destinationURL = documentsDirectoryURL.appendingPathComponent(fileName)
        
        // Check if it exists before downloading
        if FileManager.default.fileExists(atPath: destinationURL.path) {
            print("The file already exists at path")
            completionHandler()
            // if the file doesn't exist
        } else {
            isLessonLoading = true
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            task = URLSession.shared.downloadTask(with: url) { (location, response, error) in
                DispatchQueue.main.sync {
                    guard let location = location, error == nil else { return }
                    do {
                        // Move file to destination URL after downloading
                        try FileManager.default.moveItem(at: location, to: destinationURL)
                    } catch {
                        print("--- Error: \(error)")
                        
                    }
                    self.isLessonLoading = false
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    completionHandler()
                }
                }
            task!.resume()
        }
        
    }
    
}
