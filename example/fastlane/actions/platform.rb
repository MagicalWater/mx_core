module Fastlane
  module Actions
    class PlatformAction < Action
      def self.is_windows()
        (/cygwin|mswin|mingw|bccwin|wince|emx/ =~ RUBY_PLATFORM) != nil
      end

      def self.is_mac()
        (/darwin/ =~ RUBY_PLATFORM) != nil
      end

      def self.description
        "初始化構建專案"
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
