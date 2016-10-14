//
//  SLEmoticonTextAttachment.swift
//  EmotionKeyBoard
//
//  Created by CHEUNGYuk Hang Raymond on 16/10/13.
//  Copyright © 2016年 CHEUNGYuk Hang Raymond. All rights reserved.
//

import UIKit

class SLEmoticonTextAttachment: NSTextAttachment {

    //用于保存表情对应的文字
    var chs: String?
    
    class func imageText(emoticon: SLEmoticon, font: UIFont) -> NSAttributedString {
        
        //创建附件
        let attachment = SLEmoticonTextAttachment()
        //设置图片
        attachment.image = UIImage(contentsOfFile: emoticon.imagePath!)
        //设置附件图片的大小
        let width = font.lineHeight
        attachment.bounds = CGRect(x: 0, y: -4, width: width, height: width)
        //保存图片对应的文字
        attachment.chs = emoticon.chs
        //根据附件创建属性字符串
        return NSAttributedString(attachment: attachment)
        
    }
}
