#
# Be sure to run `pod lib lint VersaPlayer.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
    s.name             = 'VersaPlayer'
    s.version          = '2.2.8+akisute'
    s.summary          = 'Versatile AVPlayer implementation'
    
    s.description      = 'Versatile AVPlayer implementation.'
    
    s.homepage         = 'https://github.com/akisute/VersaPlayer'
    s.license          = { :type => 'MIT', :file => 'LICENSE' }
    s.author           = { 'Jose Quintero' => 'jose.juan.qm@gmail.com' }
    s.source           = { :git => 'https://github.com/akisute/VersaPlayer.git', :tag => s.version.to_s }
    
    s.ios.deployment_target = '9.0'
    s.tvos.deployment_target = '9.0'
    s.macos.deployment_target = '10.13'
    s.swift_version = '4.2'
    s.source_files = 'VersaPlayer/Classes/**/*'
end
