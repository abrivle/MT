//
//  LessonTableViewCell.swift
//  MT
//
//  Created by ILYA Abramovich on 24.12.2017.
//  Copyright © 2017 ILYA Abramovich. All rights reserved.
//

import UIKit

class LessonTableViewCell: UITableViewCell {
    
    var delegate: LessonCellDelegate?
    
    @IBOutlet weak var lessonImage: UIImageView!
    @IBOutlet weak var lessonTitle: UILabel!
    @IBOutlet weak var lessonStatus: UILabel!
    @IBOutlet weak var nextButton: RoundButton!
    
    @IBAction func nextButtonTapped(_ sender: RoundButton) {
        
        let activityInd = UIActivityIndicatorView.init(activityIndicatorStyle: .gray)
        activityInd.center = lessonImage.center
        activityInd.hidesWhenStopped = true
        activityInd.startAnimating()
        lessonImage.addSubview(activityInd)
        lessonImage.alpha = 0.5
        delegate?.didTapNext(self.tag) { [weak self] in
            self?.lessonImage.alpha = 1
            activityInd.stopAnimating()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let maskPath = UIBezierPath.init(roundedRect: lessonImage.bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize.init(width: 5, height: 0))
        let shape = CAShapeLayer()
        shape.path = maskPath.cgPath
        lessonImage.layer.mask = shape
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
}

protocol LessonCellDelegate {
    func didTapNext(_ tag: Int, completionHandler: @escaping () -> ())
}
