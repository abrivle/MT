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
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var downloadingLabel: UILabel!
    @IBOutlet weak var downloadingIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var downloadingCancelButtonLabel: UILabel!
    @IBOutlet weak var downloadingCancelButton: UIButton!
    
    @IBAction func nextButtonTapped(_ sender: RoundButton) {
        
        // If view.alpha != 0 means a lesson is downloading
        guard view.alpha == 0
            else {
                downloadingLabel.textColor = UIColor.red
                DispatchQueue.main.asyncAfter(deadline: (.now() + 0.3)) { [weak self] in
                    self?.downloadingLabel.textColor = UIColor.white
                }
                return
        }
        
        view.alpha = 0.5
        lessonImage.addSubview(view)
        
        downloadingLabel.text = "Downloading..."
        downloadingCancelButtonLabel.text = "Cancel"
        downloadingCancelButton.isEnabled = true
        
        delegate?.didTapNext(self.tag) { [weak self] in
            self?.view.alpha = 0
        }
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        downloadingCancelButton.isEnabled = false
        delegate?.didTapCancel(self.tag) { [weak self] in
            self?.view.alpha = 0
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let maskPath = UIBezierPath.init(roundedRect: lessonImage.bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize.init(width: 5, height: 0))
        let shape = CAShapeLayer()
        shape.path = maskPath.cgPath
        lessonImage.layer.mask = shape
    }
    
    // When we scroll Table View, activity indicator stops animation without overriding this func
    override func prepareForReuse() {
        super.prepareForReuse()
        downloadingIndicator.startAnimating()
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
    func didTapCancel(_ tag: Int, completionHandler: @escaping () -> ())
}
