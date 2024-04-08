Pod::Spec.new do |s|
  s.name             = "JTAppleCalendar"
  s.version          = "8.0.5"
  s.summary          = "The Unofficial Swift Apple Calendar Library. View. Control. for iOS & tvOS"
  s.description      = <<-DESC
A highly configurable Apple calendar control. Contains features like boundary dates, month and week view. Very light weight.
                       DESC

  s.homepage         = "https://patchthecode.com"
  # s.screenshots    = "https://patchthecode.github.io/"
  s.license          = 'MIT'
  s.author           = { "JayT" => "patchthecode@gmail.com" }
  s.source           = { :git => "https://github.com/patchthecode/JTAppleCalendar.git", :tag => s.version.to_s }

  s.swift_version    = '5'

  s.ios.deployment_target = '11.0'
  s.tvos.deployment_target = '11.0'

  s.source_files = 'Sources/JTAppleCalendar/*.swift'
  s.resource_bundles = {'JTAppleCalendar' => ['Sources/JTAppleCalendar/PrivacyInfo.xcprivacy']}
end

