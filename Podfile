target 'twinme' do
platform :ios, '12.0'

pod 'CocoaLumberjack', :path => 'Pods/CocoaLumberjack', inhibit_warnings: true
pod 'KissXML', :path => 'Pods/KissXML', inhibit_warnings: true
pod 'SQLCipher', :path => 'Pods/SQLCipher', inhibit_warnings: true
pod 'FMDB/SQLCipher', :path => 'Pods/FMDB', inhibit_warnings: true
pod 'SlackTextViewController', :path => 'Pods/SlackTextViewController', inhibit_warnings: true
pod 'SSZipArchive', :path => 'Pods/ZipArchive', inhibit_warnings: true
pod 'lottie-ios', :path => 'Pods/lottie-ios', inhibit_warnings: true
end

ENV["COCOAPODS_DISABLE_STATS"] = "true"

post_install do |installer_representation|
  installer_representation.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['ONLY_ACTIVE_ARCH'] = 'NO'
    end
  end
end
