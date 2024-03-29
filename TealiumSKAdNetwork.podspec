#
# Be sure to run `pod lib lint TealiumSKAdNetwork.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'TealiumSKAdNetwork'
  s.version          = '1.1.0'
  s.summary          = 'Tealium Swift and SKAdNetwork integration'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  Tealium's integration with Apple's SKAdNetwork
                       DESC

  s.homepage         = 'https://github.com/Tealium/tealium-ios-skadnetwork-remote-command'
  s.license          = { :type => "Commercial", :file => "LICENSE" }
  s.authors            = { "Tealium Inc." => "tealium@tealium.com",
                           "craigrouse"   => "craig.rouse@tealium.com",
                           "enricozannini" => "enrico.zannini@tealium.com",
                           "tylerrister" => "tyler.rister@tealium.com" }
  s.source           = { :git => 'https://github.com/Tealium/tealium-ios-skadnetwork-remote-command.git', :tag => "#{s.version}" }
  s.social_media_url   = "https://twitter.com/tealium"
  s.swift_version = "5.0"
  s.ios.deployment_target = '12.0'

  s.source_files = 'Sources/*.{swift}'
  
  s.ios.dependency 'tealium-swift/Core', '~> 2.12'
  s.ios.dependency 'tealium-swift/RemoteCommands', '~> 2.12'
end
