#
# Be sure to run `pod lib lint wvtimelib.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'wvtimelib'
  s.version          = '2020.08.19'
  s.summary          = 'A short description of wvtimelib.'
# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/pfzq303/wvtimelib'
  # s.screenshots     = 'www.example/Users/hqq/Documents/admin/code/wvtimelibSwift/wvtimelibSwift.podspec.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'pfzq303' => 'pfzq303' }
  s.source           = { :git => 'https://github.com/pfzq303/wvtimelib.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.source_files = 'wvLC_Time/*.h','wvlib/Classes/**/*'
  s.vendored_libraries = 'wvLC_Time/*.a'

  s.public_header_files = 'wvLC_Time/**/*.h'
  # s.preserve_paths = 'script/xcodeproj.rb'
  #s.resources = 'wvLC_Time/wvRes.bundle'
  s.requires_arc = false
  s.static_framework = true
  $c_script = <<-EOF
  day=$(date -v -2d +%Y.%m.%d)
  if [ "$day" \\> "#{s.version}" ]; then
    echo "please upgrade sdk. current version: #{s.version}"
    exit 1
  fi
  EOF
  s.script_phase = { :name => 'check_version', :script => $c_script, :execution_position => :before_compile }
#  s.prepare_command = "ruby script/xcodeproj.rb"
  #s.frameworks = 'MediaPlayer', 'GameController'
  s.prefix_header_file = 'prefix.pch'
  #s.dependency 'JPush'
end
