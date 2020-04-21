module Fastlane
  module Actions
    class SetKeyInfoAction < Action
      def self.run(params)

        resourceRepPath = ENV['APP_RESOURCES']
        nameCN = params[:name_cn]
        nameEN = params[:name_en]
        index = params[:index]
        indexNeed = params[:index_need]
        if indexNeed != "-1"
          index = indexNeed
        end

        UI.important "Check Path #{resourceRepPath}"
        UI.important "Check Param index = #{index}, cn = #{nameCN}, en = #{nameEN}"

        keyText = File.read("#{resourceRepPath}/android/android_key.txt", :encoding => 'UTF-8')
        keyJson = JSON.parse(keyText)

        if !(index.nil?) or !(nameEN.nil?) or !(nameCN.nil?)
          keyJson['keys'].each_with_index { |keyObj, i|
            if i.to_s == index.to_s or keyObj['tag_cn'] == nameCN or keyObj['tag_en'] == nameEN
              if keyObj['tag_en'] == ""
                name = keyObj['tag_cn']
                UI.important "#{i} - #{keyObj['tag_cn']}"
              else
                name = keyObj['tag_en']
                UI.important "#{i} - #{keyObj['tag_en']}. #{keyObj['tag_cn']}"
              end
              keyAlias = keyObj['alias']
              password = keyJson['password']
              write_key_info(name, keyAlias, password)
            end
          }
        else
          # 參數皆為 nil
          # 打印出可選擇的選項
          UI.important "需要參數: index(基數) 或 name_cn(簡中名) 或 name_en(代號), 請輸入選擇的 key index/name"
          keyJson['keys'].each_with_index { |keyObj, i|
            if keyObj['tag_en'] == ""
              UI.important "#{i} - #{keyObj['tag_cn']}"
            else
              UI.important "#{i} - #{keyObj['tag_en']}. #{keyObj['tag_cn']}"
            end

          }
        end

      end

      # 檢查 en_code 是否有對應到 key file
      def self.is_key_file_effective(en_code)
        effective = false
        resourceRepPath = ENV['APP_RESOURCES']
        keyText = File.read("#{resourceRepPath}/android/android_key.txt", :encoding => 'UTF-8')
        keyJson = JSON.parse(keyText)
        keyJson['keys'].each_with_index { |keyObj, i|
          if keyObj['tag_en'] == en_code
            if keyObj['tag_en'] == ""
              name = keyObj['tag_cn']
              UI.important "key exist - #{i} - #{keyObj['tag_cn']}"
            else
              name = keyObj['tag_en']
              UI.important "key exist - #{i} - #{keyObj['tag_en']}. #{keyObj['tag_cn']}"
            end
            effective = true
          end
        }
        effective
      end

      # name -> 專案代碼名稱
      # alias -> 別名
      # password -> 密碼
      def self.write_key_info(name_code, key_alias, key_password)

        content =
        %(storeFile=/android/#{name_code}/key.jks
storePassword=#{key_password}
keyAlias=#{key_alias}
keyPassword=#{key_password})

        FileUtils.touch('./android/key.properties')
        File.write('./android/key.properties', content)
      end

      def self.description
        "快速設置 key file 資訊"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(
            key: :index_need,
            description: "選擇的 key index",
            is_string: true,
            optional: false
          ),
          FastlaneCore::ConfigItem.new(
            key: :name_cn,
            description: "選擇的 key 名稱(可選)",
            is_string: true,
            optional: true
          ),
          FastlaneCore::ConfigItem.new(
            key: :name_en,
            description: "選擇的 key 名稱(可選)",
            is_string: true,
            optional: true
          ),
          FastlaneCore::ConfigItem.new(
            key: :index,
            description: "選擇的 key index(可選, 與 select_name 擇一)",
            is_string: true,
            optional: true
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
