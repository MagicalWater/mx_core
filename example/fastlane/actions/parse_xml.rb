module Fastlane
  module Actions
    class ParseXmlAction < Action
      def self.write(params)
        require 'nokogiri'

        puts "Action path: #{Dir.pwd}"

        xmlPath = params[:xml_path]
        nodeArray = params[:node_array]
        paramLabel = params[:label]
        paramValue = params[:value]

        # 更新
        File.open(xmlPath, "r:UTF-8") { |readFile|
          doc = Nokogiri::XML(readFile, nil, "UTF-8")

          self.write_value(doc, nil, nodeArray, paramLabel, paramValue)
          File.open(xmlPath, "w:UTF-8") do |writeFile|
            writeFile.write doc.to_xml
          end
          UI.message("寫入完成")
        }
      end

      def self.read(params)
        require 'nokogiri'

        puts "Action path: #{Dir.pwd}"

        xmlPath = params[:xml_path]
        nodeArray = params[:node_array]
        paramLabel = params[:label]

        readValue = ""

        # 更新
        File.open(xmlPath, "r:UTF-8") { |readFile|
          doc = Nokogiri::XML(readFile, nil, "UTF-8")
          readValue = self.read_value(doc, nodeArray, paramLabel)
          UI.message("讀取完成")
        }

        readValue
      end

      # 傳入xml需要尋找的節點, 以及在此節點下取得對應label的value
      def self.read_value(xml, nodeList, label)
        v = ""
        if nodeList.length > 1 then
          # 長度大於1, 代表我們需要繼續往下尋找節點
          xml.css(nodeList[0]).each do |node|
            UI.message("Search next node #{nodeList[1]}")
            v = self.read_value(node, nodeList[1..-1], label)
          end
        else
          # 長度等於1, 代表這個節點就是我們要的
          xml.css(nodeList[0]).each do |node|
            v = node[label]
            UI.message("Find node #{nodeList[0]}, get #{label}=#{v}")
          end
        end
        v
      end

      # 傳入xml需要尋找的節點, 以及在此節點下要設置的label以及value
      def self.write_value(xml, node, nodeList, label, value)
        if node == nil
          node = xml
        end

        if nodeList.length > 1 then
          # 長度大於1, 代表我們需要繼續往下尋找節點
          node.css(nodeList[0]).each do |subNode|
            UI.message("Search next node #{nodeList[0]}")
            self.write_value(xml, subNode, nodeList[1..-1], label, value)
          end
        else
          # 長度等於1, 代表這個節點就是我們要的
          # 檢查是否存在此node
          puts "Local node #{nodeList[0]}"

          if node.css(nodeList[0]).empty?
            # 建立新的 node
            subNode = Nokogiri::XML::Node.new nodeList[0], xml
            subNode[label] = value
            node.children.before(subNode)
            UI.message("Create node #{nodeList[0]}, set #{label}=#{value}")
          else
            # 存在, 直接賦值
            node.css(nodeList[0]).each do |subNode|
              subNode[label] = value
              UI.message("Find node #{nodeList[0]}, set #{label}=#{value}")
            end
          end
        end
      end

      def self.description
        "解析 xml 與寫入"
      end

      def self.authors
        ["https://github.com/MagicalWater/Water"]
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(
            key: :xml_path,
            description: "xml的位置",
            is_string: true,
            optional: false
          ),
          FastlaneCore::ConfigItem.new(
            key: :node_array,
            description: "設置的節點",
            is_string: false,
            optional: false
          ),
          FastlaneCore::ConfigItem.new(
            key: :label,
            description: "設置的label",
            is_string: true,
            optional: false
          ),
          FastlaneCore::ConfigItem.new(
            key: :value,
            description: "設置的value",
            is_string: true,
            optional: false
          ),
        ]
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end
