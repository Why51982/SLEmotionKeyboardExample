//
//  SLEmotionKeyboardPackages.swift
//  EmotionKeyBoard
//
//  Created by CHEUNGYuk Hang Raymond on 16/10/10.
//  Copyright © 2016年 CHEUNGYuk Hang Raymond. All rights reserved.
//

import UIKit

///表情包，存储每一组表情
class SLEmotionKeyboardPackages: NSObject {
    
    ///表情id
    var id: String?
    ///分组名称
    var groupName: String?
    ///表情数组
    var emoticons: [SLEmoticon]?
    
    ///是packages()方法只执行一次，保证性能
    static let packageList: [SLEmotionKeyboardPackages] = SLEmotionKeyboardPackages.packages()
    
    init(id: String) {
        self.id = id
    }
    
    private class func packages() -> [SLEmotionKeyboardPackages] {
        
        var packages = [SLEmotionKeyboardPackages]()
        //创建最近组
        let pa = SLEmotionKeyboardPackages(id: "")
        pa.groupName = "最近"
        pa.emoticons = [SLEmoticon]()
        pa.appendEmptyEmoticon()
        packages.append(pa)
        
        //根据plist创建组
        let path = Bundle.main.path(forResource: "emoticons.plist", ofType: nil, inDirectory: "Emoticons.bundle")
        let dic = NSDictionary(contentsOfFile: path!)
        let dicArray = dic!["packages"] as! [[String : AnyObject]]
        
        for packageDic in dicArray {
            let package = SLEmotionKeyboardPackages(id: packageDic["id"] as! String)
            package.loadEmoticons()
            package.appendEmptyEmoticon()
            packages.append(package)
        }
        
        return packages
    }
    
    ///添加喜爱的表情
    func addFavouriteEmoticon(emoticon: SLEmoticon) {
        
        //移除删除按钮
        emoticons?.removeLast()
        
        //判断数组是否保存着当前表情
        let contain = emoticons!.contains(emoticon)
        
        //如果没有就往里面添加
        if !contain {
            //插入一个表情
            emoticons?.append(emoticon)
        }
        
        //根据使用次数给数组进行排序
        emoticons?.sort(by: { (element1, element2) -> Bool in
            return element1.times > element2.times
        })
        
        //如果插入过表情就要删除一个
        if !contain {
            emoticons?.removeLast()
        }
        
        //追加删除按钮
        emoticons?.append(SLEmoticon(isRemoveButton: true))
    }
    
    //追加空白按钮,如果一行没有21个按钮就添加空白按钮
    func appendEmptyEmoticon() {
        let length = emoticons!.count
        let count = emoticons!.count % 21
        
        if count != 0 || length == 0 {
            for _ in count..<20 {
                //追加空白按钮
                emoticons?.append(SLEmoticon(isRemoveButton: false))
            }
            //追加删除按钮
            emoticons?.append(SLEmoticon(isRemoveButton: true))
        }
    }
    
    //加载对应的表情数组
    private func loadEmoticons() {
        
        //加载id路径对应的info.plist
        let dic = NSDictionary(contentsOfFile: infoPath())
        //设置分组名
        groupName = dic?["group_name_cn"] as? String
        //获取表情数组
        let emoticonArray = dic?["emoticons"] as! [[String : String]]
        
        //实例化表情
        emoticons = [SLEmoticon]()
        
        var index = 0
        for emo in emoticonArray {
            
            index += 1
            let emoticon = SLEmoticon.init(dic: emo as [String : AnyObject], id: id!)
            emoticons!.append(emoticon)
            if index == 20 {
                emoticons?.append(SLEmoticon.init(isRemoveButton: true))
                index = 0
            }
            
        }
    }
    
    ///表情包所在路径的info.plist
    private func infoPath() -> String {
        return (SLEmotionKeyboardPackages.bundlePath().appendingPathComponent(id!) as NSString).appendingPathComponent("info.plist")
    }
    
    //表情包所在的路径
    class func bundlePath() -> NSString {
        return (Bundle.main.bundlePath as NSString).appendingPathComponent("Emoticons.bundle") as NSString
    }
}

class SLEmoticon: NSObject {
    
    ///用户的使用次数
    var times: Int = 0
    ///id
    var id: String?
    ///表情文字,发送给新浪服务器的文本内容
    var chs: String?
    ///表情图片,在App中进行图文混排使用的图片
    var png: String? {
        didSet {
            imagePath = (SLEmotionKeyboardPackages.bundlePath().appendingPathComponent(id!) as NSString).appendingPathComponent(png!)
        }
    }
    ///UNICODE 编码字符串
    var code: String?{
        didSet {
            //1.从字符串中取出十六进制的数
            //创建一个扫描器,扫描器可以从字符串中提取我们想要的数据
            let scanner = Scanner(string: code!)
            
            //2.提取16进制数字
            var result: UInt32 = 0
            scanner.scanHexInt32(&result)
            
            //3.将16进制转化为emoji字符串
            emojiStr = "\(Character(UnicodeScalar(result)!))"
        }
    }
    
    ///辅助属性:图片的全路径
    var imagePath: String?
    ///辅助属性:emoji表情
    var emojiStr: String?
    ///辅助属性:标记是否是删除按钮
    var isRemoveButton: Bool = false
    
    init(isRemoveButton: Bool) {
        super.init()
        self.isRemoveButton = isRemoveButton
    }
    
    init(dic: [String : AnyObject], id: String) {
        super.init()
        self.id = id
        setValuesForKeys(dic)
    }
    
    override func setValue(_ value: Any?, forUndefinedKey key: String) {
        
    }
}
