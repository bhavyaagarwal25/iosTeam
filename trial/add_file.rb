require 'xcodeproj'

project_path = 'trial.xcodeproj'
project = Xcodeproj::Project.open(project_path)
target = project.targets.first

file_path = 'trial/Intents/BlinkitAppIntents.swift'

# Create Intents group if it doesn't exist
group = project.main_group.find_subpath(File.join('trial', 'Intents'), true)
group.set_source_tree('<group>')
group.set_path('Intents')

file_ref = group.new_reference(File.basename(file_path))
target.add_file_references([file_ref])

project.save
puts "Added #{file_path} to target!"
