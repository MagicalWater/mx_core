module Fastlane
  module Actions
    class SettingProjectAction < Action
      def self.run(params)

        envHash = params[:env_hash]

        puts "Actions path: #{Dir.pwd}"

        androidKotlinPath = "android/app/src/main/kotlin"
        manifestFilePath = "android/app/src/main/AndroidManifest.xml"
        sourcePath = "./fastlane/files"

        #########################################
        UI.message "放置 lib/native_channel.dart"
        fileName = "native_channel.dart"
        FileUtils.cp "#{sourcePath}/#{fileName}", "./lib/#{fileName}"

        #########################################
        UI.message "1. 設置 android manifest 的 application 類名"
        UI.message "2. 加入 android:networkSecurityConfig=@xml/network_security_config"
        ParseXmlAction.write(
          xml_path: manifestFilePath,
          node_array: ["application"],
          label: "android:name",
          value: "com.xing.mx_push.PushApplication",
        )
        ParseXmlAction.write(
          xml_path: manifestFilePath,
          node_array: ["application"],
          label: "android:networkSecurityConfig",
          value: "@xml/network_security_config",
        )

        #########################################
        UI.message "新增 res/xml/network_security_config.xml"
        fileName = "network_security_config.xml"
        fileName2 = "proguard-rules.pro"
        targetPath = "./android/app/src/main/res/xml"
        targetPath2 = "./android/app"
        FileUtils.mkdir_p(targetPath)
        FileUtils.cp "#{sourcePath}/#{fileName}", "#{targetPath}/#{fileName}"


        #########################################
        UI.message "新增 android/app/proguard-rules.pro"
        FileUtils.cp "#{sourcePath}/#{fileName2}", "#{targetPath2}/#{fileName2}"


        #########################################
        UI.message "位於 android/gradle.properties 加入 extra-gen-snapshot-options=--obfuscate"
        # 先檢查檔案裡面是否含有此tag, 不包含才加入
        searchTag = "extra-gen-snapshot-options=--obfuscate"
        fileFullPath = "./android/gradle.properties"
        if File.readlines(fileFullPath).grep(/#{searchTag}/).size > 0

        else
          text = File.read(fileFullPath, :encoding => 'UTF-8') + %{
#{searchTag}
          }
          File.open(fileFullPath, 'w') { |f|
            f.write(text)
          }
        end


        #########################################
        UI.message "新增 android/key.properties"
        SetKeyInfoAction.run(index: 0, index_need: '-1')


        #########################################
        UI.message "位於 build.gradle (Module: app), 新增渠道以及混淆相關配置"

        fileFullPath = "#{sourcePath}/gradle_add.txt"
        targetPath = "android/app/build.gradle"
        gradleString = File.read(targetPath, :encoding => 'UTF-8')
        ignoreTag = "productFlavors"

        File.open(fileFullPath, 'r:UTF-8') { |f|
          content = f.read
          if File.readlines(targetPath).grep(/#{ignoreTag}/).size > 0
            puts "不加入 渠道"
          else

            puts "加入 渠道"
            # 以 buildTypes 為支點做替代
            replaceString = gradleString.gsub(/\}(\s)+?buildTypes \{(.|\s|)+?\}(\s)+\}/) {|typeBlock|
              content
            }

            # 將替代後的字串寫回去
            File.write(targetPath, replaceString)
          end

        }


        #########################################
        UI.message "配置 FlutterChannel.kt"
        # 配置 FlutterChannel.kt 以及 MainActivity.kt
        # 取得 android 的 application id
        applicationId = ParseXmlAction.read(
          xml_path: manifestFilePath,
          node_array: ["manifest"],
          label: "package",
        )
        UI.message "取得 application id: #{applicationId}"
        applicationIdPath = applicationId.gsub('.', '/')
        targetFolderPath = "#{androidKotlinPath}/#{applicationIdPath}"
        FileUtils.mkdir_p(targetFolderPath)

        sourceFilePath = "#{sourcePath}/FlutterChannel.kt"
        targetFilePath = "#{targetFolderPath}/FlutterChannel.kt"
        content = "package #{applicationId}" + File.read(sourceFilePath, :encoding => 'UTF-8')
        File.write(targetFilePath, content)

        UI.message "配置 MainActivity.kt"
        sourceFilePath = "#{sourcePath}/MainActivity.kt"
        targetFilePath = "#{targetFolderPath}/MainActivity.kt"
        content = "package #{applicationId}" + File.read(sourceFilePath, :encoding => 'UTF-8')
        File.write(targetFilePath, content)


        #########################################
        UI.message "android 配置完成, 開始配置 ios"

        UI.message "Flutter/Release.xconfig 加入 EXTRA_GEN_SNAPSHOT_OPTIONS=--obfuscate"

        # 先檢查檔案裡面是否含有此tag, 不包含才加入
        searchTag = "EXTRA_GEN_SNAPSHOT_OPTIONS=--obfuscate"
        fileFullPath = "./ios/Flutter/Release.xcconfig"
        if File.readlines(fileFullPath).grep(/#{searchTag}/).size > 0

        else
          text = File.read(fileFullPath, :encoding => 'UTF-8') + %{
#{searchTag}
          }
          File.open(fileFullPath, 'w') { |f|
            f.write(text)
          }
        end

        #########################################
        UI.message "Info.plist 加入相應屬性"
        # Info.plist 加入相應屬性

        plistPath = "ios/Runner/Info.plist"

        SetInfoPlistValueAction.run(
          path: plistPath,
          key: "CFBundleDisplayName",
          value: "app名稱",
        )
        SetInfoPlistValueAction.run(
          path: plistPath,
          key: "NSCameraUsageDescription",
          value: "扫描新闻二维码及上传头像需要相机权限",
        )
        SetInfoPlistValueAction.run(
          path: plistPath,
          key: "NSPhotoLibraryUsageDescription",
          value: "选择图片上传头像需要相簿权限",
        )
        SetInfoPlistValueAction.run(
          path: plistPath,
          key: "io.flutter.embedded_views_preview",
          value: true,
        )
        SetInfoPlistValueAction.run(
          path: plistPath,
          key: "UIViewControllerBasedStatusBarAppearance",
          value: false,
        )
        SetInfoPlistValueAction.run(
          path: plistPath,
          key: "LSApplicationQueriesSchemes",
          value: ["mqq", "weixin", "alipays"],
        )
        SetInfoPlistValueAction.run(
          path: plistPath,
          key: "NSAppTransportSecurity",
          subkey: "NSAllowsArbitraryLoads",
          value: true,
        )

        #########################################
        UI.message "加入 AppDelegate.swift"
        fileName = "AppDelegate.swift"
        targetPath = "ios/Runner"
        FileUtils.cp "#{sourcePath}/#{fileName}", "#{targetPath}/#{fileName}"

        #########################################
        UI.message "加入 FlutterChannel.swift"
        fileName = "FlutterChannel.swift"
        targetPath = "ios/Runner"
        FileUtils.mkdir_p("#{targetPath}/flutter")
        FileUtils.cp "#{sourcePath}/#{fileName}", "#{targetPath}/flutter/#{fileName}"

        #########################################
        UI.message "更改 android application id 以及 app 名稱"
        androidBundleId = params[:android_bundle_id]

        SetAppInfoAndroidAction.run(
          android_name: envHash['android_default'],
          android_bundle_id: androidBundleId,
        )

        #########################################
        UI.message "新增依賴到pubspec.yaml"
        YamlParseAction.add_futures_project_lib()

        #########################################
        UI.message "將加入的 FlutterChannel.swift添加到xcode"
        XcodeBuildAction.run


        #########################################
        UI.message "開啟推送相關選項"
        XcodeParseAction.run(nil)

        #########################################
        UI.message "更改 ios bundle id 以及 app 名稱"

        iosName = params[:ios_name]
        iosBundleId = params[:ios_bundle_id]

        SetAppInfoIosAction.run(
          ios_name: iosName,
          ios_bundle_id: iosBundleId,
        )

        # app.dart 裡面的 appcode 需要改掉
        targetPath = "./test_driver/app.dart"
        contentString = File.read(targetPath, :encoding => 'UTF-8')
        contentString = contentString.gsub(/app0041/) {|search|
          File.basename(Dir.getwd)
        }

        File.write(targetPath, contentString)

        UI.message "全部完成"

      end

      def self.description
        "更改 ios bundle id 以及 app 名稱"
      end

      def self.authors
        ["https://github.com/MagicalWater/Water"]
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(
            key: :ios_name,
            description: "iOS App 名稱",
            is_string: true,
            optional: false
          ),
          FastlaneCore::ConfigItem.new(
            key: :ios_bundle_id,
            description: "iOS App 包名",
            is_string: true,
            optional: false
          ),
          FastlaneCore::ConfigItem.new(
            key: :android_bundle_id,
            description: "Android App 包名",
            is_string: true,
            optional: false
          ),
          FastlaneCore::ConfigItem.new(
            key: :env_hash,
            description: "環境變數",
            is_string: false,
            optional: false
          ),
        ]
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end
