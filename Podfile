# Uncomment this line to define a global platform for your project
# platform :ios, '9.0'

def shared_pods
	use_frameworks!

    pod 'Firebase/AdMob'
    pod 'Firebase/Core'#, '~> 3.15.0'
    pod 'SWXMLHash'
    pod 'Alamofire', '~> 4.0'
    pod 'Fabric'
    pod 'Crashlytics'
    pod 'SwiftyJSON'
#    pod 'Kanna', '~> 2.1.0'
#    pod 'PercentEncoder'
    pod 'AlamofireNetworkActivityLogger'
    pod 'Cluster'
#    pod 'SwiftLint'
#    pod 'Cluster'
#    pod 'ReachabilitySwift'
end

target 'PBike' do

    shared_pods

end

target 'CBike' do

    shared_pods

end

target 'PBike Dev' do

    shared_pods

end


target 'GoBike' do
    
    shared_pods
    
end

target 'GoBikeTests' do
    
    shared_pods
    
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
        config.build_settings['SWIFT_VERSION'] = '4.2'
     end
  end
end
