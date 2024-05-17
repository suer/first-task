# Uncomment the next line to define a global platform for your project
platform :ios, '14.0'

target 'FirstTask' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for FirstTask
  pod 'Firebase/Crashlytics'
  pod 'Firebase/Analytics'
  pod 'FirebaseUI/Auth'
  pod 'FirebaseUI/Google'
  pod 'Firebase/Firestore'
  pod 'FirebaseFirestoreSwift'
  pod 'Ballcap', git: 'https://github.com/1amageek/Ballcap-iOS.git', tag: '2.1.0'
  pod 'LicensePlist'

  target 'FirstTaskTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'FirstTaskUITests' do
    # Pods for testing
  end

  post_install do |installer|
    installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '14.0'
      end
    end
  end
end
