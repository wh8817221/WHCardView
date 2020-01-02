//
//  Configue.swift
//  TestCardView
//
//  Created by 王浩 on 2019/12/30.
//  Copyright © 2019 haoge. All rights reserved.
//

import UIKit

struct SelectConfigue {
    //默认按钮字体颜色
    var defaultButtonColor: UIColor = UIColor.gray
    //默认按钮的字体大小
    var defaultButtonFont: UIFont = UIFont.systemFont(ofSize: 15)
    //选择按钮的颜色
    var selectButtonColor: UIColor = UIColor.orange
    //线颜色
    var lineColor: UIColor = UIColor.orange
    //线额宽度
    var lineHeight: CGFloat = 4.0
    //线的圆角
    var lineRadius: CGFloat = 2.0
    //卡片X轴的偏移量
    var cardMarginX: CGFloat = 20.0
    //卡片Y轴的偏移量
    var cardMarginY: CGFloat = 20.0
    //两侧卡片漏出偏移量
    var cardOffsetX: CGFloat = 20.0
    //卡片间距
    var cardMargin: CGFloat = 20.0
    //是否缩放CardView  默认不缩放 缩放需要自己调整间距
    var isScaleCard: Bool = false
}

