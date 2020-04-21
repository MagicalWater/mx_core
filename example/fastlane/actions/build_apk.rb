module Fastlane
  module Actions
    class BuildApkAction < Action

      def self.run(params)

        config = params[:env_hash]

        system "flutter clean"

        UI.message("打包渠道: #{config['android_flavor']}")

        flavors = config['android_flavor'].split(',').map { |f| f.strip }

        defaultInfo = self.parse_flavor(config['android_default'])

        isKeyFileOk = false

        UI.message "檢測 key file 有效性"

        flavors.each { |flavor|
          envFlavor = "android_#{flavor}"
          flavorInfo = self.parse_flavor(config[envFlavor])
          appKey = flavorInfo['key']
          if appKey.to_s.empty?
            puts "採用預設值 #{defaultInfo}"
            appKey = defaultInfo['key']
          end
          appKey = appKey.strip
          puts "自定 Key #{flavorInfo}"
          if !appKey.to_s.empty?
            isKeyFileOk = self.is_key_file_effective(appKey)
            if !isKeyFileOk
              UI.message "can't find key file: #{appKey}"
              break
            end
          end
        }

        if !isKeyFileOk
          UI.important "key file 異常"
          return
        else
          UI.message "key file 正常"
        end

        flavors.each { |flavor|
          envFlavor = "android_#{flavor}"
          puts "渠道字串: #{config[envFlavor]}"
          flavorInfo = self.parse_flavor(config[envFlavor])
          puts "渠道資訊: #{flavorInfo}"
          appName = flavorInfo['name']
          appId = flavorInfo['id']
          appKey = flavorInfo['key']
          if appName.to_s.empty?
            appName = defaultInfo['name']
          end
          if appId.to_s.empty?
            appId = defaultInfo['id']
          end
          if appKey.to_s.empty?
            appKey = defaultInfo['key']
          end
          UI.message("開始打包: #{flavor}, appName = #{appName}, appId = #{appId}, appKey = #{appKey}")

          SetAppInfoAndroidAction.run(android_name: appName, android_bundle_id: appId)
          if !appKey.to_s.empty?
            puts "設置 key = #{appKey}"
            SetKeyInfoAction.run(name_en: appKey, index_need: '-1')
          end

          system "flutter build apk --release --flavor #{flavor.downcase}"
        }

        outputPath = params[:outputPath]
        dist = "#{outputPath}"
        FileUtils.mkdir_p(dist)

        # build/app/outputs/apk/#{渠道名}/release/app-#{渠道名}-release.apk
        flavors.each { |flavor|
          apkPath = "./build/app/outputs/apk/#{flavor}/release/app-#{flavor}-release.apk"
          UI.message("檢測 apk generate path #{apkPath}")
          FileUtils.cp apkPath, dist
        }
        UI.message("打包 apk 完成! - 數量 #{flavors.length}: #{flavors}")
      end

      # 解析 android 渠道字串
      # 格式為 名稱, bundle_id, key 代號
      def self.parse_flavor(flavor_string)
        flavorArray = flavor_string.split(',').map { |s| s.strip }
        name = flavorArray[0]
        bundleId = flavorArray[1]
        key = flavorArray[2]
        hash = {'name' => name, 'id' => bundleId, 'key' => key}
        hash
      end

      # 檢查 key file 是否有效
      def self.is_key_file_effective(en_code)
        effective = SetKeyInfoAction.is_key_file_effective(en_code)
        puts "key 是否有效: #{effective}"
        effective
      end

      def self.description
        "輸入渠道生成相應apk"
      end

      def self.available_options
        # Action 需要傳入的參數, 以陣列分隔
        [
          FastlaneCore::ConfigItem.new(
            key: :outputPath,
            description: "輸出 apk 路徑",
            optional: false, # 是否可以省略
            is_string: true, # 是不是字串
          ),
          FastlaneCore::ConfigItem.new(
            key: :env_hash,
            description: "所有環境變數, 包含渠道",
            optional: false, # 是否可以省略
            is_string: false, # 是不是字串
          )
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
