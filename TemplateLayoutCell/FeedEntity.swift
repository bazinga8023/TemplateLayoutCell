//
//  FeedEntity.swift
//  TemplateLayoutCell
//
//  Created by 张俊安 on 2018/3/13.
//  Copyright © 2018年 John.Zhang. All rights reserved.
//

import UIKit

struct FeedEntity {

    var identifier: String
    let title: String
    let content: String
    let username: String
    let time: String
    let imageName: String

    init(with dictionary: [String: String]) {
        title = dictionary["title"] ?? ""
        content = dictionary["content"] ?? ""
        username = dictionary["username"] ?? ""
        time = dictionary["time"] ?? ""
        imageName = dictionary["imageName"] ?? ""
        identifier = dictionary["identifier"] ?? ""
    }


}
