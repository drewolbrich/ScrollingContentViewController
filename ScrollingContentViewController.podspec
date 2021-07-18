Pod::Spec.new do |s|
  s.name             = 'ScrollingContentViewController'
  s.version          = '1.6.2'
  s.summary          = 'A Swift library that simplifies making a view controller\'s view scrollable'

  s.description      = <<-DESC
ScrollingContentViewController makes it easy to create a view controller with a
single scrolling content view, or to convert an existing static view controller
into one that scrolls. Most importantly, it takes care of several tricky
undocumented edge cases involving the keyboard, navigation controllers, and
device rotations.
                       DESC

  s.homepage         = 'https://github.com/drewolbrich/ScrollingContentViewController'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'drewolbrich' => 'drew@retroactivefiasco.com' }
  s.source           = { :git => 'https://github.com/drewolbrich/ScrollingContentViewController.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/drewolbrich'

  s.ios.deployment_target = '12.0'

  s.source_files = 'Sources/**/*.swift'

  s.frameworks = 'UIKit'

  s.swift_versions = ['4.2', '5.0']
end
