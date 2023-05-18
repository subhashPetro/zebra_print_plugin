#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint zebra_plugin.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'zebra_plugin'
  s.version          = '0.0.1'
  s.summary          = 'A new Flutter project.'
  s.description      = <<-DESC
A new Flutter project.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/Objective-C/MFiBtPrinterConnection.h','Classes/Objective-C/ZebraPrinterConnection.h','Classes/Objective-C/ZebraPrinter.h','Classes/Objective-C/ZebraPrinterFactory.h','Classes/Objective-C/TcpPrinterConnection.h','Classes/Objective-C/PrinterStatusMessages.h','Classes/Objective-C/SGD.h'
  s.dependency 'Flutter'
  s.platform = :ios, '9.0'
  s.public_header_files = 'include/*.h'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
