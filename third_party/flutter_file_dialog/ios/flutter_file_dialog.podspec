#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint flutter_file_dialog.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'flutter_file_dialog'
  s.version          = '3.3.0'
  s.summary          = 'Dialogs for picking and saving files in iOS.'
  s.description      = <<-DESC
A Flutter plugin providing dialogs for picking and saving files on iOS.
                       DESC
  s.homepage         = 'https://github.com/kineapps/flutter_file_dialog'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'KineApps' => 'https://github.com/kineapps' }
  s.source           = { :path => '.' }
  s.source_files = 'flutter_file_dialog/Sources/flutter_file_dialog/**/*.swift'
  s.dependency 'Flutter'
  s.platform = :ios, '13.0'

  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.swift_version = '5.9'
end
