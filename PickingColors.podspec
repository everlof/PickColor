#
# Be sure to run `pod lib lint PickColor.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'PickingColors'
  s.version          = '0.2.0'
  s.summary          = 'A versatile color-picker with sliders, hex-presentation, manual input and history.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
A versatile color-picker library, that was inspired from the pod 'Color-Picker-for-iOS'.

The features planned for version 1.0 are:

- Manipulate 'hue' using tap and pan on a 1-d slider.
- Manipulate 'saturation' and 'value' using tap and pan using a 2-d color-map.
- Manually input hex-color using the keyboard on the device.
- Lastly selected colors are available within the picker to easily pick them again, or to see colors side by side when chosing color.

Future features planned are:

- Find complementing colors
- Improved performance for generating the color-map when sliding the hue (The performance is not currently bad due to the fact that each color-pixel is 4x4 in size).
- Integrate 'everlof/NameThatColor' so show a nice, textual name of a color as well.
DESC

  s.homepage         = 'https://github.com/everlof/PickColor'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'everlof' => 'everlof@gmail.com' }
  s.source           = { :git => 'https://github.com/everlof/PickColor.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '12.0'

  s.source_files  = 'PickColor/**/*.swift', 'PickColor/Source/Persistance/PickColorModel.xcdatamodeld', 'PickColor/Source/Persistance/PickColorModel.xcdatamodeld/*.xcdatamodel'
  s.resources = [ 'PickColor/Source/Persistance/PickColorModel.xcdatamodeld','PickColor/Source/Persistance/PickColorModel.xcdatamodeld/*.xcdatamodel']
  s.preserve_paths = 'PickColor/Source/Persistance/PickColorModel.xcdatamodeld'
  s.framework  = 'CoreData'

  s.swift_version = '5.0'

  # s.resource_bundles = {
  #   'NameThatColorA' => ['NameThatColorA/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'NameThatColor', '0.1'
end
