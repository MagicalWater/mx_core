module Fastlane
  module Actions
    class IconGenerateAction < Action
      def self.run(params)

        addIos = params[:ios_add]
        addAndroid = params[:android_add]
        iconName = params[:icon_name]
        jarPath = "fastlane/jars/icon-generator.jar"
        projectPath = Dir.pwd

        if iconName != nil
          # ios app icon 不可有透明背景, 設置為白色
          iosOpacityRender = "#ffffff"
          androidSupportCommend = ""
          iosSupportCommend = ""
          if addAndroid
            androidSupportCommend = "--android"
          end
          if addIos
            iosSupportCommend = "--ios"
          end

          command = "java -jar #{jarPath} -p #{projectPath} -i #{iconName} #{androidSupportCommend} #{iosSupportCommend} --render #{iosOpacityRender}"

          UI.message "執行參數: project: #{projectPath}"
          UI.message "android: #{addAndroid}, ios: #{addIos}, image: #{iconName}, render: #{iosOpacityRender}"
          UI.message "androidSupport: #{androidSupportCommend}, iosSupport: #{iosSupportCommend}"
          UI.message "command: #{command}"

          Open3.popen3(command) do |stdin, stdout, stderr, thread|
             # UI.message "打印過程: #{stdout.read.to_s}"
          end
        end

      end

      def self.description
        "自動產生 app icon"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(
            key: :icon_name,
            description: "icon名稱",
            optional: false,
            is_string: true,
          ),
          FastlaneCore::ConfigItem.new(
            key: :ios_add,
            description: "icon是否添加到 ios",
            optional: false,
            is_string: false,
          ),
          FastlaneCore::ConfigItem.new(
            key: :android_add,
            description: "icon是否添加到 android",
            optional: false,
            is_string: false,
          ),
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
