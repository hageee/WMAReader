#platform :ios, '8.0'

use_frameworks!

target 'WebMangaAntennaReader' do
  pod 'CMPopTipView', '2.2.0'
end

post_install do | installer |
    require 'fileutils'
    FileUtils.cp_r('Pods/Target Support Files/Pods-WebMangaAntennaReader/Pods-WebMangaAntennaReader-acknowledgements.plist', 'WebMangaAntennaReader/Settings.bundle/Acknowledgements.plist', :remove_destination => true)
end