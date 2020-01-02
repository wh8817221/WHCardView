//
//  CardView.swift
//  TestCardView
//
//  Created by 王浩 on 2019/12/20.
//  Copyright © 2019 haoge. All rights reserved.
//

import UIKit

class CardFlowLayout: UICollectionViewFlowLayout {
    var confgue: SelectConfigue!
    init(configue: SelectConfigue = SelectConfigue()) {
        super.init()
        self.confgue = configue
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func prepare() {
        self.scrollDirection = .horizontal
        self.sectionInset = UIEdgeInsets(top: self.insetY, left: self.insetX, bottom: self.insetY, right: self.insetX)
        self.itemSize = CGSize(width: self.itemWidth, height: self.itemHeight)
        self.minimumLineSpacing = confgue.cardMargin
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let originalAttributesArr = super.layoutAttributesForElements(in: rect)
        //复制布局,以下操作，在复制布局中处理
        var attributesArr: Array<UICollectionViewLayoutAttributes> = Array()
        for attr in originalAttributesArr! {
            attributesArr.append(attr.copy() as! UICollectionViewLayoutAttributes)
        }
        //屏幕中线
        let centerX = (self.collectionView?.contentOffset.x)!+(self.collectionView?.bounds.width)!/2
        //最大移动距离，计算范围是移动出屏幕前的距离
        let maxApart = ((self.collectionView?.bounds.width)!+self.itemWidth)/2
        //刷新cell缩放
        for attributes in attributesArr {
            //获取cell中心和屏幕中心的距离
            let apart = abs(attributes.center.x-centerX)
            //移动进度-1~1
            let progress = apart/maxApart
            //在屏幕外的cell不处理
            if abs(progress) > 1 {
                continue
            }
            if confgue.isScaleCard {
                //根据余弦函数，弧度在 -π/4 到 π/4,即 scale在 √2/2~1~√2/2 间变化
                let scale = abs(cos(progress * CGFloat(Double.pi/4)))
                //缩放大小
                attributes.transform = CGAffineTransform(scaleX: scale, y: scale)
            }
        }
        return attributesArr
    }
    
    //MARK 配置方法
    //卡片宽度
    var itemWidth: CGFloat {
        let scaleX = 1 - (confgue.cardMarginX + confgue.cardOffsetX) * 2 / (self.collectionView?.bounds.size.width)!
        return (self.collectionView?.bounds.size.width)! * scaleX
    }
    //卡片高度
    var itemHeight: CGFloat {
        let scaleY = 1 - confgue.cardMarginY * 2 / (self.collectionView?.bounds.size.height)!
        return (self.collectionView?.bounds.size.height)!*scaleY
    }

    //设置左右缩进
    var insetX: CGFloat {
        return ((self.collectionView?.bounds.size.width)!-self.itemWidth)/2
    }
    
    //上下缩进
    var insetY: CGFloat {
        return ((self.collectionView?.bounds.size.height)!-self.itemHeight)/2
    }
    //是否实时刷新布局
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
}

//MARK:-代理
@objc protocol CardDelegate: NSObjectProtocol {
    //滑动cardView回调
    @objc optional func cardDidScroll(scrollView: UIScrollView)
    //滑动切换到新的位置回调
    @objc optional func cardDidScrollToIndex(index: Int)
    //手动点击了
    @objc optional func cardDidSelectedAtIndex(index: Int)
}

//MARK:-数据源
@objc protocol CardDataSource {
    //卡片的个数
    func numberOfCard() -> Int
    //卡片cell
    func cellForItemAtIndex(index: Int) -> UICollectionViewCell
}

class CardView: UIView, UICollectionViewDelegate, UICollectionViewDataSource {
    //共有属性
    weak var delegate: CardDelegate?
    weak var dataSource: CardDataSource?
    var selectedIndex: Int = 0
    fileprivate var configue = SelectConfigue()
    fileprivate var dragStartX: CGFloat = 0
    fileprivate var dragEndX: CGFloat = 0
    fileprivate var dragAtIndex: Int = 0
    fileprivate let flowlayout = CardFlowLayout()

