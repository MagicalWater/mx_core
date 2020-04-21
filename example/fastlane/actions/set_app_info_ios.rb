module Fastlane
  module Actions
    class SetAppInfoIosAction < Action
      def self.run(params)

        appIcon = params[:ios_icon]
        iosName = params[:ios_name]
        iosBundleId = params[:ios_bundle_id]

        UpdateInfoPlistAction.run(
          xcodeproj: "ios",
          plist_path: "ios/Runner/Info.plist",
          app_identifier: iosBundleId,
          display_name: iosName
        )

        # 檢查 message extension 是否存在
        if File.exist?('ios/message/Info.plist')
          UpdateInfoPlistAction.run(
            xcodeproj: "ios",
            plist_path: "ios/message/Info.plist",
            app_identifier: "#{iosBundleId}.message",
            display_name: iosName
          )
        end

        SetInfoPlistValueAction.run(
          path: "ios/Runner/Info.plist",
          key: "UIRequiresFullScreen",
          value: true,
        )

        SetInfoPlistValueAction.run(
          path: "ios/Runner/Info.plist",
          key: "UISupportedInterfaceOrientations",
          value: ["UIInterfaceOrientationPortrait"],
        )

        SetInfoPlistValueAction.run(
          path: "ios/Runner/Info.plist",
          key: "UISupportedInterfaceOrientations~ipad",
          value: ["UIInterfaceOrientationPortrait"],
        )

        project = Xcodeproj::Project.open("./ios/Runner.xcodeproj")
        appTarget = project.targets.first
        messageTarget = project.targets.find do |target|
          target.name == "message"
        end
        appTarget.build_configuration_list.set_setting('PRODUCT_BUNDLE_IDENTIFIER', iosBundleId)

        if !messageTarget.nil?
          messageTarget.build_configuration_list.set_setting('PRODUCT_BUNDLE_IDENTIFIER', "#{iosBundleId}.message")
        end

        project.save

        # 設置 app icon
        IconGenerateAction.run(
          icon_name: appIcon,
          ios_add: true,
          android_add: false,
        )

      end

      def self.description
        "更改 ios bundle id 以及 app 名稱, 最後加入 app icon, 以及歡迎頁圖片"
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
            key: :ios_icon,
            description: "ios app icon",
            is_string: true,
            optional: true
          ),
        ]
      end

      def self.is_supported?(platform)
        platform == :ios
      end
    end
  end
end
