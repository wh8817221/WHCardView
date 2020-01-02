
import UIKit
import SnapKit

class ViewController: UIViewController, CardDataSource, CardDelegate, TitleScrollViewDelegate {
    //背景图
    var imageView: UIImageView = UIImageView()
    //毛玻璃效果
    var blurEffectView: UIVisualEffectView = UIVisualEffectView()
    lazy var configue: SelectConfigue = {
        var c = SelectConfigue()
        c.selectButtonColor = UIColor.blue
        c.lineColor = UIColor.blue
        c.cardMarginX = 20
        c.cardMargin = 20
        c.cardOffsetX = 20
        return c
    }()
    //滚动Title
    lazy var titleScrollView: TitleScrollView = {
        let titles = self.cellInfoArr().map({$0.1})
        let titleView = TitleScrollView(frame: CGRect.zero, arrTitle: titles, configue: configue)
        titleView.delegate = self
        return titleView
    }()
    
    //滚动卡片
    lazy var cardView: CardView = {
        let temp = CardView(frame: CGRect.zero, configue: configue)
        temp.dataSource = self
        temp.delegate = self
        //注册cell
        temp.register(cellClass: CustomCollectionViewCell.self, forCellWithReuseIdentifier:"CustomCellID")
        return temp
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.buildUI()
    }
    
    func buildUI() {
        //添加其他部分
        self.buildOtherUI()
        
        self.view.addSubview(titleScrollView)
        self.titleScrollView.snp.makeConstraints { (make) in
            make.left.top.right.equalTo(self.view)
            make.height.equalTo(44)
        }

        let lbl = UILabel()
        lbl.text = "测试"
        self.navigationItem.titleView = lbl
        
        //添加cardView
        self.view.addSubview(self.cardView)
        self.cardView.snp.makeConstraints { (make) in
            make.top.equalTo(self.titleScrollView.snp.bottom)
            make.left.right.bottom.equalTo(self.view)
        }
        
    }
    
    //自动布局
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.imageView.frame = self.view.bounds
        self.blurEffectView.frame = self.view.bounds
    }
    
    func buildOtherUI() -> () {
        //设置背景色
        self.view.backgroundColor = UIColor.white

        //设置默认背景图片
        self.imageView.image = UIImage.init(named: self.cellInfoArr()[0].0)
        self.view.addSubview(self.imageView)
        
        let blurEffect = UIBlurEffect.init(style: UIBlurEffect.Style.light)
        self.blurEffectView.effect = blurEffect;
        self.blurEffectView.frame = self.imageView.bounds
        self.imageView.addSubview(blurEffectView)
    }
    //AMRK:- CardDataSource
    func numberOfCard() -> Int {
        return self.cellInfoArr().count
    }
    //返回UICollectionViewCell
    func cellForItemAtIndex(index: Int) -> (UICollectionViewCell) {
        let cell = self.cardView.dequeueReusableCell(withReuseIdentifier:"CustomCellID", for: index) as! CustomCollectionViewCell
        cell.imageView.image = UIImage(named: self.cellInfoArr()[index].0)
        cell.textLabel.text = self.cellInfoArr()[index].1
        return cell
    }
    //AMRK:- CardDelegate
    func cardDidScrollToIndex(index: Int) {
        self.imageView.image = UIImage(named: self.cellInfoArr()[index].0)
    }
    
    //点击了卡片
//    func cardDidSelectedAtIndex(index: Int) {
//        print("点击了卡片-\(index)")
//    }
    
    func cardDidScroll(scrollView: UIScrollView) {
        titleScrollView.scrollViewDidScroll(scrollView)
    }
    
    //MARK:-TitleScrollViewDelegate
    func titleButtonDidSelectedAtIndex(index: Int) {
        cardView.switchToIndex(index: index)
    }
    
    //MARK:测试数据 (图片名称，名字)
    func cellInfoArr() -> Array<(String, String)> {
        return [("1","艾德·史塔克"),("2","凯瑟琳·徒利·史塔克"),("3","罗柏·史塔克"),("4","琼恩·雪诺"),("5","艾莉亚·史塔克"),("6","珊莎·史塔克"),("7","布兰·史塔克"),("8","瑟曦·兰尼斯特·拜拉席恩"),("9","提利昂·兰尼斯特"),("10","泰温·兰尼斯特"),("11","詹姆·兰尼斯特"),("12","乔佛里·拜拉席恩"),("13","丹尼莉丝·坦格利安")]
    }
}

