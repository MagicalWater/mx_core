module Fastlane
  module Actions
    class FileHandleAction < Action
      # 傳入一個字串(name or path), 回傳 hash
      # {"ori": 原本名稱, "lower": 小駝峰, "upper": 大駝峰}
      def self.convert_name(name)
        # 原始名稱
        oriName = File.basename(name)

        # 將駝峰單字轉為 單字連接處 底線+小寫
        lowerLine = oriName.gsub(/(?<=[a-z])[A-Z]/) {|c|
          "_#{c.downcase}"
        }

        # 將使用 - 以及 空格的單字連接處, 也轉為 底線+小寫
        lowerLine = lowerLine.downcase.gsub(/(-[\w]| [\w])/) {|c|
          "_#{c[1].downcase}"
        }

        # 將所有空格轉為底線
        lowerLine = lowerLine.gsub(/ /) {|c|
          "_"
        }

        # puts "底線: #{lowerLine}"

        # 小駝峰
        lowerCamel = lowerLine.gsub(/_[\w]/) {|c|
          c[1].upcase
        }

        # dash 串連
        lowerDash = lowerLine.gsub(/_[\w]/) {|c|
          "-#{c[1]}"
        }

        # 空格 串連
        lowerSpace = lowerLine.gsub(/_[\w]/) {|c|
           " #{c[1]}"
        }

        # 小駝峰還需要把第1個字轉為小寫
        lowerCamel[0] = lowerCamel[0].downcase

        # 大駝峰只要把第1個字轉為大寫即可
        upperCamel = lowerCamel.dup
        upperCamel[0] = upperCamel[0].upcase

        # 將 lowerLine 轉為全小寫, 真正的底線 + 全小寫
        lowerLine = lowerLine.downcase

        hash = {
          "project" => project_name(),
          "ori" => oriName,
          "path" => name,
          "dir_path" => File.dirname(name),
          "lower_line" => lowerLine,
          "lower_camel" => lowerCamel,
          "upper_camel" => upperCamel,
          "lower_dash" => lowerDash,
          "lower_space" => lowerSpace,
          "name" => File.basename(name),
          "name_no_ex" => File.basename(name, File.extname(name)),
          "name_lower_dash_no_ex" => File.basename(lowerDash, File.extname(lowerDash)),
          "name_lower_line_no_ex" => File.basename(lowerLine, File.extname(lowerLine)),
          "name_lower_no_ex" => File.basename(lowerCamel, File.extname(lowerCamel)),
          "name_upper_no_ex" => File.basename(upperCamel, File.extname(upperCamel)),
          "ex" => File.extname(name),
        }

        hash
      end

      # 專案名稱
      def self.project_name()
        # 藉由 yaml_parse 取得 yaml
        # 其中的 name 屬性就是專案名稱
        yamlHash = YamlParseAction.load()

        projectName = ''

        # 如果 yamlHash 裡面沒有定義 name, 就直接從當目錄獲取
        if (yamlHash.include?("name"))
          projectName = yamlHash["name"]
        else
          projectName = File.basename(Dir.getwd)
        end

        projectName
      end

      # 取得某個路徑底下的所有檔案
      # 在且將取到的檔案做 convert
      # depth 代表繼續往下檢測幾層資料夾
      def self.get_all_files(target_path, depth = nil)
        # files = Dir.glob("#{path}/.*")
        files = []
        Find.find(target_path) do |path|
          files << path
        end

        # 刪除第一個
        files.shift

        # 刪除 .DS_Store
        files = files.select { |f|
           File.basename(f) != '.DS_Store'
        }

        findFiles = []

        targetPathDepth = target_path.split('/').size

        files.each { |file|
          # puts "確認檔案: #{file}"
          name = File.basename(file)
          path = File.dirname(file)

          isDepthOk = true
          if depth != nil
            pathDepth = path.split('/').size
            isDepthOk = (pathDepth - targetPathDepth) <= depth
          end

          # 檢查資料夾深度, 以及是否為檔案
          if (File.file?(file) && isDepthOk)
            # 是檔案
            hash = self.convert_name(file)
            findFiles << hash
          end
        }
        findFiles
      end

      # 取得某個路徑下的所有資料夾
      def self.get_all_dirs(target_path)
        files = []
        Find.find(target_path) do |path|
          files << path
        end

        # 刪除第一個
        files.shift

        # 刪除 .DS_Store
        files = files.select { |f|
           File.basename(f) != '.DS_Store'
        }

        findDirs = []

        files.each { |file|
          if File.directory? file
            # 是資料夾
            findDirs << file
          end
        }
        findDirs
      end

      # 讀取檔案後, 並且依照 hash args 替換裡面的字串
      def self.get_template(temp_path, args)
        fileS = File.read(temp_path, :encoding => 'UTF-8')
        # puts "打印出 args: #{args}, #{temp_path}"
        # puts "替換前: #{fileS}"
        args.each { |k, v|
          fileS = fileS.gsub(/\$\{#{k}\}/) { |c| v }
        }
        #puts "替換後: #{fileS}"
        fileS
      end

      def self.description
        "處理檔案"
      end

      def self.available_options
        # Action 需要傳入的參數, 以陣列分隔
        [
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
