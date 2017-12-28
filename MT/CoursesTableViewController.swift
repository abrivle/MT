//
//  CoursesTableViewController.swift
//  MT
//
//  Created by ILYA Abramovich on 23.12.2017.
//  Copyright © 2017 ILYA Abramovich. All rights reserved.
//

import UIKit

class CoursesTableViewController: UITableViewController, CourseCellDelegate {
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
//        self.navigationController?.navigationBar.titleTextAttributes = [ NSAttributedStringKey.font: UIFont(name: "Brush Script MT", size: 35)!]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let logo = #imageLiteral(resourceName: "Michel Thomas")
        let imageView = UIImageView(image:logo)
        self.navigationItem.titleView = imageView
        
        navigationController?.navigationBar.shadowImage = UIImage()
        
        navigationController?.navigationBar.layer.masksToBounds = false
        navigationController?.navigationBar.layer.shadowColor = UIColor.black.cgColor
        navigationController?.navigationBar.layer.shadowOpacity = 0.1
        navigationController?.navigationBar.layer.shadowOffset = CGSize.init(width: 0, height: 2)
        
        
        
        //navigationController?.navigationBar.layer.shadowRadius = 2
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
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
        return Constants.courses.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let course = Constants.courses[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "courseCell", for: indexPath) as! CourseTableViewCell
        cell.delegate = self 
        cell.tag = indexPath.row
        cell.courseTitle.text = course
        cell.setCourseDescription(course)
        
        return cell
    }
    
    func didTapNext(_ tag: Int) {
        guard let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "lessonsTVC") as? LessonsTableViewController else {
            print("Couldn't instantiate View Controller with identifier lessonsTVC")
            return
        }
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem
        
        let courseTitle = Constants.courses[tag]
        vc.courseTitle = courseTitle
        if let lessons = Constants.coursesDict[courseTitle] {
            vc.lessons = lessons
        } else {
            print("The course lessons list is empty!")
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
        
//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        guard let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "lessonsTVC") as? LessonsTableViewController else {
//            print("Couldn't instantiate View Controller with identifier WallTVC")
//            return
//        }
//        //        vc.rowNumber = rowNumber
//        //        vc.post = posts[rowNumber]
//        //        vc.profiles = profiles
//        //        vc.groups = groups
//        //        vc.title = "Post"
//
//        self.navigationController?.pushViewController(vc, animated: true)
//    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
