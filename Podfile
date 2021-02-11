# Uncomment this line to define a global platform for your project
platform :ios, '9.0'
# Uncomment this line if you're using Swift
use_frameworks!

target 'Austria-Forum' do
pod 'Alamofire'
pod 'ReachabilitySwift'
pod 'SwiftGen'
pod 'PKHUD'
pod 'lottie-ios'
pod 'SwiftEntryKit'

end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '5.0'
            require 'fileutils'
            FileUtils.cp_r('Pods/Target Support Files/Pods-Austria-Forum/Pods-Austria-Forum-acknowledgements.plist', 'afUsedLibsLicenses.plist', :remove_destination => true)
        end
    end
end

