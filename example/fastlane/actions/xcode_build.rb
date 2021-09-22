module Fastlane
  module Actions
    class XcodeBuildAction < Action
      def self.run()

        extensionName = "message"
        project = Xcodeproj::Project.open("./ios/Runner.xcodeproj")
        #puts "target name = #{app_target.name}"

        appTarget = project.targets.first
        oldAppTargetGroup = self.get_exist_group(project, "flutter")
        if oldAppTargetGroup != nil
          self.remove_files_from_group(appTarget, oldAppTargetGroup)
          oldAppTargetGroup.remove_from_project
        end
        newAppTargetGroup = self.create_group(project, "flutter", "Runner/flutter")
        self.add_files_to_group(project, appTarget, newAppTargetGroup)

        # 取得已存在的 group, 是為了刪除引用
        oldGroup = self.get_exist_group(project, extensionName)
        newGroup = self.create_group(project, extensionName, extensionName)
        target = self.get_target(project, :messages_extension, extensionName, newGroup, oldGroup)

        # 將 group 底下的所有檔案與資料夾加入 target
        self.add_files_to_group(project, target, newGroup)

        # 設定 build_setting 的值
        target.build_configuration_list.set_setting('INFOPLIST_FILE', "#{extensionName}/Info.plist")
        target.build_configuration_list.set_setting('ASSETCATALOG_COMPILER_APPICON_NAME', "iMessage App Icon")
        target.build_configuration_list.set_setting('PRODUCT_NAME', extensionName)
        #target.build_configuration_list.set_setting('PRODUCT_BUNDLE_IDENTIFIER', "com.ex.bundle")
        target.build_configuration_list.set_setting('ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES', "No")
        target.build_configuration_list.set_setting('ENABLE_BITCODE', "No")
        target.build_configuration_list.set_setting('SWIFT_VERSION', "4.0")

        #embed_frameworks_build_phase = project.new(Xcodeproj::Project::Object::PBXCopyFilesBuildPhase)
        #embed_frameworks_build_phase.name = 'Embed Frameworks'
        #embed_frameworks_build_phase.symbol_dst_subfolder_spec = :frameworks

        appexRef = target.product_reference

        dependency = appTarget.dependency_for_target(target)

        # 新增 dependency 裡的 target
        if dependency
          UI.message "app target 的 dependency 已包含 #{target.name}"
        else
          UI.message "app target 的 dependency 加入 #{target.name}"
          appTarget.add_dependency(target)
        end

        # 刪除 dependency 裡的 target
        #if dependency
        #  UI.message "app target 的 dependency 刪除 #{target.name}"
        #  appTarget.dependencies.delete(dependency)
        #else
        #  UI.message "app target 的 dependency 不包含 #{target.name}"
        #end

        # Add or remove .appex copy jobs
        embed_extensions_phase = appTarget.copy_files_build_phases.find do |copy_phase|
          # copy_phase.name == 'Embed Frameworks'
          copy_phase.symbol_dst_subfolder_spec == :plug_ins
        end

        # 找不到套用的 app 擴展
        if embed_extensions_phase.nil?
          # 建立一個新的
          UI.message "找不到 app extension group, 建立一個新的"
          embed_extensions_phase = appTarget.new_copy_files_build_phase('Embed App Extensions')
          embed_extensions_phase.symbol_dst_subfolder_spec = :plug_ins
        end

        findRef = embed_extensions_phase.files_references.find do |ref|
          ref.path.include? appexRef.path
        end

        appex_included = !findRef.nil?

        # 加入 embed binary 的 appex
        if appex_included
          UI.message "App target 的 embeds 已包含 #{appexRef.display_name}"
        else
          UI.message "App target 的 embeds 加入 #{appexRef.display_name}"
          build_file = embed_extensions_phase.add_file_reference(appexRef)
          build_file.settings = { "ATTRIBUTES" => ['RemoveHeadersOnCopy'] }
        end

        # 刪除 embed binary 的 appex
        #if appex_included
        #puts "App target 的 embeds 刪除 #{appexRef.display_name}"
        #  embed_extensions_phase.remove_file_reference(appexRef)
        #else
        #  puts "App target 的 embeds 不包含 #{appexRef.display_name}"
        #end

        # 儲存
        project.save

      end

      # 取得 target, 沒有的話就創建新的
      def self.get_target(project, type, name, new_group, old_group)
        projectTarget = ""
        if self.is_target_exist(project, name)
          project.targets.each { |target|
            if target.name == name
              projectTarget = target
            end
          }
          # 首先刪除所有舊的檔案參考
          if old_group != nil
            self.remove_files_from_group(projectTarget, old_group)
            old_group.remove_from_project
          end
          product = new_group.new_product_ref_for_target(name, :messages_extension)
          projectTarget.product_reference = product
        else
          projectTarget = project.new_target(type, name, :ios, "10.0", new_group, :swift)
        end
        projectTarget
      end

      def self.is_target_exist(project, name)
        exist = project.targets.any? { |target|
          target.name == name
        }
        UI.message "target - #{name} 是否存在: #{exist}"
        exist
      end

      # 取得 已存在的舊group
      def self.get_exist_group(project, path)
        group = project.main_group.find_subpath(path, false)
        group
      end

      # 取得 group, 如果已有舊的存在, 那就刪除, 重建新的
      def self.create_group(project, group_name, path)
        group = project.main_group.new_group(group_name, path, "<group>")
        group
      end

      def self.is_group_exist(project, group_name, path)
        subGroup = project.main_group.find_subpath(path, false)
        if subGroup == nil
          exist = false
        else
          exist = subGroup.real_path != project.main_group.real_path
        end
        UI.message "group - #{path} 是否存在: #{exist}"
        exist
      end

      # 自群組移除檔案
      def self.remove_files_from_group(target, group)
        group.files.each do |file|
          #UI.message "打印檔案: #{file.real_path}"
          if file.real_path.to_s.end_with?(".m",".mm",".cpp",".swift") then
            #UI.message "刪除檔案: #{file.real_path}"
            target.source_build_phase.remove_file_reference(file)
          elsif file.real_path.to_s.end_with?(".plist",".storyboard",".xib", ".xcassets") then
            # .xcassets 刪除了會造成 Assets.xcassets 找不到 folder 的問題
            #UI.message "刪除資源: #{file.real_path}"
            target.resources_build_phase.remove_file_reference(file)
          end
        end

        group.groups.each do |sub|
          self.remove_files_from_group(target, sub)
          sub.remove_from_project
        end
      end

      # 添加檔案進入群組
      def self.add_files_to_group(project, target, group)
        Dir.foreach(group.real_path) do |entry|
          filePath = File.join(group.real_path, entry)

          # puts filePath

          # 過濾目錄以及.DS_Store
          if !File.directory?(filePath) && entry != ".DS_Store" && !filePath.to_s.include?(".xcassets") then
            # 向group中增加文件引用
            puts "加入檔案: #{filePath}"
            fileReference = group.new_reference(filePath)
            # 如果不是頭文件則繼續增加到Build Phase中，PB文件需要加編譯標誌
            if filePath.to_s.end_with?("pbobjec.m", "pbobjc.mm") then
              target.add_file_references([fileReference],'-fno-objc-arc')
            elsif filePath.to_s.end_with?(".m",".mm",".cpp",".swift") then
              target.source_build_phase.add_file_reference(fileReference,true)
            elsif filePath.to_s.end_with?(".storyboard",".xib") then
              target.resources_build_phase.add_file_reference(fileReference,true)
            end
          elsif File.directory?(filePath) && entry != '.' && entry != '..' then

            # 目錄遞歸添加, 如果是 xcassets 的圖檔資源, 也需要加入 build_phase
            hierarchy_path = group.hierarchy_path[1,group.hierarchy_path.length]

            if filePath.to_s.end_with?(".xcassets")
              puts "設置資源資料夾: xcassets"
              fileReference = group.new_reference(filePath)
              target.resources_build_phase.add_file_reference(fileReference,true)
            #elsif filePath.to_s.include?(".xcassets")
            #  puts "包含資源資料夾: xcassets"
            else
              puts "設置資料夾: #{filePath}"
              subGroup = project.main_group.find_subpath(hierarchy_path + '/' + entry, true)
              subGroup.set_path(group.real_path + entry)
              subGroup.set_source_tree(group.source_tree)
              self.add_files_to_group(project,target,subGroup)
            end

          end
        end
      end

      def self.description
        ""
      end

      def self.available_options
        [
        ]
      end

      def self.authors
        ["https://github.com/MagicalWater/Water"]
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end
