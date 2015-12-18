#
#  Be sure to run `pod spec lint ITSwitch.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|
  s.name         = "ITSwitch"
  s.version      = "1.0"
  s.summary      = "ITSwitch is a replica of UISwitch for Mac OS X"
  s.description  =  "ITSwitch is a simple and lightweight replica of iOS 7 UISwitch for Mac OS X."
  s.homepage     = "https://github.com/iluuu1994/ITSwitch"
  s.license      = { :type => "Apache License", :file => "LICENSE" }
  s.author             = { "Ilija Tovilo" => "support@ilijatovilo.ch" }
  s.osx.deployment_target = "10.9"
  s.source       = { :git => "https://github.com/iluuu1994/ITSwitch.git", :tag => "v1.0" }
  s.source_files  = "ITSwitch/*.{h,m}"
  s.framework  = "QuartzCore"
  s.requires_arc = true
end
