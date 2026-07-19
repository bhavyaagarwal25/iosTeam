#!/usr/bin/env ruby
# setup_project.rb
#
# Idempotent script that does THREE things in one pass:
#
#  1. Switches the main `trial` target from GENERATE_INFOPLIST_FILE to a
#     real trial-Info.plist — the only way to express array-valued keys
#     like NSBonjourServices and BGTaskSchedulerPermittedIdentifiers.
#
#  2. Adds the RestaurantApp target (if not already present) with its own
#     RestaurantApp-Info.plist.
#
#  3. Verifies the project parses cleanly before exiting.
#
# Run:  ruby setup_project.rb

require 'xcodeproj'

PROJECT_PATH = '/Users/shubhsinghal/iosTeam/trial/trial.xcodeproj'
BASE         = '/Users/shubhsinghal/iosTeam/trial'
TEAM_ID      = '229LDLFY2Y'

project = Xcodeproj::Project.open(PROJECT_PATH)

# ═══════════════════════════════════════════════════════════════════════════
# PART 1 — Fix the `trial` target: point it at a real Info.plist
# ═══════════════════════════════════════════════════════════════════════════
trial_target = project.targets.find { |t| t.name == 'trial' }
raise "Could not find 'trial' target" unless trial_target

trial_target.build_configurations.each do |cfg|
  s = cfg.build_settings
  s.delete('GENERATE_INFOPLIST_FILE')
  # Remove all INFOPLIST_KEY_ entries — they're superseded by the plist file
  s.keys.select { |k| k.start_with?('INFOPLIST_KEY_') }.each { |k| s.delete(k) }
  s['INFOPLIST_FILE'] = 'trial/trial-Info.plist'
end

puts "✓ trial target: switched to trial/trial-Info.plist"

# ═══════════════════════════════════════════════════════════════════════════
# PART 2 — Add RestaurantApp target (idempotent)
# ═══════════════════════════════════════════════════════════════════════════
if project.targets.find { |t| t.name == 'RestaurantApp' }
  puts "✓ RestaurantApp target already exists — skipping"
else
  restaurant = project.new_target(:application, 'RestaurantApp', :ios, '17.0')

  restaurant.build_configurations.each do |cfg|
    s = cfg.build_settings
    s['PRODUCT_BUNDLE_IDENTIFIER']    = 'com.bhavy1a.restaurantapp'
    s['PRODUCT_NAME']                 = 'RestaurantApp'
    s['DEVELOPMENT_TEAM']             = TEAM_ID
    s['CODE_SIGN_STYLE']              = 'Automatic'
    s['SWIFT_VERSION']                = '5.0'
    s['TARGETED_DEVICE_FAMILY']       = '1,2'
    s['IPHONEOS_DEPLOYMENT_TARGET']   = '17.0'
    s['INFOPLIST_FILE']               = 'RestaurantApp/RestaurantApp-Info.plist'
    s['GENERATE_INFOPLIST_FILE']      = 'NO'
    s['ENABLE_PREVIEWS']              = 'YES'
    s['MARKETING_VERSION']            = '1.0'
    s['CURRENT_PROJECT_VERSION']      = '1'
    s['SWIFT_APPROACHABLE_CONCURRENCY']                  = 'YES'
    s['SWIFT_DEFAULT_ACTOR_ISOLATION']                   = 'MainActor'
    s['SWIFT_UPCOMING_FEATURE_MEMBER_IMPORT_VISIBILITY'] = 'YES'
    if cfg.name == 'Debug'
      s['SWIFT_OPTIMIZATION_LEVEL']            = '-Onone'
      s['SWIFT_ACTIVE_COMPILATION_CONDITIONS'] = 'DEBUG'
      s['ONLY_ACTIVE_ARCH']                    = 'YES'
      s['MTL_ENABLE_DEBUG_INFO']               = 'INCLUDE_SOURCE'
    else
      s['SWIFT_COMPILATION_MODE'] = 'wholemodule'
      s['VALIDATE_PRODUCT']       = 'YES'
    end
  end

  # Source file groups
  root = project.main_group
  ra_group     = root.new_group('RestaurantApp',  "#{BASE}/RestaurantApp", '<absolute>')
  mesh_group   = root.new_group('Shared-Mesh',    "#{BASE}/trial/Mesh",    '<absolute>')
  models_group = root.new_group('Shared-Models',  "#{BASE}/trial/Models",  '<absolute>')

  phase = restaurant.source_build_phase

  def add_src(group, abs_path, phase, project)
    ref = group.new_file(abs_path, '<absolute>')
    phase.add_file_reference(ref)
  end

  %w[RestaurantApp.swift RestaurantRootView.swift RestaurantMeshReceiver.swift
     IncomingOrderCard.swift MeshAckPacket.swift].each do |f|
    add_src(ra_group, "#{BASE}/RestaurantApp/#{f}", phase, project)
  end

  %w[OrderPacket.swift KeychainService.swift MeshPacketSigner.swift].each do |f|
    add_src(mesh_group, "#{BASE}/trial/Mesh/#{f}", phase, project)
  end

  %w[ZomatoCartItem.swift Restaurant.swift].each do |f|
    add_src(models_group, "#{BASE}/trial/Models/#{f}", phase, project)
  end

  # Add product to Products group
  products = root.children.find { |c| c.respond_to?(:name) && c.name == 'Products' }
  products << restaurant.product_reference if products && restaurant.product_reference

  puts "✓ RestaurantApp target: created with 10 source files"
end

# ═══════════════════════════════════════════════════════════════════════════
# PART 3 — Save and verify
# ═══════════════════════════════════════════════════════════════════════════
project.save
puts "✓ Project saved"

# Quick sanity check using xcodebuild -list
result = `xcodebuild -project "#{PROJECT_PATH}" -list 2>&1`
if result.include?('trial') && !result.include?('damaged')
  puts "✓ Project parses cleanly"
  puts ""
  puts "Targets now in project:"
  result.scan(/^\s{8}(\w+)$/).flatten.each { |t| puts "  • #{t}" }
else
  puts "✗ Project still has parse error:"
  puts result
  exit 1
end
