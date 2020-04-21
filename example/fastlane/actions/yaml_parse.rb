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
        add_lib(false, lib_hash('json_annotation'))
        add_lib(false, lib_hash('annotation_route'))
        # add_lib(false, lib_hash('xson'))
        add_lib(false, lib_hash('xson_annotation'))
        # add_lib(false, lib_hash('xson_builder'))
        add_lib(false, lib_hash('type_translator'))
        add_lib(false, core_lib_hash('mx_core'))

        # add_override_lib(lib_hash('crypto'))
        # add_override_lib(lib_hash('test_api'))

        add_lib(true, core_lib_hash('mx_json'))
        # add_lib(true, lib_hash('flutter_test'))
        # add_lib(true, lib_hash('flutter_driver'))
        # add_lib(true, lib_hash('test'))
        # add_lib(true, lib_hash('screenshots'))
        add_lib(true, lib_hash('json_serializable'))
        add_lib(true, lib_hash('build_runner'))
        add_default_images()
      end

      # 加入期貨專案需求的lib
      def self.add_futures_project_lib()
        add_lib(false, lib_hash('mx_base'))
        add_lib(false, lib_hash('dio'))
        add_lib(false, lib_hash('sprintf'))
        add_lib(false, lib_hash('json_annotation'))
        add_lib(false, lib_hash('flutter_spinkit'))
        add_lib(false, lib_hash('rxdart'))
        add_lib(false, lib_hash('annotation_route'))
        add_lib(false, lib_hash('url_launcher'))
        add_lib(false, lib_hash('shared_preferences'))
        add_lib(false, lib_hash('flutter_staggered_grid_view'))
        add_lib(false, lib_hash('cached_network_image'))
        add_lib(false, lib_hash('flutter_sticky_header'))
        add_lib(false, lib_hash('path_provider'))
        add_lib(false, lib_hash('path'))
        add_lib(false, lib_hash('fluttertoast'))
        add_lib(false, lib_hash('video_player'))
        add_lib(false, lib_hash('chewie'))
        add_lib(false, lib_hash('flutter_html'))
        add_lib(false, lib_hash('flutter_swiper'))
        add_lib(false, lib_hash('charts_flutter'))
        add_lib(false, lib_hash('package_info'))
        add_lib(false, lib_hash('barcode_scan'))
        add_lib(false, lib_hash('image_picker'))
        add_lib(false, lib_hash('share'))
        add_lib(false, lib_hash('stack_trace'))
        add_lib(true, lib_hash('flutter_test'))
        add_lib(true, lib_hash('flutter_driver'))
        add_lib(true, lib_hash('test'))
        add_lib(true, lib_hash('screenshots'))
        add_lib(true, lib_hash('json_serializable'))
        add_lib(true, lib_hash('build_runner'))
        add_lib(true, core_lib_hash('mx_json'))
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

      def add_core_lib(is_dev, lib_name)
        libHash = self.core_lib_hash(lib_name)
        add_lib(is_dev, libHash)
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

      # 取得 3rdpay/AppCore-Flutter 的 lib
      def self.core_lib_hash(lib_name)
        hash = {
          lib_name => {
            'git' => {
              'url' => 'git@github.com:3rdpay/AppCore-Flutter.git',
              'path' => lib_name
            }
          }
        }
      end

      def self.lib_hash(name)
        hash = {
          'flutter_localizations' => {
            'sdk' => 'flutter'
          },
          'flutter_test' => {
            'sdk' => 'flutter'
          },
          'flutter_driver' => {
            'sdk' => 'flutter'
          },
          'mx_base' => {
            'git' => {
              'url' => 'git@github.com:3rdpay/AppCMS-Flutter.git',
              'path' => 'mx_base'
            }
          },
          'crypto'                      => "^2.1.3",
          'test_api'                    => "^0.2.7",
          'test'                        => "^1.6.8",
          'annotation_route'            => "^0.0.2",
          'json_annotation'             => "^3.0.0",
          'build_runner'                => "^1.6.8",
          'json_serializable'           => "^3.2.2",
          'rxdart'                      => "^0.22.0",
          'flutter_swiper'              => "^1.1.6",
          'flutter_slidable'            => "^0.5.3",
          'barcode_scan'                => "^1.0.0",
          'flutter_sticky_header'       => "^0.4.0",
          'sqflite'                     => "^1.1.5",
          'dio'                         => "^2.1.0",
          'sprintf'                     => "^4.0.2",
          'flutter_spinkit'             => "^3.1.0",
          'url_launcher'                => "^5.0.2",
          'shared_preferences'          => "^0.5.1+2",
          'flutter_staggered_grid_view' => "^0.2.7",
          'cached_network_image'        => "^1.1.0",
          'path_provider'               => "^0.5.0+1",
          'path'                        => "^1.6.2",
          'fluttertoast'                => "^3.0.3",
          'video_player'                => "^0.10.0+4",
          'chewie'                      => "^0.9.7",
          'flutter_html'                => "^0.9.6",
          'charts_flutter'              => "^0.6.0",
          'package_info'                => "^0.4.0+3",
          'image_picker'                => "^0.5.3+1",
          'share'                       => "^0.6.1",
          'stack_trace'                 => "^1.9.3",
          'screenshots'                 => "^0.2.1",
          'xson'                        => "^1.0.4",
          'xson_builder'                => "^1.0.0",
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
