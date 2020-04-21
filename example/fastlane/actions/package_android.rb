module Fastlane
  module Actions
    class PackageAndroidAction < Action

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
          UI.important "Android 打包模式: product, 為求安全性, 暫時不開放 product"
          $isProduct = true
        elsif packageType == "2"
          UI.important "Android 打包模式: release"
          $isRelease = true
        else
          UI.important "Android 打包模式: debug"
          $isDebug = true
        end

        if !(version.empty?)
          modify_version(version)
        end

        # 輸出目的
        dest = "#{config['android_output']}"
        FileUtils.mkdir_p(dest)

        # 編譯源碼, 回傳 apk path
        build_source(dest, needClean)
      end

      # 修改 yaml 的版本
      def self.modify_version(version)

        versionName = version.match(/.+(?=\+)/)[0]
        versionCode = version.match(/(?<=\+).+/)[0]

        if versionName.empty? || versionCode.empty?
          # 版本解析錯誤
          UI.user_error!("版本解析錯誤: #{version}")
        end

        yamlHash = YamlParseAction.load()
        yamlHash["version"] = version

        UI.important "設置版本號 - #{version}"
        YamlParseAction.write(yamlHash)
      end

      # 執行編譯
      def self.build_source(output_path, need_clean)
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
          command = "flutter build apk --debug --flavor=tonone -t lib/main_debug.dart"
        elsif $isRelease
          command = "flutter build apk --release --flavor=tonone -t lib/main_release.dart"
        elsif $isProduct
          command = "flutter build apk --release --flavor=tonone -t lib/main_product.dart"
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
            UI.error "編譯有錯誤或警告"
            errorSplit = err.split("\n")
            ignoreWarning = true
            errDetect = ""
            errorSplit.each { |errorInfo|
              errorInfo = errorInfo.downcase.strip
              if (errorInfo.start_with?("note:")) || (errorInfo.start_with?("warning:")) || (errorInfo.start_with?("! ")) || (errorInfo.start_with?("see "))
                # 忽略 Note 以及警告
              else
                ignoreWarning = false
                errDetect = errorInfo
              end
            }

            if ignoreWarning
              UI.important "檢測為 Note 或 Warning 的錯誤, 進行忽略: \n#{err}"
            else
              # 錯誤不可忽略
              UI.user_error!("編譯訊息:\n#{out}\無法忽略的錯誤: #{errDetect} \n#{err}")
            end
          end
        end

        sourcePath = ""
        destPath = ""

        # 將 apk 移至export
        if $isDebug
          sourcePath = "./build/app/outputs/apk/toNone/debug/app-toNone-debug.apk"
          destPath = "#{output_path}/debug.apk"
        elsif $isRelease
          sourcePath = "./build/app/outputs/apk/toNone/release/app-toNone-release.apk"
          destPath = "#{output_path}/release.apk"
        elsif $isRelease
          sourcePath = "./build/app/outputs/apk/toNone/release/app-toNone-product.apk"
          destPath = "#{output_path}/product.apk"
        end

        FileUtils.cp(sourcePath, destPath)

        destPath
      end

      def self.description
        "Android 打包 e7 app"
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
        platform == :android
      end
    end
  end

end
