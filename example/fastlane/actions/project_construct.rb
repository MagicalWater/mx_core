module Fastlane
  module Actions
    class ProjectConstructAction < Action
      def self.run(params)

        YamlParseAction.add_general_project_lib()

        system "flutter pub get"

        # 複製flutter專案基礎結構
        copy_construct_entity()

        projectType = get_project_type()

        puts "專案類型: #{projectType}"

        # plugin 專案不加入
        if projectType != 'plugin'
          # 放置與本地溝通基礎channel
          place_native_channel()

          # 加入網路安全性設定
          add_network_config()

          # 加入 ios 的 webview_flutter 的 plist 宣告
          add_webview_flutter_need_ios()

          # 加入 android 的 gradle 配置(包含渠道等等)
          add_flavor_to_android_gradle()

          # 添加混淆配置
          add_obfuscate()
        end

        # 創建範例 json
        exJson = %{{
  "code": 100,
  "data": "data"
}}
        FileUtils.mkdir_p("assets/images")
        FileUtils.mkdir_p("assets/jsons")
        File.write("assets/jsons/ex_api.json", exJson)

        # 接著跑自動生成code三大組件action
        JsonBeanConvertGenerateAction.run(nil)
        AssetsGenerateAction.run(nil)
        RoutesGenerateAction.run(enforce_command: true)
      end

      # 加入網路配置設定
      # 安著以及ios發送http請求都需要加入此配置
      def self.add_network_config()
        # 配置android
        manifestFilePath = "android/app/src/main/AndroidManifest.xml"

        # 設置xml指定檔案
        ParseXmlAction.write(
          xml_path: manifestFilePath,
          node_array: ["application"],
          label: "android:networkSecurityConfig",
          value: "@xml/network_security_config",
        )

        # 設定網路權限
        ParseXmlAction.write(
          xml_path: manifestFilePath,
          node_array: ["manifest", "uses-permission"],
          label: "android:name",
          value: "android.permission.INTERNET",
        )

        # 寫入配置檔案
        FileUtils.mkdir_p('./android/app/src/main/res/xml')
        FileUtils.cp "./fastlane/files/network_security_config.xml", "./android/app/src/main/res/xml/network_security_config.xml"

        # 配置ios
        plistPath = "ios/Runner/Info.plist"

        SetInfoPlistValueAction.run(
          path: plistPath,
          key: "NSAppTransportSecurity",
          subkey: "NSAllowsArbitraryLoads",
          value: true,
        )
      end

      # 取得專案類型, 回傳字串
      def self.get_project_type()
        text = File.read('.metadata')
        projectType = ''
        text.gsub(/(?<=project_type:)( |\w)+/) { |f|
          projectType = f.strip
          f
        }
        projectType
      end

      # 放置 native channel code
      def self.place_native_channel()

        # 1. 處理flutter端的channel
        FileUtils.cp "./fastlane/files/native_channel.dart", "./lib/native_channel.dart"

        # 2. 處理android端的channel

        # 安著的 manifest 路徑
        manifestFilePath = "android/app/src/main/AndroidManifest.xml"
        androidKotlinPath = "android/app/src/main/kotlin"

        # 先取得 application id
        applicationId = ParseXmlAction.read(
          xml_path: manifestFilePath,
          node_array: ["manifest"],
          label: "package",
        )

        # 從 application id 取得實體路徑
        applicationIdPath = applicationId.gsub('.', '/')
        targetFolderPath = "#{androidKotlinPath}/#{applicationIdPath}"
        FileUtils.mkdir_p(targetFolderPath)

        # 將檔案寫入到android
        sourceFilePath = "./fastlane/files/FlutterChannel.kt"
        targetFilePath = "#{targetFolderPath}/FlutterChannel.kt"
        content = "package #{applicationId}" + File.read(sourceFilePath, :encoding => 'UTF-8')
        File.write(targetFilePath, content)

        # 在android上的MainActivity.kt增加code
        # 搜索 import 區域, 並插入缺少 import 的 widget
        targetFilePath = "#{targetFolderPath}/MainActivity.kt"
        content = File.read(targetFilePath, :encoding => 'UTF-8')
        content = content.gsub(/(import .+(\s)+)+/) { |c|
          addText = ""
          if !(c.include?('io.flutter.plugin.common.PluginRegistry'))
            # 需要加入
            addText = "import io.flutter.plugin.common.PluginRegistry\n"
          end
          c + addText
        }

        # 在 GeneratedPluginRegistrant.registerWith(this) 下面加入
        # FlutterChannel.registerWith(registrarFor(FlutterChannel::class.java.name))
        content = content.gsub(/(?<=GeneratedPluginRegistrant\.registerWith\(this\))(.|\s)*?(?=})/) { |c|
          addText = ""
          if !(c.include?('FlutterChannel.registerWith(registrarFor(FlutterChannel::class.java.name))'))
            # 需要加入
            addText = "FlutterChannel.registerWith(registrarFor(FlutterChannel::class.java.name))\n"
          end
          c + addText
        }
        File.write(targetFilePath, content)

        # 3. 處理ios端的channel

        # 將檔案寫入到ios
        fileName = "FlutterChannel.swift"
        targetPath = "ios/Runner"
        FileUtils.mkdir_p("#{targetPath}/flutter")
        FileUtils.cp "./fastlane/files/FlutterChannel.swift", "ios/Runner/flutter/FlutterChannel.swift"

        # 修改AppDelegate.swift的程式碼
        # 在 GeneratedPluginRegistrant.register(with: self) 下面加入
        # FlutterChannel.register(with: self.window.rootViewController as! FlutterViewController)
        targetFilePath = "ios/Runner/AppDelegate.swift"
        content = File.read(targetFilePath, :encoding => 'UTF-8')

        content = content.gsub(/(?<=GeneratedPluginRegistrant\.register\(with: self\))(.|\s)*?(?=return)/) { |c|
          addText = ""
          if !(c.include?('FlutterChannel.register(with: self.window.rootViewController as! FlutterViewController)'))
            # 需要加入
            addText = "\nFlutterChannel.register(with: self.window.rootViewController as! FlutterViewController)\n"
          end
          c + addText
        }
        File.write(targetFilePath, content)

        # 將 加入的 channel 添加到xcode配置
        XcodeParseAction.add_flutter_file_to_xcode()

      end


      # 加入 flavor/簽名/application id 配置到android gradle
      def self.add_flavor_to_android_gradle()

        # 修改 gradle 的配置
        gradlePath = "android/app/build.gradle"
        gradleString = File.read(gradlePath, :encoding => 'UTF-8')

        ignoreTag = "productFlavors"

        if File.readlines(gradlePath).grep(/#{ignoreTag}/).size == 0
          # 以 buildTypes 為支點做替代
          replaceString = File.read('./fastlane/files/gradle_add.txt', :encoding => 'UTF-8')
          gradleString = gradleString.gsub(/\}(\s)+?buildTypes \{(.|\s|)+?\}(\s)+\}/) {|typeBlock|
            replaceString
          }

          # 將替代後的字串寫回去
          File.write(gradlePath, gradleString)
        end

        # 增加 簽名key 的資訊
        SetKeyInfoAction.run(index: 0, index_need: '-1')
      end

      # 加入混淆配置
      def self.add_obfuscate()

        # 加入android的混淆配置
        propertiesPath = "./android/gradle.properties"
        searchTag = "extra-gen-snapshot-options=--obfuscate"
        if File.readlines(propertiesPath).grep(/#{searchTag}/).size == 0
          text = File.read(propertiesPath, :encoding => 'UTF-8') + "#{searchTag}\n"
          File.write(propertiesPath, text)
        end

        # 複製 android 混淆配置
        FileUtils.cp "./fastlane/files/proguard-rules.pro", "./android/app/proguard-rules.pro"

        # 加入ios的混淆配置
        searchTag = "EXTRA_GEN_SNAPSHOT_OPTIONS=--obfuscate"
        xcconfigPath = "./ios/Flutter/Release.xcconfig"
        if File.readlines(xcconfigPath).grep(/#{searchTag}/).size > 0
          text = File.read(xcconfigPath, :encoding => 'UTF-8') + "#{searchTag}\n"
          File.write(xcconfigPath, text)
        end

      end

      # 配置 webview_flutter 在ios上需要的權限宣告
      # io.flutter.embedded_views_preview
      def self.add_webview_flutter_need_ios()
        plistPath = "ios/Runner/Info.plist"
        SetInfoPlistValueAction.run(
          path: plistPath,
          key: "io.flutter.embedded_views_preview",
          value: true,
        )
      end

      # 創建基本專案構建
      def self.copy_construct_entity()
        require 'pathname'
        # FileUtils.copy_entry("fastlane/files/project_construct", "lib")

        FileHandleAction.get_all_files('fastlane/files/project_construct').each { |fileHash|
          segments = []
          Pathname.new(fileHash['path']).each_filename { |s|
            segments << s
          }

          if segments[-1].to_s.end_with?("_dart")
            segments[-1] = segments[-1].gsub(/_dart$/) { |m| ".dart" }
          end

          segments = segments[2..-1]
          segments[0] = 'lib'

          targetPath = segments.join('/')
          # puts "複製從 #{fileHash['path']} 到 #{targetPath}"

          # 使用 template 的方式載入檔案, 寫入目標
          text = FileHandleAction.get_template(fileHash['path'], fileHash)
          # puts "建立資料夾: #{File.dirname(targetPath)}"
          FileUtils.mkdir_p(File.dirname(targetPath))

          # 假如 targetPath 是 res/colors.dart, 檢測到檔案已存在時, 則略過
          if targetPath == 'lib/res/colors.dart' && File.exist?(targetPath)
            # 略過
          elsif targetPath == 'lib/bloc/application_bloc.dart' && File.exist?(targetPath)
            # 假如檔案是 bloc/application_bloc.dart, 檢查到檔案已存在則略過
            # 略過
          elsif targetPath == 'lib/localization/localization.dart' && File.exist?(targetPath)
            # 假如檔案是 localization/localization.dart, 檢查到檔案已存在則略過
            # 略過
          else
            File.write(targetPath, text)
          end

          # if fileHash['name'].include?('ex_db_dart')
            # puts "打印出內容: #{text}"
          # end
          # FileUtils.cp fileHash['path'], targetPath
        }
      end

      def self.description
        "初始化構建專案"
      end

      def self.authors
        ["https://github.com/MagicalWater/Water"]
      end

      def self.available_options
        [
        ]
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end
