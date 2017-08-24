
Pod::Spec.new do |s|
  s.name         = "GGSwiftKit"
  s.version      = "0.0.1"
  s.summary      = "GGSwiftKit.提供一些简单的swift工具"
  s.description  = <<-DESC
为大家提供一些方便，里面包含一些常用的控件，将不断的完善
                   DESC
  s.homepage     = "https://github.com/GyorZou/SwifterKit"
  s.license      =  'MIT'
  s.author  = { "jp007" => "" }
  s.ios.deployment_target = '8.0'
  s.source       = { :git => "https://github.com/GyorZou/SwifterKit.git", :tag => "#{s.version}" }
  s.source_files  = "GGSwiftKit/**/*.swift"
  s.requires_arc = true
  s.framework  = "UIKit"
end
