//
//  LessonTableViewCell.swift
//  MT
//
//  Created by ILYA Abramovich on 24.12.2017.
//  Copyright © 2017 ILYA Abramovich. All rights reserved.
//

import UIKit

class LessonTableViewCell: UITableViewCell, URLSessionDownloadDelegate {
    
    @IBOutlet weak var lessonImage: UIImageView!
    @IBOutlet weak var lessonTitle: UILabel!
    @IBOutlet weak var lessonStatus: UILabel!
    @IBOutlet weak var nextButton: RoundButton!
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var downloadingLabel: UILabel!
    @IBOutlet weak var downloadingIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var downloadingCancelButtonLabel: UILabel!
    @IBOutlet weak var downloadingCancelButton: UIButton!
    @IBOutlet weak var progressBar: UIProgressView!
    
    var delegate: LessonCellDelegate?
    var delegateOfVC: LessonsTableViewController?
    
    var lessonUrl = ""
    
    // Create destination file url
    let documentsDirectoryURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    
    @IBAction func nextButtonTapped(_ sender: RoundButton) {
        
        // If view.alpha != 0 means a lesson is downloading
        guard view.alpha == 0
            else {
                showAlert(title: "The lesson is already downloaded", message: "After downloading the lesson...")
                return
        }
        
        view.alpha = 0.5
        downloadingLabel.text = "Downloading..."
        downloadingCancelButtonLabel.text = "Cancel"
        downloadingCancelButton.isEnabled = true
        
        // If during the download of one lesson, clicking on the download of another lesson will be shown Aleret Controller
        guard delegateOfVC?.isLessonLoading == false
            else {
                showAlert(title: "Loading lesson", message: "Wait until the download is complete")
                view.alpha = 0
                downloadingCancelButton.isEnabled = false
                return
        }
        
        guard let url = URL(string: lessonUrl)
            else {
                showAlert(title: "Wrong URL", message: nil)
                view.alpha = 0
                downloadingCancelButton.isEnabled = false
                return
        }
        
//        tempFileName = url.lastPathComponent
//        tempURL = url
        
        // Check Lesson Status
        switch lessonStatus.text {
        case "Available offline"?:
            delegateOfVC?.play(fileName: url.lastPathComponent, tag: tag)
            view.alpha = 0
            downloadingCancelButton.isEnabled = false
        case "Available online"?:
            progressBar.progressTintColor = Constants.buttonColor
            
            // Remove old temp.mp3
            try? FileManager.default.removeItem(at: documentsDirectoryURL.appendingPathComponent("temp.mp3"))
            
            // Download new temp.mp3
            downloadFile(from: url, fileName: "temp.mp3")
            
        default:
            break
        }
        
        delegate?.didTapNext(self.tag) {
            // Do smth when the func is compleate
        }
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        delegateOfVC?.isLessonLoading = false
        downloadingCancelButton.isEnabled = false
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        progressBar.progress = 0
        delegateOfVC?.task!.cancel()
        view.alpha = 0
        delegate?.didTapCancel(self.tag) {
            // Do smth when the func is compleate
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Round corners
        let maskPath = UIBezierPath.init(roundedRect: lessonImage.bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize.init(width: 5, height: 0))
        let shape = CAShapeLayer()
        shape.path = maskPath.cgPath
        lessonImage.layer.mask = shape
        lessonImage.clipsToBounds = true
//        view.layer.mask = shape
    }
    
    // When we scroll Table View, activity indicator stops animation without overriding this func
    override func prepareForReuse() {
        super.prepareForReuse()
        downloadingIndicator.startAnimating()
        
        // Round corners
        let maskPath = UIBezierPath.init(roundedRect: lessonImage.bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize.init(width: 5, height: 0))
        let shape = CAShapeLayer()
        shape.path = maskPath.cgPath
        lessonImage.layer.mask = shape
        lessonImage.clipsToBounds = true
//        view.layer.mask = shape
    }
    
    func downloadFile(from url: URL, fileName: String) {
        
        // Checking internet connection
        guard Reachability.isConnectedToNetwork() else {
            view.alpha = 0
            downloadingCancelButton.isEnabled = false
            showAlert(title: "No internet connection", message: "An internet connection is required to download the lesson. You can save lesson to device after downloading for offline access")
            return
        }
        
        delegateOfVC?.isLessonLoading = true
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let configuration = URLSessionConfiguration.default
        let urlSession = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        
        // We want to cancel task when Lessons TableVC will disappear
        delegateOfVC?.task = urlSession.downloadTask(with: url)
        delegateOfVC?.task!.resume()
    }
    
    // Download progress
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        let progress = Float(totalBytesWritten)/Float(totalBytesExpectedToWrite)
        print(progress)
        let totalBytes = Float(Int(Float(totalBytesExpectedToWrite)/(1024*1024)*10))/10
        DispatchQueue.main.async { [weak self] in
            self?.progressBar.progress = progress
            self?.downloadingLabel.text = "Downloading \(totalBytes)MB"
        }
        
    }
    
    // When file download is finished
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        
        print("Finished downloading file")
        
        let destinationURL = documentsDirectoryURL.appendingPathComponent("temp.mp3")
        
        guard !FileManager.default.fileExists(atPath: destinationURL.path)
            else {
                print("The file already exists at path")
                return
        }
        
        do {
            // Move file to destination URL after downloading
            try FileManager.default.moveItem(at: location, to: destinationURL)
        } catch {
            print("--- Error: \(error)")
        }
        DispatchQueue.main.async { [weak self] in
            self?.delegateOfVC?.isLessonLoading = false
            self?.delegateOfVC?.play(fileName: "temp.mp3", tag: (self?.tag)!)
            self?.progressBar.progress = 0
            self?.view.alpha = 0
            self?.downloadingCancelButton.isEnabled = false
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
    }
    
    func showAlert(title: String?, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        delegateOfVC?.present(alert, animated: true, completion: nil)
    }
    
}
protocol LessonCellDelegate {
    func didTapNext(_ tag: Int, completionHandler: @escaping () -> ())
    func didTapCancel(_ tag: Int, completionHandler: @escaping () -> ())
}
