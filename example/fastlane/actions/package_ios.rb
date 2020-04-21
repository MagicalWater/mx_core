module Fastlane
  module Actions
    class PackageIosAction < Action

      $isDebug = false
      $isRelease = false
      $isProduct = false

      def self.run(params)
        config = params[:env_hash]
        needClean = params[:need_clean]
        packageType = params[:type]
        version = params[:version]
        version = version.to_s.strip

        if packageType == "3"
          UI.important "IOS 打包模式: product, 為求安全性, 暫時不開放 product"
          $isProduct = true
        elsif packageType == "2"
          UI.important "IOS 打包模式: release"
          $isRelease = true
        else
          UI.important "IOS 打包模式: debug"
          $isDebug = true
        end

        if !(version.empty?)
          PackageAndroidAction.modify_version(version)
        end

        # 輸出目的
        dest = "#{config['ios_output']}"
        FileUtils.mkdir_p(dest)

        # app icon 名稱
        appIcon = "./assets/images/#{config['ios_app_icon']}"

        # 檢查圖片是否存在
        if !(File.exist?(appIcon))
          UI.user_error!("圖片: #{appIcon} 不存在, 請檢查錯誤")
        end

        # 編譯源碼
        build_source(needClean)

        # 打包空包, 回傳路徑
        package_empty(dest, appIcon)

      end

      # 執行編譯
      def self.build_source(need_clean)
        if need_clean == false
          system "flutter pub get"
        elsif !($isDebug)
          system "flutter clean"
          system "flutter pub get"
          system "flutter pub upgrade"
        else
          system "flutter pub get"
        end

        command = ""

        if $isDebug
          command = "flutter build ios --debug -t lib/main_debug.dart"
        elsif $isRelease
          command = "flutter build ios --release -t lib/main_release.dart"
        elsif $isProduct
          command = "flutter build ios --release -t lib/main_product.dart"
        end

        UI.message "執行編譯指令: #{command}"
        UI.message "編譯中..."

        # 執行 clean 以及 build
        Open3.popen3(command) do |stdin, stdout, stderr, thread|
          err = stderr.read.to_s
          out = stdout.read.to_s
          isSuccess = err.empty?
          if isSuccess
            UI.message "編譯完畢, 開始打包"
          else
            UI.user_error!("編譯訊息:\n#{out}\n錯誤訊息:\n #{err}")
          end
        end

      end

      # 打包成空包
      def self.package_empty(dest, app_icon_path)
        # 創建一個 temp 資料夾
        tempPath = "#{dest}/temp"
        tempPayloadPath = "#{tempPath}/Payload"

        FileUtils.mkdir_p(tempPayloadPath)

        # 放置 app_icon
        # app icon 目標位置
        iconDestPath = "#{tempPath}/iTunesArtwork"

        place_app_icon(app_icon_path, iconDestPath, 1024, 1024)

        ipaPath = "./build/ios/iphoneos"
        FileUtils.copy_entry ipaPath, tempPayloadPath

        # 將 資料夾跟圖片放去 zip
        isWindows = PlatformAction.is_windows
        if isWindows
          system "cd #{tempPath} & zip Payload.zip iTunesArtwork -r Payload"
        else
          system "cd #{tempPath}; zip Payload.zip iTunesArtwork -r Payload"
        end

        destPath = ""

        if $isDebug
          destPath = "#{dest}/debug.ipa"
        elsif $isRelease
          destPath = "#{dest}/release.ipa"
        elsif $isProduct
          destPath = "#{dest}/product.ipa"
        end

        FileUtils.mv("#{tempPath}/Payload.zip", destPath)

        FileUtils.rm_rf(tempPath)

        destPath
      end

      # 變更圖片大小, 並放置到指定位置
      def self.place_app_icon(source, dest, width, height)
        require 'rmagick'
        image = Magick::Image.read(source).first

        image.change_geometry!("#{width}x#{height}") { |cols, rows, img|
            newimg = img.resize(width, height)
            newimg.write(dest)

            img = Magick::ImageList.new(dest)
            img.background_color = "white"
            img.flatten_images.write(dest)
        }
      end

      def self.description
        "Ios 打包 e7 app"
      end

      def self.available_options
        # Action 需要傳入的參數, 以陣列分隔
        [
          FastlaneCore::ConfigItem.new(
            key: :env_hash,
            description: "所有環境變數, 包含渠道",
            optional: false, # 是否可以省略
            is_string: false, # 是不是字串
          ),
          FastlaneCore::ConfigItem.new(
            key: :type,
            description: "打包模式(輸入index)\n1. debug (默認)\n2. release\n3. product",
            optional: false,
            is_string: true,
          ),
          FastlaneCore::ConfigItem.new(
            key: :version,
            description: "指定版本 ",
            optional: true,
            is_string: true,
          ),
          FastlaneCore::ConfigItem.new(
            key: :need_clean,
            description: "打包前是否執行 clean",
            optional: true,
            is_string: false,
          ),
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
