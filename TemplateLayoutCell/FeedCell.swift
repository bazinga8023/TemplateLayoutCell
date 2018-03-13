//
//  FDFeedCell.swift
//  TemplateLayoutCell
//
//  Created by 张俊安 on 2018/3/13.
//  Copyright © 2018年 John.Zhang. All rights reserved.
//

import UIKit

class FeedCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var contentImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    

    var entity: FeedEntity! {
        didSet {
            titleLabel.text = entity.title
            contentLabel.text = entity.content
            contentImageView.image = entity.imageName.isEmpty ? nil : UIImage.init(named: entity.imageName)
            userNameLabel.text = entity.username
            timeLabel.text = entity.time
        }
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        var totalHeight: CGFloat = 0
        totalHeight += titleLabel.sizeThatFits(size).height
        totalHeight += contentLabel.sizeThatFits(size).height
        totalHeight += contentImageView.sizeThatFits(size).height
        totalHeight += userNameLabel.sizeThatFits(size).height
        totalHeight += 40
        return CGSize.init(width: size.width, height: totalHeight)
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        contentView.bounds = UIScreen.main.bounds
    }



}
