//
//  CourseTableViewCell.swift
//  MT
//
//  Created by ILYA Abramovich on 23.12.2017.
//  Copyright © 2017 ILYA Abramovich. All rights reserved.
//

import UIKit

class CourseTableViewCell: UITableViewCell {
    
    var delegate: CourseCellDelegate?
    
    @IBOutlet weak var courseTitle: UILabel!
    @IBOutlet weak var courseDescription: UILabel!
    
    @IBAction func nextButtonTapped(_ sender: RoundButton) {
        delegate?.didTapNext(self.tag)
    }
    
    func setCourseDescription(_ key: String) {
        let descriptrion = Constants.coursesDict[key]![0]
        if !descriptrion.isEmpty {
            courseDescription.text = descriptrion
        } else {
            courseDescription.text = Constants.courseDescriptionDefault
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

protocol CourseCellDelegate {
    func didTapNext (_ tag: Int)
}
