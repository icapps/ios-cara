#
# Be sure to run `pod lib lint Cara.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'Cara'
  s.version          = '1.0.0'
  s.summary          = 'Our webservice layer.'
  s.description      = <<-DESC
Cara is the webservice layer that is (or should be) most commonly used throughout our apps.
                       DESC

  s.homepage         = 'https://github.com/icapps/ios-cara'
  s.license          = { type: 'MIT', file: 'LICENSE' }
  s.author           = { 'Jelle Vandebeeck' => 'jelle@fousa.be' }
  s.source           = { git: 'https://github.com/cara/ios-cara.git', tag: s.version.to_s }
  s.social_media_url = 'https://twitter.com/icapps'

  s.ios.deployment_target = '10.0'
  s.tvos.deployment_target = '10.0'
  s.osx.deployment_target = '10.10'

  s.source_files = 'Sources/**/*'
  s.dependency 'CryptoSwift', '~> 0.13'
  s.dependency 'Connectivity', '~> 2.0.0'
end
