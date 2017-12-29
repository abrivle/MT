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
import CoreData

class LessonsTableViewController: UITableViewController, LessonCellDelegate {
    
    var courseTitle = ""
    var lessons = [""]
    var lessonsStatus = [String]()
    
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
        guard isLessonLoading == false
            else {
                let alert = UIAlertController(title: "Loading lesson", message: "Wait until the download is complete", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Lo siento!", style: .default, handler: nil))
                alert.addAction(UIAlertAction(title: "I'm doing what I want!!1", style: .cancel, handler: nil))
                alert.addAction(UIAlertAction(title: "Red Button", style: .destructive, handler: nil))
                self.present(alert, animated: true, completion: nil)
                completionHandler()
                return
        }
        guard let url = URL(string: lessons[tag]) else { return completionHandler() }
        
        tempFileName = url.lastPathComponent
        tempURL = url
        
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
    
    func play(fileName: String, tag: Int) {
        let docURL = documentsDirectoryURL.appendingPathComponent(fileName)
        let player = AVPlayer(url: docURL)
        
        
        playerViewController.player = player
        
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem
        playerViewController.title = "Lesson №\(tag + 1)"
        
        switch lessonsStatus[tag] {
        case "Available offline":
            setRemoveButton()
        case "Available online":
            setSaveButton()
        default:
            break
        }
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
        let destinationURL = documentsDirectoryURL.appendingPathComponent(fileName)
        
        // Check if it exists before downloading
        if FileManager.default.fileExists(atPath: destinationURL.path) {
            print("The file already exists at path")
            completionHandler()
            // if the file doesn't exist
        } else {
            isLessonLoading = true
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            URLSession.shared.downloadTask(with: url) { (location, response, error) in
                DispatchQueue.main.sync {
                    guard let location = location, error == nil else { return }
                    do {
                        // Move file to destination URL after downloading
                        try FileManager.default.moveItem(at: location, to: destinationURL)
                    } catch {
                        print(error)
                        
                    }
                    self.isLessonLoading = false
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    completionHandler()
                }
                }.resume()
        }
        
    }
    
}
