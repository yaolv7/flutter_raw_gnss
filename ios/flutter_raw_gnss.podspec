#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint flutter_raw_gnss.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'flutter_raw_gnss'
  s.version          = '0.0.1'
  s.summary          = 'raw_gnss 📡 makes it easy to fetch raw GNSS data including GNSS Measurement Events, GNSS Navigation Messages, and GNSS Status Events.'
  s.description      = <<-DESC
raw_gnss 📡 makes it easy to fetch raw GNSS data including GNSS Measurement Events, GNSS Navigation Messages, and GNSS Status Events.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '12.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'

  # If your plugin requires a privacy manifest, for example if it uses any
  # required reason APIs, update the PrivacyInfo.xcprivacy file to describe your
  # plugin's privacy impact, and then uncomment this line. For more information,
  # see https://developer.apple.com/documentation/bundleresources/privacy_manifest_files
  # s.resource_bundles = {'flutter_raw_gnss_privacy' => ['Resources/PrivacyInfo.xcprivacy']}
end
