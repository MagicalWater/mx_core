module Fastlane
  module Actions
    class RoutesGenerateAction < Action

      # 排序好的頁面
      $globalSortPages = []

      # 頁面對應的路徑名稱
      $globalPagePath = {}

      def self.run(params)
        # 自動生成 Route 相關檔案
        self.generate_route()

        pages = self.get_routes_page

        # 生成基礎 application bloc
        self.generate_application_bloc()

        # 生成 page / widget / bloc
        newCreatedPage = self.generate_page()

        self.generate_page_bloc()

        # 將 page / widget 插入到 route_mixin
        self.insert_route('lib/router/route_widget.dart')

        # 假如有新的 widget 或 page, 則跑 自動生成 code 命令, 或者 enforce_command 強制指令開啟時
        if !newCreatedPage.empty? || params[:enforce_command]
          UI.message "有新的 page 或 widget 產生 或 強制輸入指令: page - #{newCreatedPage.size}, enforce - #{params[:enforce_command]}, 自動添加命令"
          UI.message "flutter packages pub run build_runner build --delete-conflicting-outputs"
          system "flutter packages pub run build_runner build --delete-conflicting-outputs"
          UI.important "完成, 新 page - #{newCreatedPage.size}"
          newCreatedPage.each { |p|
            UI.message "page: #{p}"
          }
          return true
        else
          UI.message "沒有新的 page 或 widget 需要生成"
          return false
        end

      end

      # 自動生成 page
      # 回傳自動產生的新的 page 列表
      def self.generate_page()
        newCreated = []
        # 只生成不存在的

        $globalSortPages.each { |page|
          # 取得應該生成的路徑
          placePath = get_page_place_path(page)
          # puts "頁面: #{page} 放置: #{placePath}"
          self.get_no_exist_file("lib/ui/page/#{placePath}", [page], '_page.dart').each { |hash|
            newCreated << hash['filename']
            UI.message "檢測到缺少 page : #{hash['filename']}, 自動生成"
            self.place_page(
              hash['filename'],
              hash['project'],
              hash['ori'],
              hash['lower_line'],
              hash['upper_camel'],
              placePath
            )
          }
        }
        newCreated
      end

      # 自動生成基礎 applicationBloc
      def self.generate_application_bloc()

        FileUtils.mkdir_p('lib/bloc')

        appBlocPath = 'fastlane/files/project_construct/bloc/application_bloc_dart'
        targetPath = 'lib/bloc/application_bloc.dart'

        if !(File.exist?(targetPath))
          hash = FileHandleAction.convert_name(appBlocPath)
          template = FileHandleAction.get_template(appBlocPath, hash)
          File.write(targetPath, template)
        end
      end

      # 自動生成 bloc
      def self.generate_page_bloc()
        # 只生成不存在的
        $globalSortPages.each { |page|
          # 取得應該生成的路徑
          placePath = get_page_place_path(page)
          # puts "頁面: #{page} 放置: #{placePath}"
          self.get_no_exist_file("lib/bloc/page/#{placePath}", [page], '_bloc.dart').each { |hash|
          
            self.place_page_bloc(
              hash['filename'],
              hash['project'],
              hash['ori'],
              hash['lower_line'],
              hash['upper_camel'],
              placePath
            )
          }
        }
      end

      # 自動在 route_widget_mixin 加入缺少的 page / widget
      def self.insert_route(route_mixin_file)
        content = File.read(route_mixin_file, :encoding => 'UTF-8')

        # 搜索 import 區域, 並插入缺少 import 的 page
        content = content.gsub(/(import .+;(\s)+)+/) { |c|
          addText = ""
          $globalSortPages.each { |page|
            convertName = FileHandleAction.convert_name(page)
            findName = "#{convertName['lower_line']}_bloc.dart"
            placePath = get_page_place_path(page)
            if !(c.include?(findName))
              if placePath.to_s.empty?
                addText = addText + "import 'package:#{FileHandleAction.project_name()}/bloc/page/#{findName}';\n"
              else
                addText = addText + "import 'package:#{FileHandleAction.project_name()}/bloc/page/#{placePath}/#{findName}';\n"
              end
              # puts "不包含 import: #{findName}"
            end
          }
          c = c + addText
          c
        }

        # 搜索 pageList 實體, 並插入缺少的page
        content = content.gsub(/(?<=pageList = \[)(\s|.)*?(?=\];)/) { |c|
          addText = ""
          $globalSortPages.each { |page|
            findName = "Pages.#{page}"
            if c.include? findName
              # puts "包含 page: #{findName}"
            else
              # puts "不包含 page: #{findName}"
              addText = "#{addText}  #{findName},\n  "
            end
          }
          c = c + addText
          c
        }

        # 搜索 _getPage 方法實體, 並插入缺少的 page
        content = content.gsub(/  Widget getPage\(RouteData data\) \{(\s|.)+?\n  \}/) { |c|

          # 一個一個檢查 Page 是否存在
          addText = ""

          $globalSortPages.each { |page|
            if c.include? "Pages.#{page}"
              # puts "包含 page: #{page}"
            else
              # puts "不包含 page: #{page}"

              # 取得名稱的各種樣式
              convertName = FileHandleAction.convert_name(page)
              addText = addText + %{      case Pages.#{page}:
        return BlocProvider(
          child: child,
          bloc: #{convertName['upper_camel']}Bloc(blocOption),
        );
}
            end
          }
          # puts "需要加入: #{addText}"
          c = c.gsub(/      default:/) { |place|
            # puts "找到: #{addText + place}"
            place = addText + place
          }

          c
        }

        File.write(route_mixin_file, content)
      end



      # 自動生成 route 必備檔案
      def self.generate_route()
        # 只生成不存在的

        # 檢查是否有 route.dart
        self.get_no_exist_file('lib/router', ["route"], '.dart').each { |hash|
          tempText = FileHandleAction.get_template("fastlane/files/template/template_route_dart", hash)
          File.write("lib/router/route.dart", tempText)
        }

        # 檢查是否有 route_widget.dart
        self.get_no_exist_file('lib/router', ["route_widget"], '.dart').each { |hash|
          # puts "生成 route_widget: #{hash}"
          tempText = FileHandleAction.get_template("fastlane/files/template/template_route_widget_dart", hash)
          # puts "寫入 route_widget: #{tempText}"
          File.write("lib/router/route_widget.dart", tempText)
        }

        # 檢查是否有 routes.dart
        self.get_no_exist_file('lib/router', ["routes"], '.dart').each { |hash|
          tempText = FileHandleAction.get_template("fastlane/files/template/template_routes_dart", hash)
          File.write("lib/router/routes.dart", tempText)
        }

      end


      # 取得需要產生的(不存在的)檔案列表
      # 即是 在 find_path 中 沒有出現的 find_file
      def self.get_no_exist_file(find_path, find_files, file_suffix_name)
        noExistFiles = []
        FileUtils.mkdir_p(find_path)
        findFiles = []
        findAA = []
        FileHandleAction.get_all_files(find_path, 0).each { |file|
          findFiles << file['ori']
          findAA << file['path']
        }

        find_files.each { |file|
          convertName = FileHandleAction.convert_name(file)

          # 先搜索page是否已存在
          filename = "#{convertName['lower_line']}#{file_suffix_name}"

          # puts "檔案存在嗎: #{findFiles.include? filename}, #{file}"
          if !findFiles.include? filename
            # 檔案不存在, 創建
            hash = {
              "filename" => filename,
              "project" => FileHandleAction.project_name(),
              "ori" => convertName['ori'],
              "lower_line" => convertName['lower_line'],
              "upper_camel" => convertName['upper_camel'],
            }
            noExistFiles << hash
          end
        }
        noExistFiles
      end

      # 從 template_page_dart 產生一個 page 至放到目標
      def self.place_page(target_name, project, ori_name, lower_line_name, upper_camel_name, place_path)
        hashPath = ''
        if !(place_path.to_s.empty?)
          hashPath = "#{place_path}/"
        end
        hash = {
          "project" => project,
          "ori" => ori_name,
          "lower_line" => lower_line_name,
          "upper_camel" => upper_camel_name,
          "path" => hashPath,
        }
        tempText = FileHandleAction.get_template("fastlane/files/template/template_page_dart", hash)
        FileUtils.mkdir_p("lib/ui/page/#{place_path}")
        if place_path.to_s.empty?
          File.write("lib/ui/page/#{target_name}", tempText)
        else 
          File.write("lib/ui/page/#{place_path}/#{target_name}", tempText)
        end
      end

      # 從 template_page_bloc_dart 產生一個 bloc 至放到目標
      def self.place_page_bloc(target_name, project, ori_name, lower_line_name, upper_camel_name, place_path)
        hash = {
          "project" => project,
          "ori" => ori_name,
          "lower_line" => lower_line_name,
          "upper_camel" => upper_camel_name,
        }
        tempText = FileHandleAction.get_template("fastlane/files/template/template_page_bloc_dart", hash)
        FileUtils.mkdir_p("lib/bloc/page/#{place_path}")
        if place_path.to_s.empty?
          File.write("lib/bloc/page/#{target_name}", tempText)
        else 
          File.write("lib/bloc/page/#{place_path}/#{target_name}", tempText)
        end
      end

      # 取得 routes 裡所有的 page 名稱 以及對應的路徑
      def self.get_routes_page()
        routesString = File.read("./lib/router/routes.dart", :encoding => 'UTF-8')
        result = /(?<=class Pages {)(\s|.|)+?(?=})/.match(routesString)
        pages = {}
        result[0].scan(/(?<=static const ).+(?=;)/).each { |page|
          name = page.scan(/\w+(?= *=)/)[0]
          path = page.scan(/(?<=\").+(?=\")/)[0]
          pages[name] = path
        }

        realPathPage = {}
        pages.each { |k, v|
          $globalPagePath[k] = parse_real_path(pages, v)
        }

        # 將頁面依照節點深度排序
        $globalSortPages = pages.keys.sort { |k1, k2|
          v1Len = $globalPagePath[k1].split('/').size
          v2Len = $globalPagePath[k2].split('/').size
          if v1Len < v2Len then
            -1
          elsif v1Len > v2Len then
            1
          else
            0
          end
        }

        #puts "尋找每個頁面的父親頁面名稱"
        #$globalSortPages.each { |e|
        #  puts "頁面: #{e}, 父親: #{get_parent_page_name(e)}"
        #}

        pages
      end

      # 取得某個頁面應該放置的路徑
      def self.get_page_place_path(page_name)
        path = get_page_place_dir(page_name)
        # 刪除最後一個節點名稱
        if (path.split('/').size > 1)
          path = path.split('/')[0..-2].join('/')
        else
          path = ''
        end
        path
      end

      def self.get_page_place_dir(page_name)
        path = FileHandleAction.convert_name(page_name)['lower_line']
        # 檢查是否有父親, 有父親時, 需要再加上父親的路徑
        parent_name = get_parent_page_name(page_name)
        if !(parent_name.to_s.empty?)
          path = "#{get_page_place_dir(parent_name)}/#{path}"
        end
        path
      end

      # 取得某個頁面的父親頁面名稱
      def self.get_parent_page_name(page_name)
        page_path = $globalPagePath[page_name]
        finds = $globalPagePath.select { |k, v|
          isPathOk = page_path.start_with?(v)
          isDepthOk = false
          if isPathOk
            vDepth = v.split('/').size
            pageDepth = page_path.split('/').size
            isDepthOk = (vDepth == pageDepth - 1)
          end
          page_path != v && isPathOk && isDepthOk
        }
        parentName = nil
        if finds.size > 0
          parentName = finds.keys.last
        end
        parentName
      end

      # 若 path 含有變數, 則先全數解析
      def self.parse_real_path(pages, path)
        lastPath = ''
        if path.scan(/\$\w+(?=\/)/).size > 0
          path = path.gsub(/\$\w+(?=\/)/).each { |find|
            pageName = find[1..-1]
            parentPath = pages[pageName]
            parentPath
          }
          lastPath = parse_real_path(pages, path)
        else
          lastPath = path
        end
        lastPath
      end

      def self.description
        "根據 lib/router/routes.dart 生成對應的 page widget bloc"
      end

      def self.available_options
        [
            FastlaneCore::ConfigItem.new(
              key: :enforce_command,
              description: "強制輸入生成code指令",
              is_string: false,
              optional: false
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
