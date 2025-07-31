#!/bin/bash

# Ultimate fix for Xcode 15+ -G flag issues
echo "Applying ultimate -G flag fix..."

# Navigate to iOS directory
cd ios

# Remove all Pods and start fresh
rm -rf Pods Podfile.lock

# Create a comprehensive fix script that runs after pod install
cat > fix_grpc_flags.rb << 'EOF'
def fix_grpc_compiler_flags(installer)
  puts "Fixing gRPC compiler flags for Xcode 15+..."
  
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      # Remove ALL instances of -G flag from compiler settings
      ['OTHER_CFLAGS', 'OTHER_CPLUSPLUSFLAGS', 'OTHER_SWIFT_FLAGS'].each do |setting|
        if config.build_settings[setting]
          if config.build_settings[setting].is_a?(Array)
            config.build_settings[setting].reject! { |flag| flag.include?('-G') }
          elsif config.build_settings[setting].is_a?(String)
            config.build_settings[setting] = config.build_settings[setting].gsub(/-G\S*/, '')
          end
        end
      end
      
      # Specifically target problematic libraries
      if target.name.include?('BoringSSL') || target.name.include?('gRPC') || target.name.include?('leveldb')
        config.build_settings['OTHER_CFLAGS'] = '$(inherited) -w'
        config.build_settings['OTHER_CPLUSPLUSFLAGS'] = '$(inherited) -w'
        config.build_settings['GCC_WARN_INHIBIT_ALL_WARNINGS'] = 'YES'
      end
      
      # Set deployment target
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
    end
  end
end
EOF

# Add the fix to Podfile
if ! grep -q "load.*fix_grpc_flags.rb" Podfile; then
  sed -i '' '1i\
load File.expand_path("fix_grpc_flags.rb", __dir__)
' Podfile
fi

# Update the post_install hook in Podfile to use our fix
sed -i '' '/post_install do |installer|/,/^end$/c\
post_install do |installer|\
  fix_grpc_compiler_flags(installer)\
  installer.pods_project.targets.each do |target|\
    flutter_additional_ios_build_settings(target)\
    target.build_configurations.each do |config|\
      config.build_settings["GCC_PREPROCESSOR_DEFINITIONS"] ||= [\
        "$(inherited)",\
        "PERMISSION_EVENTS=1",\
        "PERMISSION_REMINDERS=1",\
        "PERMISSION_CONTACTS=1",\
        "PERMISSION_CAMERA=1",\
        "PERMISSION_MICROPHONE=1",\
        "PERMISSION_SPEECH_RECOGNIZER=1",\
        "PERMISSION_PHOTOS=1",\
        "PERMISSION_NOTIFICATIONS=1",\
      ]\
      config.build_settings["IPHONEOS_DEPLOYMENT_TARGET"] = "13.0"\
      config.build_settings["OTHER_CFLAGS"] = ""\
      config.build_settings["OTHER_CPLUSPLUSFLAGS"] = ""\
      config.build_settings["OTHER_SWIFT_FLAGS"] = ""\
      config.build_settings["SWIFT_VERSION"] = "5.0"\
      config.build_settings["CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES"] = "YES"\
      config.build_settings["ENABLE_BITCODE"] = "NO"\
      config.build_settings["GCC_C_LANGUAGE_STANDARD"] = "gnu11"\
      config.build_settings["CLANG_CXX_LANGUAGE_STANDARD"] = "gnu++17"\
      config.build_settings["CLANG_CXX_LIBRARY"] = "libc++"\
    end\
  end\
  installer.pods_project.build_configurations.each do |config|\
    config.build_settings.delete("OTHER_CFLAGS")\
    config.build_settings.delete("OTHER_CPLUSPLUSFLAGS")\
    config.build_settings["OTHER_CFLAGS"] = ""\
    config.build_settings["OTHER_CPLUSPLUSFLAGS"] = ""\
  end\
end' Podfile

# Install pods with the new fix
pod install

echo "Ultimate fix applied! Try archiving again."
