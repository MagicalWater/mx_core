module Fastlane
  module Actions
    class GemInstallAction < Action
      def self.run(params)

        pluginName = params[:plugin_name]
        isWindows = (/cygwin|mswin|mingw|bccwin|wince|emx/ =~ RUBY_PLATFORM) != nil
        isMac = (/darwin/ =~ RUBY_PLATFORM) != nil

        isPluginInstall = false

        search_command = ""
        if isWindows
          search_command = "gem contents #{pluginName}"
        else
          search_command = "gem contents #{pluginName}"
        end

        install_command = ""
        if isWindows
          install_command = "gem install #{pluginName}"
        else
          install_command = "sudo gem install #{pluginName}"
        end

        puts "使用命令 #{search_command}"

        # 使用 Open3 呼叫 shell 的方式可以得到輸出
        Open3.popen3(search_command) do |stdin, stdout, stderr, thread|
           output = stdout.read.to_s
           match = output.scan(/#{pluginName}/)
           isPluginInstall = match.size > 1
        end

        UI.message "檢查套件是否已安裝 (#{pluginName}) - #{isPluginInstall}"

        if !isPluginInstall
          UI.message "即將安裝 #{pluginName}"
          system install_command
        end
      end

      def self.description
        "使用 gem install 安裝套件, 在安裝之前檢查是否已安裝"
      end

      def self.available_options
        # Action 需要傳入的參數, 以陣列分隔
        [
          FastlaneCore::ConfigItem.new(
            key: :plugin_name,
            description: "安裝的套件名稱",
            optional: false,
            is_string: true,
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
