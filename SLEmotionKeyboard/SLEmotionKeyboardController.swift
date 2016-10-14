//
//  SLEmotionKeyboardController.swift
//  EmotionKeyBoard
//
//  Created by CHEUNGYuk Hang Raymond on 16/10/9.
//  Copyright © 2016年 CHEUNGYuk Hang Raymond. All rights reserved.
//

import UIKit

let SLEmotionKeyboardCellReuseIdentifier = "SLEmotionKeyboardCellReuseIdentifier"


class SLEmotionKeyboardController: UIViewController {
    
    //定义一个闭包属性
    var emoticonDidSelectedCallBack: (_ emoticon: SLEmoticon) -> ()
    
    init(callBack: @escaping (_ emoticon: SLEmoticon) -> ()) {
        self.emoticonDidSelectedCallBack = callBack
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //初始化控件
        setupUI()
    }
    
    //初始化控件
    private func setupUI() {
        //添加子控件
        view.addSubview(collectionView)
        view.addSubview(toolBar)
        
        //禁止autoresizing
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        toolBar.translatesAutoresizingMaskIntoConstraints = false
        
        //布局子控件
        var cons = [NSLayoutConstraint]()
        let dic = ["collectionView" : collectionView, "toolBar" : toolBar] as [String : Any]
        cons += NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[collectionView]-0-|", options: NSLayoutFormatOptions.init(rawValue: 0), metrics: nil, views: dic)
        cons += NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[toolBar]-0-|", options: NSLayoutFormatOptions.init(rawValue: 0), metrics: nil, views: dic)
        cons += NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[collectionView]-[toolBar(44)]-0-|", options: NSLayoutFormatOptions.init(rawValue: 0), metrics: nil, views: dic)
        
        //添加约束
        view.addConstraints(cons)
    }
    
    //MARK: - 懒加载
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: SLEmotionKeyboardFlowLayout())
        collectionView.backgroundColor = UIColor.white
        collectionView.dataSource = self
        collectionView.delegate = self 
        collectionView.register(SLEmotionKeyboardCell.self, forCellWithReuseIdentifier: SLEmotionKeyboardCellReuseIdentifier)
        return collectionView
    }()
    
    private lazy var toolBar: UIToolbar = {
        let toolBar = UIToolbar()
        toolBar.tintColor = UIColor.darkGray
        let titles = ["最近", "默认", "emoji", "浪小花"]
        var items = [UIBarButtonItem]()
        var i = 0
        for title in titles {
            let item = UIBarButtonItem(title: title, style: UIBarButtonItemStyle.plain, target: self, action: #selector(SLEmotionKeyboardController.itemClick(item:)))
            item.tag = i
            i = i + 1
            let flexibleItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
            items.append(item)
            items.append(flexibleItem)
        }
        items.removeLast()
        toolBar.items = items
        return toolBar
    }()
    
    lazy var emoticonPackages: [SLEmotionKeyboardPackages] = {
        let emoticonPackages = SLEmotionKeyboardPackages.packageList
        return emoticonPackages
    }()
    
    //MARK: - item点击事件
     func itemClick(item: UIBarButtonItem) {
        collectionView.scrollToItem(at: IndexPath.init(row: 0, section: item.tag), at: UICollectionViewScrollPosition.left, animated: true)
    }
}

extension SLEmotionKeyboardController: UICollectionViewDataSource, UICollectionViewDelegate {
    ///返回多少组
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return emoticonPackages.count
    }
    ///返回每组多少行
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return emoticonPackages[section].emoticons!.count
    }
    ///创建cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SLEmotionKeyboardCellReuseIdentifier, for: indexPath) as! SLEmotionKeyboardCell
        let emoticon = emoticonPackages[indexPath.section].emoticons?[indexPath.item]
        cell.emoticon = emoticon
        return cell
    }
    ///cell选中
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //获取当前选中的表情
        let emoticon = emoticonPackages[indexPath.section].emoticons![indexPath.item]
        //判断表情符号是否有效
        if indexPath.section != 0 && emoticon.chs != nil || emoticon.code != nil {
            emoticon.times += 1
            //将表情添加到"最近"
            emoticonPackages[0].addFavouriteEmoticon(emoticon: emoticon)
        }
        
        emoticonDidSelectedCallBack(emoticon)
    }
}

class SLEmotionKeyboardFlowLayout: UICollectionViewFlowLayout {
    
    override func prepare() {
        super.prepare()
        
        let width = (collectionView?.bounds.width)! / 7
        itemSize = CGSize(width: width, height: width)
        scrollDirection = UICollectionViewScrollDirection.horizontal
        collectionView?.isPagingEnabled = true
        minimumLineSpacing = 0
        minimumInteritemSpacing = 0
        
        let insertY = (collectionView!.bounds.height - width * 3) * 0.49
        collectionView?.contentInset = UIEdgeInsetsMake(insertY, 0, insertY, 0)
        
    }
}

class SLEmotionKeyboardCell: UICollectionViewCell {
    
    var emoticon: SLEmoticon? {
        
        didSet {
            //图片表情
            if emoticon?.chs != nil {
                iconView.setImage(UIImage.init(named: emoticon!.imagePath!), for: UIControlState.normal)
            } else {  //防止重用问题
                iconView.setImage(nil, for: UIControlState.normal)
            }
            
            //设置emoji表情
            //注意加上""是为了重用
            iconView.setTitle(emoticon?.emojiStr ?? "", for: UIControlState.normal)
            
            if emoticon!.isRemoveButton {
                iconView.setImage(UIImage.init(named: "compose_emotion_delete"), for: UIControlState.normal)
//                iconView.setImage(UIImage.init(named: "compose_emotion_delete_highlighted"), for: UIControlState.highlighted)
            }
        }
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(iconView)
        iconView.frame = contentView.bounds
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var iconView: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = UIFont.systemFont(ofSize: 32)
        button.addTarget(self, action: #selector(SLEmotionKeyboardCell.buttonClick), for: UIControlEvents.touchUpInside)
        button.isUserInteractionEnabled = false
        return button
    }()
    
    func buttonClick() {
        print("---")
    }
}

