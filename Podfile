# Uncomment this line to define a global platform for your project
platform :ios, '10.0'
# Uncomment this line if you're using Swift
use_frameworks!

target 'Austria-Forum' do
pod 'SwiftyJSON'
pod 'Alamofire', '~> 4.0'
pod 'Fabric'
pod 'Crashlytics'
pod 'ReachabilitySwift'

end

target 'Austria-ForumTests' do
    pod 'SwiftyJSON'
    pod 'Alamofire', '~> 4.0'
    pod 'Fabric'
    pod 'Crashlytics'
    pod 'ReachabilitySwift'
    
end

target 'Austria-ForumUITests' do
    pod 'SwiftyJSON'
    pod 'Alamofire', '~> 4.0'
    pod 'Fabric'
    pod 'Crashlytics'
    pod 'ReachabilitySwift'

end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '3.0'
        end
    end
end

