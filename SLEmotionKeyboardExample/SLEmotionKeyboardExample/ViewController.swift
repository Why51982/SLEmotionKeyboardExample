//
//  ViewController.swift
//  SLEmotionKeyboardExample
//
//  Created by CHEUNGYuk Hang Raymond on 16/10/14.
//  Copyright © 2016年 CHEUNGYuk Hang Raymond. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    //编辑的文本,作为呼出键盘用
    @IBOutlet weak var textView: UITextView!
    
    ///模拟发送(获取发送文本)
    @IBAction func postItem(_ sender: AnyObject) {
        
        //将要发送的文字
        print(textView.postEmoticonAttributedText())
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //将键盘控制器添加成控制器的子控制器，保住命
        addChildViewController(emotionKeyboard)
        
        textView.inputView = emotionKeyboard.view
        textView.font = UIFont.systemFont(ofSize: 20)
    }
    
    //MARK: - 懒加载
    private lazy var emotionKeyboard: SLEmotionKeyboardController = SLEmotionKeyboardController { [unowned self] (emoticon) in
        
        self.textView.insertEmoticon(emoticon: emoticon)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }



}

