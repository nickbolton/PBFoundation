#
# Be sure to run `pod spec lint PBFoundation.podspec' to ensure this is a
# valid spec.
#
# Remove all comments before submitting the spec. Optional attributes are commented.
#
# For details see: https://github.com/CocoaPods/CocoaPods/wiki/The-podspec-format
#
Pod::Spec.new do |s|
  s.name         = "PBFoundation"
  s.version      = "0.0.1"
  s.summary      = "PBFoundation is a collection of useful Mac and iOS utilities and view subclasses"
  s.homepage     = "https://github.com/nickbolton/PBFoundation"
  s.license      = 'MIT (example)'
  s.author       = { "nickbolton" => "nick@deucent.com" }
  s.source       = { :git => "https://github.com/nickbolton/PBFoundation.git", :tag => "0.0.1" }
  s.source_files = '*.{h,m}', 'Shared', 'Shared/**/*.{h,m}', 'Mac', 'Mac/**/*.{h,m}', 'iOS', 'iOS/**/*.{h,m}'
end
