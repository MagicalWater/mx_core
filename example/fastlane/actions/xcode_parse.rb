module Fastlane
  module Actions
    class XcodeParseAction < Action
      # 啟動遠程推送
      def self.enable_remote_push()
        # 啟動推送
        enabled_push()

        # 啟動背景推送模式
        enabled_remote_notification()
      end

      # 重新添加ios/Runner/flutter資料夾裡面的檔案到xcode
      def self.add_flutter_file_to_xcode()
        project = Xcodeproj::Project.open("./ios/Runner.xcodeproj")
        appTarget = project.targets.first

        runnerGroup = project.main_group.find_subpath('Runner', false)

        # 取得路徑為 flutter 的群組 
        # 第二個參數false => group 不存在不自動創建
        flutterGroup = add_group(runnerGroup, 'flutter', 'flutter')

        add_files_to_group(appTarget, flutterGroup)

        project.save
      end

      # 添加一個group, 並將group資料夾底下的檔案都加入group
      def self.add_group(parent_group, group_name, group_path)
        # 先將已存在的group移除
        group = parent_group.find_subpath(group_path, false)

        if group != nil
          puts "app群組不為空, 將檔案全部移除"
          group.remove_from_project
        end

        # 創建新的 group
        parent_group.new_group(group_name, group_path, "<group>")
      end

      # 將某個group底下的所有檔案都加入group
      def self.add_files_to_group(target, group)
        puts "尋找資料夾: #{group.real_path}"
        Dir.foreach(group.real_path) do |entry|
          filePath = File.join(group.real_path, entry)

          if filePath.to_s.end_with?(".xcassets") then
            fileReference = group.new_reference(filePath)
            target.resources_build_phase.add_file_reference(fileReference,true)
          elsif File.directory?(filePath) && entry != '.' && entry != '..' then
            subGroup = group.new_group(entry, entry, "<group>")
            self.add_files_to_group(target, subGroup)
          elsif !File.directory?(filePath) && entry != ".DS_Store"  then
            fileReference = group.new_reference(filePath)
            # 如果不是頭文件則繼續增加到Build Phase中，PB文件需要加編譯標誌
            if filePath.to_s.end_with?("pbobjec.m", "pbobjc.mm") then
              target.add_file_references([fileReference],'-fno-objc-arc')
            elsif filePath.to_s.end_with?(".m",".mm",".cpp",".swift") then
              target.source_build_phase.add_file_reference(fileReference,true)
            elsif filePath.to_s.end_with?(".storyboard",".xib") then
              target.resources_build_phase.add_file_reference(fileReference,true)
            end
          end
            
        end
      end

      # 添加 iMessage Extension
      # 若當前已經有同樣名稱的 target 存在, 則不動作
      # 此方法暫時因為 info.plist 相關預設檔案來源的問題, 佔不開放使用
      def self.add_imessage_extension(name)
        project = Xcodeproj::Project.open("./ios/Runner.xcodeproj")

        # app專案的 target 通常是第一個
        exist = project.targets.any? { |target|
          target.name == name
        }

        if exist
          puts "target 名稱: #{name} 已存在, 重新添加底下所有的檔案"
        else
          extensionGroup = add_group(project.main_group, name, name)
          extensionTarget = project.new_target(:messages_extension, name, :ios, "10.0", group, :swift)
          add_files_to_group(extensionTarget, extensionGroup)
        end
      end

      # 啟動 background_mode 的 remote_notifications
      def self.enabled_remote_notification()
        # 激活 SystemCapabilities 底下的 com.apple.BackgroundModes
        project = Xcodeproj::Project.open("../ios/Runner.xcodeproj")
        appTarget = project.targets.first
        capabilities = system_capabilities(project, appTarget)
        capabilities['com.apple.BackgroundModes'] = {"enabled" => "1"}

        # 添加 key 到 Info.plist
        SetInfoPlistValueAction.run(
          path: "../ios/Runner/Info.plist",
          key: "UIBackgroundModes",
          value: ["fetch", "remote-notification"],
        )
        project.save()
      end

      # 開啟推送
      def self.enabled_push()

        # 激活 SystemCapabilities 底下的 com.apple.Push
        project = Xcodeproj::Project.open("../ios/Runner.xcodeproj")
        appTarget = project.targets.first
        capabilities = system_capabilities(project, appTarget)
        capabilities['com.apple.Push'] = {"enabled" => "1"}

        # 將 build_setting 底下的 CODE_SIGN_ENTITLEMENTS 指向 Runner.entitlements
        sectionObject = getRootTargetSectionObject(project, appTarget)
        sectionObject.build_configurations.each do |config|
          config.build_settings['CODE_SIGN_ENTITLEMENTS'] = 'Runner/Runner.entitlements'
          config.build_settings['CODE_SIGN_INJECT_BASE_ENTITLEMENTS'] = 'YES'
        end

        # 取得 Runner.entitlements
        generate_entitlements()

        # 將檔案 entitlements 的 ref 加入 ios/Runner 底下
        runnerTargetMainGroup = project.main_group.find_subpath('Runner', false)
        isRefExist = runnerTargetMainGroup.files.any? { |file| file.path.include? 'Runner.entitlements' }
        if !isRefExist
          runnerTargetMainGroup.new_reference('Runner.entitlements')
        end

        project.save()
      end

      # 創建 Runner.entitlements, 若不存在則自動創建
      def self.generate_entitlements()
        filePath = "../ios/Runner/Runner.entitlements"
        if !File.exist?(filePath)
          content = %{<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>aps-environment</key>
  <string>development</string>
</dict>
</plist>}
          File.write(filePath, content)
        end
        SetInfoPlistValueAction.run(
          path: filePath,
          key: "aps-environment",
          value: "development",
        )

      end

      def self.getRootTargetSectionObject(project, target)
        sectionObject = {}
        project.objects.each do |obj|
          if obj.uuid == target.uuid
            sectionObject = obj
            break
          end
        end
        return sectionObject
      end

      def self.system_capabilities(project, target)
        targets_attributes = project.root_object.attributes['TargetAttributes']
        target_attributes = targets_attributes[target.uuid]
        if !target_attributes.key?('SystemCapabilities')
          target_attributes['SystemCapabilities'] = {}
        end
        target_attributes['SystemCapabilities']
      end

      def self.description
        "xcode 激活 推送"
      end

      def self.available_options
        [
        ]
      end

      def self.authors
        ["https://github.com/MagicalWater/Water"]
      end

      def self.is_supported?(platform)
        platform == :ios
      end
    end
  end
end
