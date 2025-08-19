# Uncomment the next line to define a global platform for your project
platform :ios, '14.0'

target 'FirstTask' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for FirstTask
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

      # Ensure the GCC_WARN_INHIBIT_ALL_WARNINGS flag is removed for BoringSSL-GRPC and BoringSSL-GRPC-iOS
      if ['BoringSSL-GRPC', 'BoringSSL-GRPC-iOS'].include? target.name
        target.source_build_phase.files.each do |file|
          if file.settings && file.settings['COMPILER_FLAGS']
            flags = file.settings['COMPILER_FLAGS'].split
            flags.reject! { |flag| flag == '-GCC_WARN_INHIBIT_ALL_WARNINGS' }
            file.settings['COMPILER_FLAGS'] = flags.join(' ')
          end
        end
      end
    end
  end
end
