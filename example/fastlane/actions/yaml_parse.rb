module Fastlane
  module Actions
    class YamlParseAction < Action

      def self.run(params)

      end

      def self.load()
        require 'yaml'
        yamlHash = YAML.load_file('pubspec.yaml')
        yamlHash
      end

      def self.write(yaml_hash)
        require 'yaml'
        File.write('pubspec.yaml', yaml_hash.to_yaml)
      end

      # 加入一般專案最少需求的lib
      def self.add_general_project_lib()
        add_lib(false, lib_hash('flutter_localizations'))
        add_lib(false, lib_hash('mx_core'))
        add_lib(true, lib_hash('build_runner'))
        add_default_images()
      end

      def self.add_default_images()
        yamlHash = YAML.load_file('pubspec.yaml')
        if yamlHash.key?('flutter')
          yamlHash['flutter']['assets'] = ['assets/images/']
        else
          yamlHash['flutter'] = {
            'assets' => [
              'assets/images/'
            ]
          }
        end

        File.write('pubspec.yaml', yamlHash.to_yaml)
      end

      def self.add_lib(is_dev, lib_hash)
        require 'yaml'
        yamlHash = YAML.load_file('pubspec.yaml')
        normalTarget = 'dependencies'
        devTarget = 'dev_dependencies'
        target = ''
        if is_dev
          target = devTarget
        else
          target = normalTarget
        end
        lib_hash.each { |k,v|

          # 只有當 一般 跟 dev target 都不存在時才引入
          if !(yamlHash[normalTarget].include?(k)) && !(yamlHash[devTarget].include?(k))
            # 不存在時才引入
            yamlHash[target][k] = v
          end
        }
        File.write('pubspec.yaml', yamlHash.to_yaml)
      end

      # 添加 override 的庫
      def self.add_override_lib(lib_hash)
        require 'yaml'
        yamlHash = YAML.load_file('pubspec.yaml')
        target = 'dependency_overrides'
        if !(yamlHash.include?(target))
          yamlHash[target] = {}
        end
        lib_hash.each { |k,v|
          if !(yamlHash[target].include?(k))
            # 不存在時才引入
            yamlHash[target][k] = v
          end
        }
        File.write('pubspec.yaml', yamlHash.to_yaml)
      end

      def self.lib_hash(name)
        hash = {
          'flutter_localizations' => {
            'sdk' => 'flutter'
          },
          'mx_core' => {
            'git' => {
              'url' => 'git@github.com:MagicalWater/Base-APP-Core.git',
            }
          },
          'mx_json' => {
            'git' => {
              'url' => 'git@github.com:MagicalWater/Base-APP-JsonBean.git',
            }
          },
          'annotation_route'            => "^0.0.2",
          'json_annotation'             => "^3.0.0",
          'build_runner'                => "^1.6.8",
          'json_serializable'           => "^3.2.2",
          'flutter_sticky_header'       => "^0.4.0",
          'flutter_staggered_grid_view' => "^0.2.7",
          'xson_annotation'             => "^1.0.0",
          'type_translator'             => "^1.0.2+1",
        }

        findHash = {
          name => hash[name]
        }
        findHash
      end

      def self.description
        "解析yaml"
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
