# Temporary: adds the ShareExtension target to ios/Runner.xcodeproj.
require 'xcodeproj'

project = Xcodeproj::Project.open('ios/Runner.xcodeproj')
abort 'already there' if project.targets.any? { |t| t.name == 'ShareExtension' }
runner = project.targets.find { |t| t.name == 'Runner' }

ext = project.new_target(:app_extension, 'ShareExtension', :ios, '15.0', nil, :swift)
project.build_configurations.map(&:name).each do |name|
  next if ext.build_configurations.any? { |c| c.name == name }
  ext.add_build_configuration(name, name == 'Debug' ? :debug : :release)
end

group = project.main_group.new_group('ShareExtension', 'ShareExtension')
source = group.new_reference('ShareViewController.swift')
group.new_reference('Info.plist')
group.new_reference('ShareExtension.entitlements')
xcconfig = group.new_reference('ShareExtension.xcconfig')
ext.add_file_references([source])

ext.build_configurations.each do |config|
  config.base_configuration_reference = xcconfig
  s = config.build_settings
  s['INFOPLIST_FILE'] = 'ShareExtension/Info.plist'
  s['GENERATE_INFOPLIST_FILE'] = 'NO'
  s['CODE_SIGN_ENTITLEMENTS'] = 'ShareExtension/ShareExtension.entitlements'
  s['CODE_SIGN_STYLE'] = 'Automatic'
  s['PRODUCT_BUNDLE_IDENTIFIER'] = '$(APP_BUNDLE_ID).ShareExtension'
  s['PRODUCT_NAME'] = '$(TARGET_NAME)'
  s['SWIFT_VERSION'] = '5.0'
  s['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
  s['TARGETED_DEVICE_FAMILY'] = '1,2'
  # Opening the app goes through the responder chain to UIApplication.open.
  s['APPLICATION_EXTENSION_API_ONLY'] = 'NO'
  s['SKIP_INSTALL'] = 'YES'
  s['LD_RUNPATH_SEARCH_PATHS'] = ['$(inherited)', '@executable_path/Frameworks', '@executable_path/../../Frameworks']
end

runner_group = project.main_group.children.find { |g| g.display_name == 'Runner' }
runner_group.new_reference('Runner.entitlements')
runner.build_configurations.each do |config|
  config.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] = '$(APP_BUNDLE_ID)'
  config.build_settings['CODE_SIGN_ENTITLEMENTS'] = 'Runner/Runner.entitlements'
end

runner.add_dependency(ext)
embed = runner.new_copy_files_build_phase('Embed Foundation Extensions')
embed.symbol_dst_subfolder_spec = :plug_ins
file = embed.add_file_reference(ext.product_reference, true)
file.settings = { 'ATTRIBUTES' => ['RemoveHeadersOnCopy'] }
# Embedding after Flutter's Thin Binary script makes a build cycle.
runner.build_phases.delete(embed)
thin = runner.build_phases.index { |p| p.respond_to?(:name) && p.name == 'Thin Binary' }
abort 'no Thin Binary phase' unless thin
runner.build_phases.insert(thin, embed)

project.save
