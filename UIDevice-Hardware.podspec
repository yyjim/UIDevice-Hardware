Pod::Spec.new do |s|
  s.name         = 'UIDevice-Hardware'
  s.version      = '0.1.6-cb'
  s.license      = { :type => 'BSD' }
  s.platform     = :ios
  s.summary      = 'Category on UIDevice to distinguish between platforms and provide human-readable device names e.g. "iPad Mini 2G (Cellular)".'
  s.homepage     = 'https://github.com/yyjim/UIDevice-Hardware'
  s.authors      = { 'Erica Sadun' => 'erica@ericasadun.com', 'Eric Horacek' => 'eric@monospacecollective.com', 'Jim Wang' => 'yy.jim731@gmail.com' }
  s.source       = { :git => 'https://github.com/yyjim/UIDevice-Hardware.git', :tag => s.version.to_s }
  s.source_files = 'UIDevice+Hardware.{h,m}'
  s.requires_arc = true
  s.xcconfig     = { 'OTHER_LDFLAGS' => '-ObjC -all_load -force_load' }
end
