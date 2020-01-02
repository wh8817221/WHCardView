
Pod::Spec.new do |spec|

  spec.name         = "CardView"
  spec.version      = "1.0"
  spec.summary      = "高性能的SelectItem"
  spec.homepage     = "https://github.com/wh8817221/CardView"
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.author             = { "浩浩" => "446505447@qq.com" }
  spec.social_media_url   = "https://www.jianshu.com/u/af4388902f7d"
  spec.platform     = :ios, "9.0"
  spec.source       = { :git => "https://github.com/wh8817221/CardView.git", :tag => spec.version }
  spec.source_files  = "CardView/**/*.{h,swift}"
  spec.framework  = "UIKit"
  spec.requires_arc = true
  spec.dependency "SnapKit", "~> 4.2.0"

end
