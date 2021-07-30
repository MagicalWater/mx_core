module Fastlane
  module Actions
    class JsonBeanConvertGenerateAction < Action
      def self.run(params)

        beanFiles = self.get_all_bean

        # 檢測需要生成 model 的資料夾
        self.json_files(beanFiles)

        beanFiles = self.get_all_bean

        beanFiles.each { |f|
          puts "找到 json file = #{f['path']}"
        }

        # UI.message "找到 json 檔案: #{beanFiles}"
        self.generate_bean_convert(beanFiles)

      end

      # 檢測 res 底下含有的 json 文本
      def self.json_files(beanFiles)
        FileUtils.mkdir_p('assets/jsons')

        # puts "打印: #{beanFiles}"

        FileHandleAction.get_all_files('assets/jsons').each { |file|

          # UI.important "檔案屬性"
          # UI.message "file = #{file}"
          # 取得在 assets/jsons/ 底下的相對路徑

          # 檔案相對路徑
          len = 'assets/jsons/'.size
          # UI.message "file相對路徑 = #{fileRelPath}"

          detectDir = ""

          if (file['dir_path'][len..-1].to_s.empty?)
            detectDir = "#{file['name_no_ex']}"
          else
            detectDir = "#{file['dir_path'][len..-1]}/#{file['name_no_ex']}"
          end

          detectName = file['name_no_ex'] + ".dart"
          targetClassName = file['name_upper_no_ex']
          targetFileName = file['name_lower_line_no_ex'] + ".dart"
          # puts "檔案名稱命名為: #{file}"
          # 排除 已經存在於 bean 的檔案
          isExclude = beanFiles.any? { |bean|

            beanLen = 'lib/bean/'.size
            beanRelPath = bean['dir_path'][beanLen..-1]

            name = bean['name']

            isSame = (name == detectName) && (beanRelPath == detectDir)
            # puts "檢測: #{name} - #{detectName}, #{beanRelPath} - #{detectDir}"
            isSame
          }

          # puts "確認檔案: #{file['path']}, 需要排除嗎: #{isExclude}"

          if !isExclude
            # 代表檔案需要加入
            FileUtils.mkdir_p("lib/bean/#{detectDir}")
            command = "json_dart_generator -f #{file['path']} -o lib/bean/#{detectDir}/#{targetFileName} -s Bean -n #{targetClassName}"
            puts "生成 bean 命令: #{command}"
            system command
          end
        }
      end

      # 產生 bean 對應的 code
      def self.generate_bean_convert(beanFiles)
        FileUtils.mkdir_p("lib/bean")
        if !(File.exist? "lib/bean/bean_converter.dart")
          FileUtils.cp "fastlane/files/template/template_bean_converter_dart", "lib/bean/bean_converter.dart"
        end

        codeString = File.read("lib/bean/bean_converter.dart", :encoding => 'UTF-8')

        # 搜索 import 區域, 並插入缺少 import 的 bean
        codeString = codeString.gsub(/(import .+;(\s)+)+/) { |c|
          puts "尋找 import "
          addText = ""
          beanFiles.each { |beanFile|
            # 路徑為 lib/bean/...
            # import 不需要 lib
            path = beanFile['path'].split('/')[1..-1].join('/')
            if c.include? path
              puts "包含 import: #{path}"
            else
              puts "不包含 import: #{path}"
              addText = "import 'package:#{FileHandleAction.project_name()}/#{path}';\n#{addText}"
            end
          }
          c = c + addText
          c
        }

        # 搜索 export 區域, 並插入缺少 export 的 bean
        isExportFind = false
        codeString = codeString.gsub(/(export .+;(\s)+)+/) { |c|
          isExportFind = true
          puts "尋找 export "
          addText = ""
          beanFiles.each { |beanFile|
            # 路徑為 lib/bean/...
            # import 不需要 lib
            path = beanFile['path'].split('/')[1..-1].join('/')
            if c.include? path
              puts "包含 export: #{path}"
            else
              puts "不包含 export: #{path}"
              addText = "export 'package:#{FileHandleAction.project_name()}/#{path}';\n#{addText}"
            end
          }

          c = c + addText
          c
        }

        # 如果搜不到 export 區域, 代表還沒有, 那就搜索 import 加在後面
        if !isExportFind
          codeString = codeString.gsub(/(import .+;(\s)+)+/) { |c|
            puts "尋找 import, 預備在import後面插入 export"
            addText = ""
            beanFiles.each { |beanFile|
              # 路徑為 lib/bean/...
              # import 不需要 lib
              path = beanFile['path'].split('/')[1..-1].join('/')
              addText = "export 'package:#{FileHandleAction.project_name()}/#{path}';\n#{addText}"
            }
            c = c + "\n" + addText
            c
          }
        end

        # 取得定義 _factories 變數的實體
        codeString = codeString.gsub(/final _factories = <Type, Function>{(\s|.)+?}/) { |c|
          puts "進行 _factories 添加"
          beanFiles.each { |fileHash|
            # puts "尋找: #{fileHash}"
            className = File.basename("#{fileHash['upper_camel']}", File.extname(fileHash['upper_camel']))

            if className != "ResponseBeanBase"
              className += "Bean"
            end

            # 檢查 className 是否已經宣告
            needAdd = false

            if /(\s)#{className}:/.match?(c) then
              puts "已經宣告了: #{className}"
            else
              needAdd = true
            end

            if needAdd then
              # 添加到錨點
              # 需要添加 到 } 上方
              c = c.gsub(/\n\s*}/) { |anchor|
                anchor = %{
    #{className}: (jsonData) => #{className}.fromJson(jsonData),} + anchor
                anchor
              }
            end
          }
          c
        }


        File.write("lib/bean/bean_converter.dart", codeString)

      end

      # 取得所有的 bean
      def self.get_all_bean()
        FileUtils.mkdir_p('lib/bean')
        beanFiles = []
        FileHandleAction.get_all_files('lib/bean').each { |file|
          # 排除 lib/bean/general 路徑的檔案
          # puts "確認檔案: #{file['path']}"
          if (file['path'].end_with?(".g.dart")) || (file['path'].end_with?(".reflectable.dart")) || (file['path'].include? "bean_converter.dart") || (file['path'].include? "response_code_map.dart")
            #puts "檔案存在於 general, 或者 結尾是 .g.dart, 排除"
          elsif (file['path'].include? ".dart")
            #puts "檔案確認為 bean file"
            beanFiles << file
          end
        }
        beanFiles
      end

      def self.get_template(temp_path, args)
        fileS = File.read(temp_path, :encoding => 'UTF-8')
        #puts "打印出 args: #{args}"
        #puts "替換前: #{fileS}"
        args.each { |k, v|
          fileS = fileS.gsub(/\$\{#{k}\}/) { |c| v }
        }
        #puts "替換後: #{fileS}"
        fileS
      end

      def self.description
        "根據 lib/bean 自動生成對應的 beanConverter 類"
      end

      def self.available_options
        [
        ]
      end

      def self.authors
        ["Your GitHub/Twitter Name"]
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end
