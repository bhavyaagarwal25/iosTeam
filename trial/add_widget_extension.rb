require 'xcodeproj'

project_path = '/Users/shubhsinghal/iosTeam/trial/trial.xcodeproj'
project = Xcodeproj::Project.open(project_path)

if project.targets.find { |t| t.name == 'trialWidgetExtension' }
  puts "Widget Extension target already exists."
  exit 0
end

app_target = project.targets.find { |t| t.name == 'trial' }

widget_target = project.new_target(
  :app_extension,
  'trialWidgetExtension',
  :ios,
  '16.1'
)

widget_target.build_configurations.each do |config|
  config.build_settings['INFOPLIST_FILE'] = 'trialWidgetExtension/Info.plist'
  config.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] = 'hackathonieeeeeebhavi.trialWidgetExtension'
  config.build_settings['PRODUCT_NAME'] = '$(TARGET_NAME)'
  config.build_settings['SWIFT_VERSION'] = '5.0'
  config.build_settings['SKIP_INSTALL'] = 'YES'
  config.build_settings['TARGETED_DEVICE_FAMILY'] = '1,2'
end

Dir.mkdir('trialWidgetExtension') unless Dir.exist?('trialWidgetExtension')

info_plist_path = 'trialWidgetExtension/Info.plist'
File.write(info_plist_path, <<~PLIST)
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>NSExtension</key>
    <dict>
        <key>NSExtensionPointIdentifier</key>
        <string>com.apple.widgetkit-extension</string>
    </dict>
</dict>
</plist>
PLIST

widget_bundle_path = 'trialWidgetExtension/trialWidgetBundle.swift'
File.write(widget_bundle_path, <<~SWIFT)
import WidgetKit
import SwiftUI

@main
struct trialWidgetBundle: WidgetBundle {
    var body: some Widget {
        OrderLiveActivityWidget()
    }
}
SWIFT

# Add files directly by path instead of traversing groups
files_to_add = [
  'trialWidgetExtension/trialWidgetBundle.swift',
  'trial/LiveActivity/BlinkitActivityAttributes.swift',
  'trial/LiveActivity/OrderLiveActivityWidget.swift',
  'trial/Resources/BlinkitTheme.swift'
]

files_to_add.each do |path|
  file_ref = project.new_file(path)
  widget_target.source_build_phase.add_file_reference(file_ref)
end

embed_phase = app_target.new_copy_files_build_phase('Embed Foundation Extensions')
embed_phase.symbol_dst_subfolder_spec = :plug_ins
embed_phase.add_file_reference(widget_target.product_reference, true)

project.save
puts "Successfully added trialWidgetExtension target."