    fileprivate lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: flowlayout)
        view.delegate = self
        view.dataSource = self
        view.backgroundColor = UIColor.clear
        view.showsHorizontalScrollIndicator = false
        return view
    }()
    
    init(frame: CGRect, configue: SelectConfigue = SelectConfigue()) {
        super.init(frame: frame)
        self.configue = configue
        self.buildUI()
    }
    
    func buildUI() {
        self.addSubview(collectionView)
        collectionView.snp.makeConstraints { (make) in
            make.left.top.right.bottom.equalTo(self)
        }
        flowlayout.confgue = configue
    }

    //回调滚动方法
    func delegateUpdateScrollIndex(index: Int) {
        guard let delegate = self.delegate else {
            return
        }
        if (delegate.responds(to: #selector(delegate.cardDidScrollToIndex(index:)))) {
            delegate.cardDidScrollToIndex?(index: index)
        }
    }
    
    //滚动到中间
    func scrollToCenterAnimated(animated: Bool) {
        collectionView.scrollToItem(at: IndexPath(row: self.selectedIndex, section: 0), at: .centeredHorizontally, animated: animated)
    }
    
    //Card回调点击方法
    func delegateSelectedAtIndex(index: Int) {
        guard let delegate = self.delegate else {
            return
        }
        if delegate.responds(to: #selector(delegate.cardDidSelectedAtIndex(index:))) {
            delegate.cardDidSelectedAtIndex?(index: index)
        }
    }
    
    //MARK:CollectionView方法
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataSource?.numberOfCard() ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return (self.dataSource?.cellForItemAtIndex(index: indexPath.row))!
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
        self.scrollToCenterAnimated(animated: true)
        self.delegateSelectedAtIndex(index: indexPath.row)
        self.delegateUpdateScrollIndex(index: self.selectedIndex)
    }
    //MARK:数据源相关方法
    open func register(cellClass: AnyClass?, forCellWithReuseIdentifier identifier: String) {
        collectionView.register(cellClass, forCellWithReuseIdentifier: identifier)
    }
    open func dequeueReusableCell(withReuseIdentifier identifier: String, for index: Int) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: IndexPath(row: index, section: 0))
    }
    
    //居中
    @objc func fixCellToCenter() {
        if self.selectedIndex != dragAtIndex {
            self.scrollToCenterAnimated(animated: true)
            return
        }
        //最小滚动距离
        let dragMiniDistance = self.bounds.width/10
        if dragStartX - dragEndX >= dragMiniDistance {
            self.selectedIndex -= 1 //向右
        } else if dragEndX - dragStartX >= dragMiniDistance {
            self.selectedIndex += 1 //向右
        }
        let maxIndex = collectionView.numberOfItems(inSection: 0) - 1
        self.selectedIndex = max(self.selectedIndex, 0)
        self.selectedIndex = min(self.selectedIndex, maxIndex)
        self.scrollToCenterAnimated(animated: true)
        self.delegateUpdateScrollIndex(index: self.selectedIndex)
    }
    
    //MARK:切换位置方法
    func switchToIndex(index: Int) {
        DispatchQueue.main.async {
            self.selectedIndex = index
            self.scrollToCenterAnimated(animated: true)
            self.delegateUpdateScrollIndex(index: self.selectedIndex)
        }
    }
    
    //向前切换
    func switchPrevious() {
        guard let index = currentIndex else {
            return
        }
        var targetIndex = index - 1
        targetIndex = max(0, targetIndex)
        self.switchToIndex(index: targetIndex)
    }
    
    //向后切换
    func switchNext() {
        guard let index = currentIndex else {
            return
        }
        var targetIndex = index + 1
        let maxIndex = (self.dataSource?.numberOfCard())! - 1
        targetIndex = min(maxIndex, targetIndex)
        self.switchToIndex(index: targetIndex)
    }

    var currentIndex: Int? {
        let x = collectionView.contentOffset.x + collectionView.bounds.width/2
        return collectionView.indexPathForItem(at: CGPoint(x: x, y: collectionView.bounds.height/2))?.item
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //手指拖动开始
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        dragStartX = scrollView.contentOffset.x
        dragAtIndex = self.selectedIndex
    }
    
    //手指拖动停止
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        dragEndX = scrollView.contentOffset.x
        //在主线程执行居中方法
        DispatchQueue.main.async {
            self.fixCellToCenter()
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let delegate = self.delegate else {
            return
        }
        if delegate.responds(to: #selector(delegate.cardDidScroll(scrollView:))) {
            delegate.cardDidScroll?(scrollView: scrollView)
        }
    }
}

