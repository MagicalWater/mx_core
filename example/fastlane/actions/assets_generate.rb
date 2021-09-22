module Fastlane
  module Actions
    class AssetsGenerateAction < Action
      def self.run(params)
        self.images_rename()
        self.yaml_dir_generate()
        self.images_generate()
      end

      # 將檢測到的檔案全都改名為底線+小寫
      def self.images_rename()
        imageFiles = self.images_detect
        imageFiles.each { |hash|
          segments = []
          Pathname.new(hash['path']).each_filename { |s|
            segments << s
          }
          segments[-1] = hash['lower_line']
          moveFileTo = segments.join('/')
          File.rename(hash['path'], moveFileTo)
        }
      end

      # 在 yaml 生成 assets 對應的資料夾
      def self.yaml_dir_generate()
        dirs = self.assets_dir_detect
        assetsDir = []
        dirs.each { |dir|
          segments = []
          Pathname.new(dir).each_filename { |s|
            segments << s
          }
          dirPath = "#{segments.join('/')}/"
          puts "添加: #{segments}"
          assetsDir << dirPath
        }
        puts "添加資料夾: #{assetsDir}"
        yamlHash = YamlParseAction.load()
        if assetsDir.any?
          yamlHash['flutter']['assets'] = assetsDir
        else
          yamlHash.delete('assets')
        end

        YamlParseAction.write(yamlHash)
      end

      def self.images_generate()
        # 先取得要生成 images 的檔案列表
        imageFiles = self.images_detect
        puts "需要生成的: #{imageFiles.map {|item| item['lower_camel']}}"

        projectName = FileHandleAction.convert_name(FileHandleAction.project_name())

        fileString = FileHandleAction.get_template(
          "fastlane/files/template/template_images_dart",
          {'project' => projectName['upper_camel'] }
        )

        fileString = fileString.gsub(/\n  Images\._internal/) { |c|
          addText = ""
          allVar = []
          imageFiles.each { |fileHash|
            segments = []
            Pathname.new(fileHash['path']).each_filename { |s|
              segments << s
            }

            filePrefix = ''
            if segments.size > 3
              filePrefix = FileHandleAction.convert_name(segments[-2])['lower_camel']
            end

            varNameNoExtension = ''
            if filePrefix.empty?
              varNameNoExtension = fileHash['name_lower_no_ex']
            else
              varNameNoExtension = "#{filePrefix}#{fileHash['name_upper_no_ex']}"
            end

            # 如果檔案名稱有非法符號, 則去除
            varNameNoExtension = varNameNoExtension.gsub(/(\(|\))/) {|c|
              "_"
            }

            allVar.append(varNameNoExtension)

            addText = addText + %{
  static const #{varNameNoExtension} = "#{fileHash['path']}";}

          }

          allText = "\n  static const all = ["
          allVar.each { |e|
            allText = allText + %{
    #{e},}
          }

          if allVar.length > 0
            allText = allText + "\n  ];"
          else
            allText = allText + "];"
          end

          c = addText + allText + c
          c
        }

        fileString = fileString.gsub(/\n  (\w)+Images\._internal/) { |c|
          addText = ""
          allVar = []
          imageFiles.each { |fileHash|
            segments = []
            Pathname.new(fileHash['path']).each_filename { |s|
              segments << s
            }

            filePrefix = ''
            if segments.size > 3
              filePrefix = FileHandleAction.convert_name(segments[-2])['lower_camel']
            end

            varNameNoExtension = ''
            if filePrefix.empty?
              varNameNoExtension = fileHash['name_lower_no_ex']
            else
              varNameNoExtension = "#{filePrefix}#{fileHash['name_upper_no_ex']}"
            end

            varNameNoExtension = varNameNoExtension.gsub(/(\(|\))/) {|c|
              "_"
            }

            allVar.append(varNameNoExtension)

            addText = addText + %{
  static const #{varNameNoExtension} = "packages/#{projectName['ori']}/#{fileHash['path']}";}

          }

          allText = "\n  static const all = ["
          allVar.each { |e|
            allText = allText + %{
    #{e},}
          }

          if allVar.length > 0
            allText = allText + "\n  ];"
          else
            allText = allText + "];"
          end

          c = addText + allText + c
          c
        }
        FileUtils.mkdir_p("lib/res")

        File.write("lib/res/images.dart", fileString)
      end

      # 檢測 assets/images 底下有哪些檔案
      def self.images_detect()
        FileUtils.mkdir_p("assets/images")
        files = []
        FileHandleAction.get_all_files('assets/images').each { |file|
          if !(file['name'].include?('DS_Store'))
            files << file
          end
        }
        files
      end

      # 檢測 assets 底下有哪些資料夾
      def self.assets_dir_detect()
        FileUtils.mkdir_p("assets")
        dirs = []
        FileHandleAction.get_all_dirs('assets').each { |file|

          # 空資料夾不加入
          fileCount = Dir[File.join(file, '**', '*')].count { |file| File.file?(file) }
          if fileCount > 0
            dirs << file
          end
        }
        dirs
      end

      def self.description
        "根據 assets 底下的資源自動生成對應的 code"
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
