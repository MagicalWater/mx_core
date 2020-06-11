module Fastlane
  module Actions
    class MergeEnvAction < Action
      def self.run(params)
        androidEnv = load_env('fastlane/.android.env', 'android_')
        iosEnv = load_env('fastlane/.ios.env', 'ios_')
        specialEnv = {}

        mergeEnv = androidEnv

        # ios 有四個 key 需要特殊處理
        iosEnv.each { |k,v|
          if k.include? "account_specific_password"
            mergeEnv['FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD'] = v
            specialEnv['FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD'] = v
          elsif k.include? "account_name"
            mergeEnv['CERT_USERNAME'] = v
            mergeEnv[k] = v
            specialEnv['CERT_USERNAME'] = v
          elsif k.include? "account_password"
            mergeEnv['FASTLANE_PASSWORD'] = v
            mergeEnv[k] = v
            specialEnv['FASTLANE_PASSWORD'] = v
          elsif k.include? 'phone_number'
            mergeEnv['SPACESHIP_2FA_SMS_DEFAULT_PHONE_NUMBER'] = v
            specialEnv['SPACESHIP_2FA_SMS_DEFAULT_PHONE_NUMBER'] = v
          elsif k.include? "auto_cert_password"
            mergeEnv[k] = v
            specialEnv['MATCH_PASSWORD'] = v
          elsif
            mergeEnv[k] = v
          end
        }

        mergeText = ''
        specialText = %{
# 注意事項
# 將 App-Resources 倉庫 clone 回來
# https://github.com/8ucx/Base-APP-Resource
# git@github.com:8ucx/Base-APP-Resource.git
# 在環境變數加入
# key = APP_RESOURCES
# value = 路徑
# 例如:
# export APP_RESOURCES=/Users/magicalwater/FlutterProjects/App-Resources

# === 以下自動產生, 請勿修改 ===

}

        mergeEnv.each { |k,v|
          mergeText = mergeText + "\n#{k} = #{v}"
        }

        specialEnv.each { |k, v|
          specialText = specialText + "\n#{k} = #{v}"
        }

       File.write('fastlane/.merge.env', mergeText)
       File.write('fastlane/.env', specialText)

       mergeEnv
      end

      def self.load_env(env_path, prefix_key)
        env = {}
        File.readlines(env_path, :encoding => 'UTF-8').each do |line|
          nonSpace = line.strip
          if nonSpace.length > 0 && nonSpace[0] != '#'
            nonSpace.gsub(/[\w]+ *=.*/) { |c|
              split = c.split('=')
              key = split.slice!(0).strip
              value = split.join('=').strip

              if !(value.empty?) && ((value[0] == '"' && value[-1] == '"') || (value[0] == "'" && value[-1] == "'"))
                #puts "value = #{value}, 切換 #{value[1..-2]}"
                value = value[1..-2]
              end

              env["#{prefix_key}#{key}"] = value
            }
          end
        end
        env
      end

      def self.description
        "合併 env"
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
