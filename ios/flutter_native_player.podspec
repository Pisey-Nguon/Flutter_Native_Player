#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint flutter_native_player.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'flutter_native_player'
  s.version          = '1.0.0'
  s.summary          = 'Flutter plugin for playing video on flutter that is based on view configuration of the Android and iOS.'
  s.description      = <<-DESC
A new flutter plugin project.
                       DESC
  s.homepage         = 'https://github.com/Pisey-Nguon/Flutter_Native_Player'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Pisey Nguon' => 'n.sey168@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '9.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
