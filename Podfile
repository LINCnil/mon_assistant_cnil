# Uncomment the next line to define a global platform for your project
platform :ios, '13.0'

target 'CNILAssistant' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  pod 'TensorFlowLiteSwift', '~>2.4'
  
  pod 'RxSwift', '~> 6'
  pod 'RxCocoa', '~> 6'
  pod 'RxDataSources'
  pod 'Action'
  pod 'ProgressHUD'
  pod 'SnapKit'
  pod 'Swinject'
  pod 'SFSafeSymbols'
  pod 'Zip', '~> 2.1'
  pod 'Alamofire', '~> 5.2'
  pod 'LicensePlist'

  pod 'SwiftGen'
  pod 'SwiftLint'

  # Pods for CNILAssistant

  target 'CNILAssistantTests' do
    inherit! :search_paths
    # Pods for testing
    pod 'RxBlocking', '~> 6'
    pod 'RxTest', '~> 6'
    pod 'CodableCSV', '~> 0.6.5'
  end

  target 'CNILAssistantUITests' do
    # Pods for testing
  end

end

# Workaround to remove duplicated TensorFlowLite* frameworks
post_install do |installer|
  pods_aggregate_target = installer.aggregate_targets.find { |aggregate_target| aggregate_target.label == 'Pods-CNILAssistant' }
  if pods_aggregate_target.nil? then
    puts "Could not find aggregate target for CNILAssistant"
    next
  end
  pods_aggregate_target.xcconfigs.each do |configuration, xcconfig|
    puts "Removing TensorFlowLite* from OTHER_LDFLAGS"
    xcconfig.frameworks.delete("TensorFlowLiteC")
    xcconfig.frameworks.delete("TensorFlowLiteSwift")
    xcconfig.frameworks.delete("TensorFlowLite")

    xcconfig_path = pods_aggregate_target.xcconfig_path(configuration)
    xcconfig.save_as(xcconfig_path)
  end
end
