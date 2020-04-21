module Fastlane
  module Actions

    class PullScriptAction < Action
      def self.run(params)
        method = params[:method].to_s

        if method.empty?
          method = '1'
        end

        system "svn info https://github.com/i2xc/Base-APP-Automated"

        specifiedVersion = params[:version]
        isClear = params[:clear]
        if isClear == nil
          isClear = false
        end

        if method == '3'
          pull(specifiedVersion, isClear)
        elsif method == '2'
          if check_version()
            pull(nil, isClear)
          end
        else
          self.list_all_versions()
        end
      end

      # 列出現在共有哪些版本
      def self.list_all_versions()
        command = 'svn list https://github.com/i2xc/Base-APP-Automated/tags'

        nowVersion = ''
        if File.exist?("fastlane/version")
          nowVersion = File.read("fastlane/version", :encoding => 'UTF-8')
        end

        Open3.popen3(command) do |stdin, stdout, stderr, thread|
          output = stdout.read.to_s
          err = stderr.read.to_s
          if err.empty?
            UI.message "自動化腳本版本列表"
            output.each_line do |line|
              # 最尾端是 / 符號, 需要刪除
              version = line.strip
              if version[-1] == '/'
                version = version[0..-2]
              end

              if version == nowVersion
                UI.important "* #{version}"
              else
                UI.message "  #{version}"
              end

            end

          else
            UI.message "發生錯誤: #{err}"
          end
        end
      end

      # 檢查版本號
      def self.check_version()
        tempDir = "fastlane_temp"
        FileUtils.mkdir_p(tempDir)
        command = "svn export https://github.com/i2xc/Base-APP-Automated/trunk/automated_script/fastlane/version #{tempDir} --force"
        Open3.popen3(command) do |stdin, stdout, stderr, thread|
        end
        newVersion = File.read("#{tempDir}/version", :encoding => 'UTF-8')

        nowVersion = ""

        if File.exist?("fastlane/version")
          nowVersion = File.read("fastlane/version", :encoding => 'UTF-8')
        end

        userInput = 'n'

        puts "最新版本 - #{newVersion}, 當前版本 - #{nowVersion}, 是否有新版本: #{compare_version(newVersion, nowVersion)}"

        if compare_version(newVersion, nowVersion)
          print "有新版本[#{newVersion}] - 是否進行更新(y/n): "
          userInput = gets.chomp
        end

        # FileUtils.rm_rf(tempDir)

        userInput == 'y'
      end

      # 比較版本號
      def self.compare_version(new, old)
        haveNew = false
        if old.to_s.empty?
          haveNew = true
        else
          newSplit = new.split('.')
          oldSplit = old.split('.')
          newSplit.each_with_index { |newNum, i|
            if !haveNew
              if old.length <= i
                haveNew = true
              else
                oldNum = oldSplit[i]
                haveNew = newNum.to_i > oldNum.to_i
              end
            end
          }
        end
        haveNew
      end

      def self.pull(version, is_clear)
        tempDir = "fastlane_temp"

        FileUtils.mkdir_p(tempDir)

        # svn export 命令相關
        # 基礎 url    - https://github.com/3rdpay/AppAutomatedScript-Flutter
        # Path Start
        #   * 使用主支(master) - /trunk
        #   * 指定 branch     - /branchs/#{branchName}
        #   * 指定 tag        - /tags/#{tagName}
        # Path - /automated_script/fastlane

        command = ''
        command2 = ''
        command3 = ''
        if version.to_s.empty?
          UI.message "開始下載腳本 - master"
          command = "svn export https://github.com/i2xc/Base-APP-Automated/trunk/automated_script/fastlane #{tempDir} --force"
          command2 = "svn export https://github.com/i2xc/Base-APP-Automated/trunk/automated_script/Gemfile #{tempDir} --force"
          command3 = "svn export https://github.com/i2xc/Base-APP-Automated/trunk/automated_script/Gemfile.lock #{tempDir} --force"
        else
          UI.message "開始下載腳本 - 指定版本: #{version}"
          command = "svn export https://github.com/i2xc/Base-APP-Automated/tags/#{version}/automated_script/fastlane #{tempDir} --force"
          command2 = "svn export https://github.com/i2xc/Base-APP-Automated/tags/#{version}/automated_script/Gemfile #{tempDir} --force"
          command3 = "svn export https://github.com/i2xc/Base-APP-Automated/tags/#{version}/automated_script/Gemfile.lock #{tempDir} --force"
        end

        isSuccess = false

        Open3.popen3(command2) do |stdin, stdout, stderr, thread|
          output = stdout.read.to_s
          err = stderr.read.to_s
          isSuccess = err.empty?
          if isSuccess
          else
            UI.user_error!("下載腳本發生錯誤 - #{err}")
          end
        end

        Open3.popen3(command3) do |stdin, stdout, stderr, thread|
          output = stdout.read.to_s
          err = stderr.read.to_s
          isSuccess = err.empty?
          if isSuccess
          else
            UI.user_error!("下載腳本發生錯誤 - #{err}")
          end
        end

        Open3.popen3(command) do |stdin, stdout, stderr, thread|
          output = stdout.read.to_s
          err = stderr.read.to_s
          isSuccess = err.empty?
          if isSuccess
            UI.message "下載完畢"
            if is_clear
              # 清除本地所有檔案
              self.delete_all_local()
            end
          else
            UI.user_error!("下載腳本發生錯誤 - #{err}")
          end
        end

        # 覆蓋 Gemfile 與 Gemfile.lock
        FileUtils.cp "./#{tempDir}/Gemfile", "./Gemfile"
        FileUtils.cp "./#{tempDir}/Gemfile.lock", "./Gemfile.lock"
        FileUtils.rm_rf("./#{tempDir}/Gemfile")
        FileUtils.rm_rf("./#{tempDir}/Gemfile.lock")

        files = self.get_all_files(tempDir, "fastlane")

        pullScriptOri = ""
        pullScriptTarget = ""

        files[0].each_with_index { |ori, i|
          target = files[1][i]
          FileUtils.mkdir_p(File.dirname(target))

          name = File.basename(ori)
          # puts "準備更新檔名: #{name}"

          # 假如是更新腳本的話, 放置最後更新
          if name == "pull_script.rb"
            # puts "將腳本 pull_script.rb 放置最後更新"
            pullScriptOri = ori
            pullScriptTarget = target
          else
            # puts "轉移 #{ori} 到 #{target}"
            FileUtils.cp ori, target
          end
        }

        if pullScriptOri == "" or pullScriptTarget == ""
          UI.message("沒有檢測到更新腳本 pull_script.rb")
        else
          UI.message("腳本更新完成")
          FileUtils.cp pullScriptOri, pullScriptTarget
        end

        FileUtils.rm_rf(tempDir)
      end

      # 刪除本地所有檔案
      def self.delete_all_local()
        fileList = FileHandleAction.get_all_files('fastlane')
        # 除了 actions 資料夾, 其他都刪除
        fileList.each { |f|
          dirPath = f['dir_path']
          if dirPath == 'fastlane/actions' || dirPath == 'fastlane'
            # 只保留 pull_script.rb 檔案
            if f['name'] != 'pull_script.rb'
              # puts "刪除檔案: #{f['path']}"
              FileUtils.rm_rf(f['path'])
            end
          else
            # puts "刪除資料夾: #{f['dir_path']}"
            FileUtils.rm_rf(f['dir_path'])
          end
        }
      end

      # 取得某個路徑底下的所有檔案, 以及轉移後的路徑
      def self.get_all_files(ori_path, move_path)
        require 'pathname'
        require 'find'

        # files = Dir.glob("#{ori_path}/.*")
        files = []
        Find.find(ori_path) do |path|
          files << path
        end

        # 刪除第一個
        files.shift

        moved = move_path

        moveTotals = []

        # 要轉移的檔案
        movedBeforeFiles = []

        # 轉移後的檔案路徑(包含名稱)
        movedAfterFiles = []

        files.each { |file|
          # puts "確認檔案: #{file}"
          name = File.basename(file)
          path = File.dirname(file)
          if File.file?(file)
            # 是檔案
            movedBeforeFiles << file

            # 替換掉根目錄名稱, 轉移到 要替換的資料夾
            segments = []
            Pathname.new(file).each_filename { |s|
              segments << s
            }
            segments[0] = move_path
            isFileExist = File.exist?(segments.join('/'))

            # 檢查是否為 .env
            # puts "確認名稱: #{name}"
            if isFileExist && name == ".android.env"
              segments[-1] = ".android.env_new"
              moveFileTo = segments.join('/')
              movedAfterFiles << moveFileTo
            elsif isFileExist && name == ".ios.env"
              segments[-1] = ".ios.env_new"
              moveFileTo = segments.join('/')
              movedAfterFiles << moveFileTo
            else
              moveFileTo = segments.join('/')
              movedAfterFiles << moveFileTo
            end
            #f = File.open(file)
            #while line = f.gets do
            #  puts line
            #end
          else File.directory? file
            # 是資料夾
            inDirs = self.get_all_files(file, moved)
            movedBeforeFiles.concat inDirs[0]
            movedAfterFiles.concat inDirs[1]
          end
        }

        moveTotals << movedBeforeFiles
        moveTotals << movedAfterFiles

        moveTotals
      end

      def self.description
        "更新 flutter 自動化腳本"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(
            key: :method,
            description: "執行目的, 1 => 印出所有版本, 2 => 檢查更新, 3 => 直接進行更新",
            optional: true,
            is_string: false,
          ),
          FastlaneCore::ConfigItem.new(
            key: :version,
            description: "指定pull的版本",
            optional: true,
            is_string: true,
          ),
          FastlaneCore::ConfigItem.new(
            key: :clear,
            description: "是否完整清除本地檔案",
            optional: true,
            is_string: false,
          ),
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
