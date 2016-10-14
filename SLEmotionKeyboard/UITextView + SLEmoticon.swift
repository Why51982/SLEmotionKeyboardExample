//
//  UITextView + SLCategory.swift
//  EmotionKeyBoard
//
//  Created by CHEUNGYuk Hang Raymond on 16/10/13.
//  Copyright © 2016年 CHEUNGYuk Hang Raymond. All rights reserved.
//

import UIKit

extension UITextView {
    
    //插入表情
    func insertEmoticon(emoticon: SLEmoticon) {
        
        //判断是否是删除键盘
        if emoticon.isRemoveButton {
            deleteBackward()
        }
        
        //判断当前是否是emoji表情
        if (emoticon.emojiStr != nil) {
            replace(selectedTextRange!, withText: emoticon.emojiStr!)
        }
        
        //图片
        if (emoticon.png != nil) {
            //创建图片附件(图文混排)
            //根据附件创建属性字符串
            let emoticonText = SLEmoticonTextAttachment.imageText(emoticon: emoticon, font: font!)
            
            //拿到当前textView的内容
            let attributedString = NSMutableAttributedString(attributedString:attributedText)
            
            //插入表情到光标所在的位置
            //记录光标的位置，供后面恢复用
            let range = selectedRange
            attributedString.replaceCharacters(in: selectedRange, with: emoticonText)
            
            //解决使用图片后面紧接着使用emoji表情变小的问题
            attributedString.addAttribute(NSFontAttributeName, value: font!, range: NSMakeRange(range.location, 1))
            
            //插入表情后的属性字符串重新赋值给textView
            attributedText = attributedString
            
            //恢复光标位置在表情后面
            selectedRange = NSMakeRange(range.location + 1, 0)
            
            //输入表情使其自动触发textViewDidChange方法
            delegate?.textViewDidChange!(self)
            
        }
    }
    
    //发送服务器的文字
    func postEmoticonAttributedText() -> String {
        
        var postText = String()
        attributedText.enumerateAttributes(in: NSMakeRange(0, attributedText.length), options: NSAttributedString.EnumerationOptions.init(rawValue: 0)) { (obj, range, _) in
            
            //遍历的时候传递给我们的obj是个字典,如果字典中的NSAttachment这个key有值
            //那么就证明当前的是一个图片
            //            print(obj["NSAttachment"])
            //range就是纯字符串的范围
            //如果纯字符串中间有图片表情,那么range就会传递多次
            //            print(range)
            
            
            if obj["NSAttachment"] != nil {
                let attachment = obj["NSAttachment"] as! SLEmoticonTextAttachment
                postText += attachment.chs!
            } else {
                postText += (self.text as NSString).substring(with: range)
            }
        }
        return postText
    }
}
