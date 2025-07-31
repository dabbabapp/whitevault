def fix_grpc_compiler_flags(installer)
  puts "Fixing gRPC compiler flags for Xcode 15+..."
  
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      # Remove ALL instances of -G flag from compiler settings
      ['OTHER_CFLAGS', 'OTHER_CPLUSPLUSFLAGS', 'OTHER_SWIFT_FLAGS', 'GCC_PREPROCESSOR_DEFINITIONS'].each do |setting|
        if config.build_settings[setting]
          if config.build_settings[setting].is_a?(Array)
            config.build_settings[setting].reject! { |flag| flag.to_s.include?('-G') }
            config.build_settings[setting] = config.build_settings[setting].map { |flag| flag.to_s.gsub(/-G\S*/, '') }
          elsif config.build_settings[setting].is_a?(String)
            config.build_settings[setting] = config.build_settings[setting].gsub(/-G\S*/, '')
          end
        end
      end
      
      # Completely reset problematic flags for ALL targets
      config.build_settings['OTHER_CFLAGS'] = '$(inherited) -w'
      config.build_settings['OTHER_CPLUSPLUSFLAGS'] = '$(inherited) -w'
      
      # Fix GTMSessionFetcher module issue
      if target.name.include?('GTMSessionFetcher') || target.name.include?('FirebaseStorage')
        puts "  Fixing GTMSessionFetcher module for #{target.name}"
        config.build_settings['DEFINES_MODULE'] = 'YES'
        config.build_settings.delete('MODULEMAP_FILE')
      end
      
      # Specifically target problematic libraries including nanopb
      if target.name.include?('BoringSSL') || target.name.include?('gRPC') || target.name.include?('leveldb') || target.name.include?('nanopb') || target.name.include?('abseil')
        puts "  Applying aggressive fix to #{target.name}"
        config.build_settings['OTHER_CFLAGS'] = '-w'
        config.build_settings['OTHER_CPLUSPLUSFLAGS'] = '-w'
        config.build_settings['GCC_WARN_INHIBIT_ALL_WARNINGS'] = 'YES'
        config.build_settings['CLANG_WARN_DEPRECATED_OBJC_IMPLEMENTATIONS'] = 'NO'
        config.build_settings['CLANG_WARN_OBJC_IMPLICIT_RETAIN_SELF'] = 'NO'
        
        # Remove any existing compiler flags that might contain -G
        config.build_settings.delete('WARNING_CFLAGS')
        config.build_settings.delete('GCC_WARN_64_TO_32_BIT_CONVERSION')
      end
      
      # Set deployment target
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
    end
  end
  
  # Also check and fix project-level settings
  installer.pods_project.build_configurations.each do |config|
    config.build_settings['OTHER_CFLAGS'] = '$(inherited) -w'
    config.build_settings['OTHER_CPLUSPLUSFLAGS'] = '$(inherited) -w'
  end
end
