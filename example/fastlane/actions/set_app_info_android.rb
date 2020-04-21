module Fastlane
  module Actions
    class SetAppInfoAndroidAction < Action
      def self.run(params)
        require 'nokogiri'

        puts "Actions path: #{Dir.pwd}"

        bundleId = params[:android_bundle_id]
        androidName = params[:android_name]
        appIcon = params[:android_icon]
        manifestFilePath = "android/app/src/main/AndroidManifest.xml"
        label = "android:label"
        node = "application"

        ParseXmlAction.write(
          xml_path: manifestFilePath,
          node_array: ["application"],
          label: label,
          value: androidName,
        )

        if !bundleId.to_s.empty?
          # 更新 bundle id
          # 讀取 build.gradle
          gradleFilePath = "android/app/build.gradle"
          gradleString = File.read(gradleFilePath, :encoding => 'UTF-8')

          # 找到 application 並且替代
          replaceString = gradleString.gsub(/(?<=all { flavor ->\n)(.|\s)+?(?=})/) {|flavorAll|
            flavorAll.gsub(/(?<=applicationId \")(\w|\.)+/) { |link|
              bundleId
            }
          }

          # 將替代後的字串寫回去
          File.write(gradleFilePath, replaceString)
        end

        # 設置 app icon
        if !appIcon.to_s.empty?
          IconGenerateAction.run(icon_name: appIcon, ios_add: false, android_add: true)
        end

      end

      def self.description
        "更改 Mainfest 中 application 的 app名稱, 以及 gradle 下 applicationId, 最後複製加入 app icon"
      end

      def self.authors
        ["https://github.com/MagicalWater/Water"]
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(
            key: :android_name,
            description: "Android App 名",
            is_string: true,
            optional: true
          ),
          FastlaneCore::ConfigItem.new(
            key: :android_bundle_id,
            description: "Android App 包名",
            is_string: true,
            optional: true
          ),
          FastlaneCore::ConfigItem.new(
            key: :android_icon,
            description: "android app icon",
            is_string: true,
            optional: true
          ),
        ]
      end

      def self.is_supported?(platform)
        platform == :android
      end
    end
  end
end
