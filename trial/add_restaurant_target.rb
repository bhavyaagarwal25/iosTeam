#!/usr/bin/env ruby
# add_restaurant_target.rb
#
# Adds a "RestaurantApp" iOS application target to the Xcode project.
# Works around Xcode 16's PBXFileSystemSynchronizedRootGroup by using
# a plain PBXGroup for the RestaurantApp folder (which is NOT a
# synchronized group — it's a regular folder we created manually).
#
# Source files compiled into RestaurantApp:
#
#   RestaurantApp/  (own files)
#     RestaurantApp.swift, RestaurantRootView.swift,
#     RestaurantMeshReceiver.swift, IncomingOrderCard.swift,
#     MeshAckPacket.swift
#
#   Shared from trial/Mesh/
#     OrderPacket.swift, KeychainService.swift, MeshPacketSigner.swift
#
#   Shared from trial/Models/
#     ZomatoCartItem.swift, Restaurant.swift

require 'xcodeproj'

PROJECT_PATH  = '/Users/shubhsinghal/iosTeam/trial/trial.xcodeproj'
TEAM_ID       = '229LDLFY2Y'
BUNDLE_ID     = 'com.bhavy1a.restaurantapp'
TARGET_NAME   = 'RestaurantApp'
DEPLOYMENT    = '17.0'
BASE          = '/Users/shubhsinghal/iosTeam/trial'

project = Xcodeproj::Project.open(PROJECT_PATH)

# ── Guard ────────────────────────────────────────────────────────────────────
if project.targets.find { |t| t.name == TARGET_NAME }
  puts "#{TARGET_NAME} already exists — nothing to do."
  exit 0
end

# ── 1. New application target ─────────────────────────────────────────────────
target = project.new_target(:application, TARGET_NAME, :ios, DEPLOYMENT)

# ── 2. Build settings ─────────────────────────────────────────────────────────
target.build_configurations.each do |cfg|
  s = cfg.build_settings
  s['PRODUCT_BUNDLE_IDENTIFIER']    = BUNDLE_ID
  s['PRODUCT_NAME']                 = TARGET_NAME
  s['DEVELOPMENT_TEAM']             = TEAM_ID
  s['CODE_SIGN_STYLE']              = 'Automatic'
  s['SWIFT_VERSION']                = '5.0'
  s['TARGETED_DEVICE_FAMILY']       = '1,2'
  s['IPHONEOS_DEPLOYMENT_TARGET']   = DEPLOYMENT
  s['GENERATE_INFOPLIST_FILE']      = 'YES'
  s['ENABLE_PREVIEWS']              = 'YES'
  s['MARKETING_VERSION']            = '1.0'
  s['CURRENT_PROJECT_VERSION']      = '1'
  s['SWIFT_APPROACHABLE_CONCURRENCY']                  = 'YES'
  s['SWIFT_DEFAULT_ACTOR_ISOLATION']                   = 'MainActor'
  s['SWIFT_UPCOMING_FEATURE_MEMBER_IMPORT_VISIBILITY'] = 'YES'
  s['INFOPLIST_KEY_NSLocalNetworkUsageDescription'] =
    'RestaurantApp uses Bluetooth and peer Wi-Fi to receive orders from nearby customer devices.'
  s['INFOPLIST_KEY_NSBonjourServices'] =
    '_eternallite-ord._tcp _eternallite-ord._udp'
  s['INFOPLIST_KEY_UIApplicationSceneManifest_Generation']      = 'YES'
  s['INFOPLIST_KEY_UIApplicationSupportsIndirectInputEvents']    = 'YES'
  s['INFOPLIST_KEY_UILaunchScreen_Generation']                  = 'YES'
  s['INFOPLIST_KEY_UISupportedInterfaceOrientations_iPhone'] =
    'UIInterfaceOrientationPortrait UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight'
  s['INFOPLIST_KEY_UISupportedInterfaceOrientations_iPad'] =
    'UIInterfaceOrientationPortrait UIInterfaceOrientationPortraitUpsideDown UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight'
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

# ── 3. File groups ────────────────────────────────────────────────────────────
# main_group is a plain PBXGroup — safe to use new_group on.
root = project.main_group

# RestaurantApp own files — new plain group pointing to RestaurantApp/ folder
ra_group = root.new_group('RestaurantApp', "#{BASE}/RestaurantApp", '<absolute>')

# Shared Mesh group
mesh_group   = root.new_group('Shared-Mesh',   "#{BASE}/trial/Mesh",   '<absolute>')
models_group = root.new_group('Shared-Models', "#{BASE}/trial/Models", '<absolute>')

# ── 4. File references + add to Sources build phase ───────────────────────────
sources_phase = target.source_build_phase

def add_source(group, abs_path, sources_phase)
  ref = group.new_file(abs_path, '<absolute>')
  sources_phase.add_file_reference(ref)
  ref
end

# RestaurantApp own sources
%w[
  RestaurantApp.swift
  RestaurantRootView.swift
  RestaurantMeshReceiver.swift
  IncomingOrderCard.swift
  MeshAckPacket.swift
].each { |f| add_source(ra_group, "#{BASE}/RestaurantApp/#{f}", sources_phase) }

# Shared Mesh sources (only what RestaurantApp actually needs)
%w[
  OrderPacket.swift
  KeychainService.swift
  MeshPacketSigner.swift
].each { |f| add_source(mesh_group, "#{BASE}/trial/Mesh/#{f}", sources_phase) }

# Shared Model sources
%w[
  ZomatoCartItem.swift
  Restaurant.swift
].each { |f| add_source(models_group, "#{BASE}/trial/Models/#{f}", sources_phase) }

# ── 5. Add product reference to Products group ────────────────────────────────
products = root.children.find { |c| c.respond_to?(:name) && c.name == 'Products' }
if products && target.product_reference
  products << target.product_reference
end

# ── 6. Save ───────────────────────────────────────────────────────────────────
project.save

puts "✅  #{TARGET_NAME} target created."
puts "    Bundle ID : #{BUNDLE_ID}"
puts "    Sources   : 5 own + 3 Mesh + 2 Models = 10 files"
