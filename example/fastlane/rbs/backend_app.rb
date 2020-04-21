require 'net/http'
require 'json'

isWindows = (/cygwin|mswin|mingw|bccwin|wince|emx/ =~ RUBY_PLATFORM) != nil
isMac = (/darwin/ =~ RUBY_PLATFORM) != nil
if isWindows
  system "chcp 65001"
end

$xing_debug_toekn = "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsImp0aSI6IjhlZDM1ODFmODE2NWNhM2U4NmIwZWRiZDM3ZTI3MmYxZDcwN2ViNGI5YzBkZGYwYTAwOWM4Yjg4OTZkOGM0NTg2M2E3Y2NhNjRlZDBmNmU1In0.eyJhdWQiOiI1ZWU3NGI4Mi04ZTNlLTQ4NzEtYTBhZi01YjJlMGU0NjQ1ZWIiLCJqdGkiOiI4ZWQzNTgxZjgxNjVjYTNlODZiMGVkYmQzN2UyNzJmMWQ3MDdlYjRiOWMwZGRmMGEwMDljOGI4ODk2ZDhjNDU4NjNhN2NjYTY0ZWQwZjZlNSIsImlhdCI6MTUzOTg1NzQ0OCwibmJmIjoxNTM5ODU3NDQ4LCJleHAiOjE1NzEzOTM0NDgsInN1YiI6IjEzIiwic2NvcGVzIjpbXX0.GunbRg5gWeMK1WOaI8RUVezf63y2-5uY0hLUvMaSrDoJBgq8CW5iKA9gOq9q3zFLlstokOOmeOlBqN_U6Z3za1_cadlONc_6-VNSBLVg8CAFAEMbPApq-MR5bTsYfIJnSgVY3Lea54-DZP8UAQ-zV8VzeCUlJ04ipNtlAsg4cDc6yo15g0_8NsgeK3hb5RacVtbeVhj6UOd0ptgq5GXRFaR2XN-qo26JGjsQKus_f5T15Nd5BavMSytTpy2mwk3NCUYX3kxICnHlIPCZuAMN3unKXkxYuWc33a8700QlvR151UJko6AzwpWhBiq-VKDLfFYK9S_3M-_kkhgmQOFZpaJfMeYo9OZzNM9FdELtn2ZBao2RQZJU_asRY26V2LWM39SgJxUG2XXY8Cog5yUCeO1mVFfz5NamQwLtVP0d0bZZYEMSAZA2b2NcIWIw2nHe8Bly4IrR9maTsR70T_4i8FQqKbNSwEjWqYP065Lz1-Qb7v9XB6DtY4plg1ZW9K_95FCJ7pulPQtB4BP2CIirUeXqwuZ_nXag9nujZ37CxOuSNGXJsx1Bd7PstzViRVAx9AkFpzmgU454Uv4xrCuGKaKjczV6UmP34nCrGAvZ5w1XtURgtmj4L4Rz7AfS81PgIf_bnFQvZwubx0BqGMGN-O47eLc1T8ybsXQkeURBTnU"
$xing_release_toekn = "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsImp0aSI6IjdlMmM2MDc2ZWI2MTk5ZWNkMmE1ZTM4Zjg0OTkxODk1MjBhODkxOTA4MjdhNWZhODZhOThhZDU5MDE3NDIyY2RhM2VmN2RlYWFlNDdmYzliIn0.eyJhdWQiOiJjMDllYmVkNC00YjZmLTQwNjItOTNiNS1iODZjN2M0MTNkODkiLCJqdGkiOiI3ZTJjNjA3NmViNjE5OWVjZDJhNWUzOGY4NDk5MTg5NTIwYTg5MTkwODI3YTVmYTg2YTk4YWQ1OTAxNzQyMmNkYTNlZjdkZWFhZTQ3ZmM5YiIsImlhdCI6MTUzOTg1NzE5MywibmJmIjoxNTM5ODU3MTkzLCJleHAiOjE1NzEzOTMxOTMsInN1YiI6IjE1Iiwic2NvcGVzIjpbXX0.XWuN4PmqC521Ui55oY8h_-xzycoVENQVmBuK6JRUQCuCT1J6kr-x22ZWouu6qYC3j1O-rZQxr02h3P0NqclGpfvzPfJeP1Q4VYEqTZ7u_1FVAnGI5zlU9ZenmEM1d82cWvNwWOoPi9XAk7mEaHxODZjxOYH_y49oHwl5MgP_hkeSeOJDnXXF8yU-e5cA-22N99k9TzkSiz6B0c3me_IU1O1TgJc6pHyHhSnhWVHKaAE9SEX3j7m9MO1asCieakeCjSUfF78MablsqA4O6YtPKhaFZmwE4qBuxnwmt6Z8zbtPsKbI4NuoakqD9HLDl0XjwtuW31XVN-2VYhe--J6kzqGiTMfQZ2ZIdqR98-9Hd--qsWqexGxQtQnA9U-y74IJp28l_E5V-_Ms8jtj7x-MLcf6epHrybejhIyLoUQ2HpbE3r36MDq1v4fqTpHY6xo28joPSP_rCRT9n3RhEuhyYx8UHLRuYOq4ed2ZOnHNtWzTT-ugJ3pf-L7OsVBD78jxoznHmUANrfRqSddC-Ev52yNdMnfEhi_cbN8lMFsRp8FguyB3mLWdGbCqAm1kp0tqvY9T-_AsIn4584z7i9agSqWjLfgF6Ev5x_NRZGS8_iiygjrw9upA2TRuIVHUMmWH85dbjokSU8Bu4BvlNLu7aaUshDDgtahHLB-QzvPICu0"

$develop_debug_token = "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsImp0aSI6Ijk0ZjgxODlhNzhhMjFlNGIxYjVmMmI5MjhhMzdjM2ViN2JkYmU5Nzk5YTkwOTA1YWM5NTgyNTY3MDYwZGY4YWJkMzE4NjdhM2EwNGY3ZmIyIn0.eyJhdWQiOiI4ZTU2ZWMyNC01ZDQzLTQxZWYtOTc2OS05Y2E1NmVhMzAwYzIiLCJqdGkiOiI5NGY4MTg5YTc4YTIxZTRiMWI1ZjJiOTI4YTM3YzNlYjdiZGJlOTc5OWE5MDkwNWFjOTU4MjU2NzA2MGRmOGFiZDMxODY3YTNhMDRmN2ZiMiIsImlhdCI6MTU2MzQxODEyNiwibmJmIjoxNTYzNDE4MTI2LCJleHAiOjE1OTUwNDA1MjYsInN1YiI6IjEwIiwic2NvcGVzIjpbXX0.h7qISw_e62RIq37VJ1RVSSY6M-MHru5qv8OgHUpcJHTcDLFklqIt3QOVHIP3Rfs68h6IRTxfmoc1knpXLdDCgCibFOZBJ7A2xEVD6CQfELPBFI2j7tTw32ZXc3lJqxPfnVTqR6IKhpQMYxjG39lFLd5BfbqaflTNalJUowMFvpnw418Hz1fU9Gs_xeKgJeTAAVLRoOOmVM6M9DySNC2irA8wC5hUWKMgETwScaeNvPs3yvL7bjGI0BxGn6F3ey08nCfcfx2robJUuOOOBP-TuNK2hxzOGAZN5Mqb4pX_FFMEOEvJXXy0vi9V4LUQsrVzEqIec_Y81XeXBEvZqCCyhzC4WSqNT4aefqA231C3KZNI_asxCxQ8eqMmSN4OtrK87breGd66dwJkXfIWB-GKDlIUbyRKKwwwObSlrncxypVvn030zQ9Zx8_5_oB0b0TSBXnvVqLlk83eZNCUpIej31hWvDwihAJhf0wlOcmdbzVi9RsDjjYAYtTY8RcDVKB2wd0b55ifm5gHHx_Q9OlCcRP15iLAhnnrKoPO3ez_aljE315BfkMexEmo7e8KA8-BuyDctGcvysZbb_5ieA4Zp8zIH_8wYcs2myloXFWBWlTISqVCBIXNP9Fjh6p4NIPdTZgBsziEfoF_T9FNo-XHTkfMdiL5HHXH1T8kFmBzmpk"
$develop_release_token = "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsImp0aSI6ImQ5MTIxMDI4ZTZmMWFlZDkwNGI2ZjU1OWNmMjYyNDk3MWM4ZTI3MDM5ZWVjOWIxOGZhZmFiZmM0MmUyY2M2NmRlNzA0NWUwOWIyYzg0NWZmIn0.eyJhdWQiOiIwNDA2ZDc0ZC03NmFkLTRkMzctOWQ5MC0xYWQ4OTAzZDRkYzciLCJqdGkiOiJkOTEyMTAyOGU2ZjFhZWQ5MDRiNmY1NTljZjI2MjQ5NzFjOGUyNzAzOWVlYzliMThmYWZhYmZjNDJlMmNjNjZkZTcwNDVlMDliMmM4NDVmZiIsImlhdCI6MTU2MzQxODA3MiwibmJmIjoxNTYzNDE4MDcyLCJleHAiOjE1OTUwNDA0NzIsInN1YiI6IjEwIiwic2NvcGVzIjpbXX0.efvAbRXEIECypfXehMlZuZ0aNT8cDlA0V7HwbjHCsRXhbGPge93GA7vhZQciDDQxhchIKVc4yoq6YsVQY58b_kSB6vEtq1EAQPZVsciSSYAa1fOIUfMr1YP3noQpIAumQCCRI5sTYhhA0hLqkXOsV-9m75kSmofXHSFCgC0P8rp6b7mHWwxYGQchcFNlQ2zFMSg-mx2EymqUZyMvYJhVj3d3BOTxa35lGQDbWgXtLE7j9aelW0onEmEL7t41w6i3U5aoD3okySkhQNwEWeDzFH4phxekUmYF4d3m6QnZyRCJVYOqgiDLxKf3xIs8z6R-qpTjsSOLt4SClAY4Y6zpsa683NXHJXH5XS7FdTzmE-O2iGIXtdy_oHHGSVH6_HahHjKwL79pxxzaJxQmAoVSt6LiHmYD978AO1fuyOqlTafv3MIXCPqdbNdvas_8Ry2eaIW3a4AhZWjXzcjqXvhxPyxSqVtufxuxCbA_bqkfvEoF89aMjYiEVoUI16DR_2Jgu6KhXVDQaW7GANUyXohZxWoDHLBXA6NewwrSDci2hlqBpEq8RbZRZpgVj30UhHrl8JEWkyE0-Hg1eyQMUUZXEHlRpO5GhX4OJUN6MUK9Y9GHawaNoUdWL-Evczf21Sx30G0cr1Kz7B_aVsXeHSk2pnqbXzSLR8I9Stw4FXQhlXE"

$debug_host = 'http://api.appcms.xing99.cc'
$release_host = 'https://api.apps99.cc'

$used_host = ""

$is_release = false

$headerKey = "Authorization"
$xingHeaderValue = "Bearer #{$token}"
$developHeaderValue = ""

$appDataList = nil

def is_number? string
  true if Float(string) rescue false
end

# 同步測試機/正式機對應的環境變數
def sync_environment(release)
  $is_release = release
  if release
    $used_host = $release_host
    $xingHeaderValue = "Bearer #{$xing_release_toekn}"
    $developHeaderValue = "Bearer #{$develop_release_token}"
  else
    $used_host = $debug_host
    $xingHeaderValue = "Bearer #{$xing_debug_toekn}"
    $developHeaderValue = "Bearer #{$develop_debug_token}"
  end
end

# 建立推送任務
def create_push_task(appData)
  taskId = nil
  oauth = get_oauth()
  create_push_url = "#{$used_host}/pushnotification/message/maintain"

  bodyHash = {
    :content => "欢迎加入 #{appData['name']}",
  }

  bodyHash['topic_id[0]'] = appData['id']

  body = URI.encode_www_form(bodyHash)

  url = URI.parse(create_push_url)
  req = Net::HTTP::Post.new(url.to_s, initheader = {$headerKey => $developHeaderValue})
  req.body = body

  Net::HTTP.start(url.host, url.port, :use_ssl => true) do |http|
    response = http.request(req)
    repBody = response.body
    code = JSON.parse(repBody)["code"]
    isSuccess = code == 200 || code == 201
    if isSuccess
      taskId = JSON.parse(repBody)["data"]['id'].to_s
      puts "create push task success"
    else 
      puts "create push task fail - #{repBody}"
    end
  end
  taskId
end

# 發送推播
def start_push(task_id)
  oauth = get_oauth()
  start_push_url = "#{$used_host}/pushnotification/message/push"

  body = URI.encode_www_form({
    :id => task_id
  })

  url = URI.parse(start_push_url)
  req = Net::HTTP::Post.new(url.to_s, initheader = {$headerKey => $developHeaderValue})
  req.body = body

  isSuccess = false

  Net::HTTP.start(url.host, url.port, :use_ssl => true) do |http|
    response = http.request(req)
    repBody = response.body
    code = JSON.parse(repBody)["code"]
    isSuccess = code == 200 || code == 201
    if isSuccess
      puts "push success"
    else
      puts "push fail"
    end
  end
  isSuccess
end

# 刪除推送任務
def delete_push_task(task_id)
  oauth = get_oauth()
  create_push_url = "#{$used_host}/pushnotification/message/maintain?id[]=#{task_id}"

  url = URI.parse(create_push_url)
  req = Net::HTTP::Delete.new(url.to_s, initheader = {$headerKey => $developHeaderValue})

  isSuccess = false

  Net::HTTP.start(url.host, url.port, :use_ssl => true) do |http|
    response = http.request(req)
    repBody = response.body
    code = JSON.parse(repBody)["code"]
    isSuccess = code == 200 || code == 201
    if isSuccess
      taskId = JSON.parse(repBody)["data"]['id'].to_s
      puts "delete push task success"
    else 
      puts "delete push task fail - #{repBody}"
    end
  end
  isSuccess
end

# 測試推播,
# 建立一個推播任務
# 推播任務執行
# 刪除任務
def push_test(code)
  # $token = login('water', 'wateris666')
  # $developHeaderValue = "Bearer #{$token}"
  
  appData = get_app_data(code)
  if appData.nil?
    puts "找不到對應的 app code - #{code}"
    return
  end

  taskId = create_push_task(appData)

  if taskId.to_s.empty?
    puts "建立推送任務失敗"
    return
  end

  pushSuccess = start_push(taskId)

  deleteSuccess = delete_push_task(taskId)

end

# 解析參數後回傳
def parse_argv()

  hash = Hash[ ARGV.join(' ').scan(/--?([^=\s]+)(?:=(\S+))?/) ]
  if hash.length == 0 || (hash.length == 1 && hash.key?('env'))
    # 載入環境變數的設定檔

    envPath = ''
    if hash.key?('env')
      envPath = hash['env']
    else
      envPath = "#{__dir__}/.backend_app.env"
      hash['env'] = envPath
    end

    create_env(envPath)

    envText = File.read(envPath, :encoding => 'UTF-8')
    envs = {}
    envText.gsub(/\w+ *= *.+(?= *\n)/) { |c|
      cSplit = c.split('=').map{ |s| s.strip }
      if cSplit.length == 2 && !(is_number?(cSplit[0]))
        envs[cSplit[0]] = cSplit[1]
      end
    }

    hash['code'] = envs['code']

    if envs['method'] == '2'
      hash['update'] = ''
    elsif envs['method'] == '3'
      hash['push_test'] = ''
    end
    if envs['release'] == 'on'
      hash['release'] = ''
    end
    if !(envs['xiaomi'].to_s.include? '--')
      hash['xiaomi'] = envs['xiaomi']
    end
    if !(envs['umeng'].to_s.include? '--')
      hash['umeng'] = envs['umeng']
    end
    if !(envs['name'].to_s.include? '--')
      hash['name'] = envs['name']
    end
    if !(envs['redirect_switch'].to_s.include? '--')
      hash['redirect_switch'] = envs['redirect_switch']
    end
    if !(envs['redirect_url'].to_s.include? '--')
      hash['redirect_url'] = envs['redirect_url']
    end
    if !(envs['qq'].to_s.include? '--')
      hash['qq'] = envs['qq']
    end
    if !(envs['wechat'].to_s.include? '--')
      hash['wechat'] = envs['wechat']
    end
    if !(envs['customer'].to_s.include? '--')
      hash['customer'] = envs['customer']
    end
    if !(ENV['state'].to_s.include? '--')
      hash['state'] = envs['state']
    end
  end
  hash
end

# 取得 oauth 認證資料
def get_oauth()
  oauthUrl = "https://admin.apps99.cc/assets/config/passport.json"
  url = URI.parse(oauthUrl)
  req = Net::HTTP::Get.new(url.to_s)

  clientId = ""
  clientSecret = ""
  
  Net::HTTP.start(url.host, url.port, :use_ssl => true) do |http|
    response = http.request(req)
    repBody = response.body
    stable = JSON.parse(repBody)["stable"]
    clientId = stable['client_id']
    clientSecret = stable['client_secret']
    # puts "id = #{clientId}"
    # puts "secret = #{clientSecret}"
  end

  hash = {
    "id" => clientId,
    "secret" => clientSecret
  }
  hash
end

# 登入 回傳 access token
def login(username, password)
  oauth = get_oauth()
  login_url = "#{$used_host}/passport/login"

  body = URI.encode_www_form({
    :username => username,
    :password => password,
    :client_id => oauth['id'], 
    :client_secret => oauth['secret'],
    :grant_type => 'password'
  })

  url = URI.parse(login_url)
  req = Net::HTTP::Post.new(url.to_s)
  req.body = body
  token = nil
  Net::HTTP.start(url.host, url.port, :use_ssl => true) do |http|
    response = http.request(req)
    repBody = response.body
    token = JSON.parse(repBody)["data"]['access_token']
  end
  # puts "access token = #{token}"
  token
end

# 取得所有的app
def get_all_app()

  if $appDataList != nil
    # puts "已存在舊有 app 設定列表, 不獲取新的"
    return $appDataList
  end

  app_url = "#{$used_host}/app_setting"

  body = URI.encode_www_form({
    :perpage => 10000,
    :page => 1
  })

  url = URI.parse(app_url)
  req = Net::HTTP::Post.new(url.to_s, initheader = {$headerKey => $xingHeaderValue})
  req.body = body
  Net::HTTP.start(url.host, url.port, :use_ssl => true) do |http|
    response = http.request(req)
    repBody = response.body
    data = JSON.parse(repBody)["data"]
    $appDataList = data.map { |app_data| 
      topic = app_data['topic_id']
      topicId = nil
      topicAppKey = nil
      topicSecret = nil
      topicPackage = nil
      if topic != nil
        topicId = topic['topic']
        topicAppKey = topic['app_key']
        topicSecret = topic['app_secret']
        topicPackage = topic['package_name']
      end
      hash = {
        'id' => app_data['id'],
        'code' => app_data['code'],
        'name' => app_data['name'],
        'category' => app_data['category'],
        'mobile_device' => app_data['mobile_device'],
        'redirect_switch' => app_data['redirect_switch'],
        'redirect_url' => app_data['redirect_url'],
        'update_switch' => app_data['update_switch'],
        'update_url' => app_data['update_url'],
        'update_content' => app_data['update_content'],
        'qq_id' => app_data['qq_id'],
        'wechat_id' => app_data['wechat_id'],
        'customer_service' => app_data['customer_service'],
        'status' => app_data['status'],
        'topic_id[topic]' => topicId,
        'topic_id[app_key]' => topicAppKey,
        'topic_id[app_secret]' => topicSecret,
        'topic_id[package_name]' => topicPackage,
        'push_path' => app_data['push_path'],
        'app_version' => app_data['app_version'],
        'app_url' => app_data['app_url'],
      }
      # puts "device = #{app_data['mobile_device']}"
      hash
    }
    # $appDataList.each { |hash|
    #   hash.each { |key, value|
    #     puts "打印 key = #{key}, value = #{value}"
    #   }
    # }
  end
  $appDataList
end

def get_app_data(code)
  findApp = get_all_app().find { |data| 
    data['code'] == code
  }
  # puts "第一階段打印"
  # findApp.each { |key, value|
  #   puts "k = #{key}, v = #{value}"
  # }
  findApp
end

def get_flavor_name(flavor)
  name = ""
  if flavor == 'oppo'
    name = ' - OPPO'
  elsif flavor == 'qq'
    name = ' - 应用宝'
  elsif flavor == '360'
    name = ' - 360'
  elsif flavor == 'vivo'
    name = ' - VIVO'
  elsif flavor == 'xiaomi'
    name = ' - 小米'
  elsif flavor == 'huawei'
    name = ' - 华为'
  elsif flavor == 'nduo'
    name = ' - N多'
  elsif flavor == 'gionee'
    name = ' - 金立'
  elsif flavor == 'wang'
    name = ' - 豌豆荚'
  elsif flavor == 'sogou'
    name = ' - 搜狗'
  elsif flavor == 'mumayi'
    name = ' - 木蚂蚁'
  elsif flavor == 'smart'
    name = ' - 锤子'
  elsif flavor == 'lenovo'
    name = ' - 联想'
  elsif flavor == 'meizu'
    name = ' - 魅族'
  elsif flavor == 'baidu'
    name = ' - 百度'
  elsif flavor == 'anzhi'
    name = ' - 安智'
  end
  name
end

# 建立 app, 回傳創建資訊
def create_app(code, name, status, xiaomi, umeng)
  craete_url = "#{$used_host}/app_setting/data_manipulation"

  device = "ios"
  if code.to_s.start_with? "N-"
    device = "android"
  end

  bodyHash = {
    :code => code,
    :name => name,
    :category => 'futures',
    :mobile_device => device,
    :redirect_switch => 'off',
    :update_switch => 'off',
    :status => status,
  }

  if !umeng.to_s.empty? && appData['mobile_device'] == 'ios'
    bodyHash['push_path'] = 'umeng'

    # 加入友盟推送
    umengSplit = umeng.split(',').map{ |s| s.strip }

    bodyHash['topic_id[app_key]'] = umengSplit[0]
    bodyHash['topic_id[app_secret]'] = umengSplit[1]
  elsif !xiaomi.to_s.empty? && appData['mobile_device'] == 'android'
    bodyHash['push_path'] = 'xiaomi'

    # 加入友盟推送
    xiaomiSplit = xiaomi.split(',').map{ |s| s.strip }

    bodyHash['topic_id[app_secret]'] = xiaomiSplit[0]
    bodyHash['topic_id[package_name]'] = xiaomiSplit[1]
  else
    # 加入 aws 推送
    bodyHash['push_path'] = 'aws'
    if $is_debug
      bodyHash['topic_id[topic]'] = "arn:aws:sns:ap-southeast-1:748166261271:#{code}-Dev"
    else
      bodyHash['topic_id[topic]'] = "arn:aws:sns:ap-southeast-1:748166261271:#{code}"
    end
  end
  body = URI.encode_www_form(bodyHash)
  url = URI.parse(craete_url)
  req = Net::HTTP::Post.new(url.to_s, initheader = {$headerKey => $xingHeaderValue})
  req.body = body
  Net::HTTP.start(url.host, url.port, :use_ssl => true) do |http|
    response = http.request(req)
    repBody = response.body
    code = JSON.parse(repBody)["code"]
    isSuccess = code == 200 || code == 201
    if isSuccess
      puts "create ios app success: #{code} - #{name}"
    else
      puts "create ios app fail: #{repBody}"
    end
  end
end

# 更新 app
def update_app(code, new_name, new_status, new_xiaomi, new_umeng, new_qq, new_wechat, new_customer, new_redirect_switch, new_redirect_url)
  appData = get_app_data(code)

  if appData.nil?
    puts "找不到對應的 app code - #{code}"
    return
  end

  if !new_name.to_s.empty?
    appData['name'] = new_name
  end
  if new_status != nil
    appData['status'] = new_status
  end

  if new_qq != nil
    appData['qq_id'] = new_qq
  end

  if new_wechat != nil
    appData['wechat_id'] = new_wechat
  end

  if new_customer != nil
    appData['customer_service'] = new_customer
  end

  if new_redirect_url != nil
    appData['redirect_url'] = [new_redirect_url]
  end

  if new_redirect_switch != nil
    appData['redirect_switch'] = new_redirect_switch
  end

  if !new_umeng.to_s.empty? && appData['mobile_device'] == 'ios'
    appData['push_path'] = 'umeng'

    # 加入友盟推送
    umengSplit = new_umeng.split(',').map{ |s| s.strip }

    appData['topic_id[app_key]'] = umengSplit[0]
    appData['topic_id[app_secret]'] = umengSplit[1]
  elsif !new_xiaomi.to_s.empty? && appData['mobile_device'] == 'android'
    appData['push_path'] = 'xiaomi'

    # 加入友盟推送
    xiaomiSplit = new_xiaomi.split(',').map{ |s| s.strip }

    appData['topic_id[app_secret]'] = xiaomiSplit[0]
    appData['topic_id[package_name]'] = xiaomiSplit[1]
  elsif appData['push_path'] == 'aws'
    # 加入 aws 推送
    appData['push_path'] = 'aws'
    if $is_debug
      appData['topic_id[topic]'] = "arn:aws:sns:ap-southeast-1:748166261271:#{code}-Dev"
    else
      appData['topic_id[topic]'] = "arn:aws:sns:ap-southeast-1:748166261271:#{code}"
    end
  end

  if appData['redirect_url'] != nil
    appData['redirect_url'].each_with_index { |url, index|
      appData["redirect_url[#{index}]"] = url
    }
    appData.delete('redirect_url')
  end

  # puts "打印出需要更改的資料"
  # appData.compact.each { |key, value|
  #   puts "k = #{key}, v = #{value}"
  # }
  modify_url = "#{$used_host}/app_setting/data_manipulation"

  body = URI.encode_www_form(appData.compact)
  url = URI.parse(modify_url)
  req = Net::HTTP::Put.new(url.to_s, initheader = {$headerKey => $xingHeaderValue})
  req.body = body
  Net::HTTP.start(url.host, url.port, :use_ssl => true) do |http|
    response = http.request(req)
    repBody = response.body
    code = JSON.parse(repBody)["code"]
    isSuccess = code == 200 || code == 201
    if isSuccess
      puts "update ios app success: #{code} - #{appData['name']}"
    else
      puts "update ios app fail: #{repBody}"
    end
  end
end

# 將 index 轉為對應的 state
def change_step_to_state(step)
  status = nil
  if step == '1'
    status = 'unpublished'
  elsif step == '2'
    status = 'verifying'
  elsif step == '3'
    status = 'published'
  elsif step == '4'
    status = 'removed'
  end
  status
end

def change_step_to_desc(step)
  desc = nil
  if step == '1'
    desc = '未上架'
  elsif step == '2'
    desc = '審核中'
  elsif step == '3'
    desc = '已上架'
  elsif step == '4'
    desc = '已下架'
  end
  desc
end

# 檢測渠道跟平台, android 要依照渠道設置appName
def app_name_setting(code, name)

  device = "ios"
  if code.to_s.start_with? "N-"
    device = "android"
  end

  if name.to_s.empty?
    name = code
  end

  # 假如是 android, 判斷尾端的 code分配渠道
  if device == 'android'
    flavor = ''
    code.gsub(/(?<=-)\w+?$/) { |f|
      flavor = f
      f
    }
    flavorName = get_flavor_name(flavor)
    if flavorName.empty?
      puts "app code parse fail - flavor name not found - #{code}"
      return name
    end

    name = name + flavorName
  end
  name
end

# 自動生成環境檔
def create_env(env_path)
  if File.exist?(env_path)
    return
  end
  text = %{code            =
name            = --
method          = 1
release         = on
xiaomi          = --
umeng           = --
redirect_switch = --
redirect_url    = --
qq              = --
wechat          = --
customer        = --
state           = --

# 說明
#
# method 腳本目的, 對應
# 1 => 建立 app (默認)
# 2 => 更新 app
# 3 => 推播測試

# redirect_switch 對應 - on, off
# release 是否為正式環境, 對應 - on, off

# umeng 友盟推送, 格式 key,secret
# xiaomi 小米推送, 格式 app_secret,package_name

# state 對應
# 1 => 未上架
# 2 => 審核中
# 3 => 已上架
# 4 => 已下架}
  File.write(env_path, text)
end

def print_help()
  puts "命令格式"
  puts "  -help (命令幫助)"
  puts "  -update (更新app)"
  puts "  -release (正式機, 默認測試機)"
  puts "  -push_test (推播測試)"
  puts "  -umeng=XXX (友盟推送, 格式為 key,secret - 默認使用aws )"
  puts "  -xiaomi=XXX (小米推送, 格式為 app_secret,package_name - 默認使用aws )"
  puts "  -code=XXX (App Code)"
  puts "  -name=XXX (App 名稱)"
  puts "  -redirect_switch=XXX (跳轉開關 on, off)"
  puts "  -redirect_url=XXX (跳轉url)"
  puts "  -qq=XXX (QQ)"
  puts "  -wechat=XXX (WeChat)"
  puts "  -customer=XXX (客服)"
  puts "  -env=XXX (環境變數位置)"
  puts "  -state=X (狀態 1, 2, 3, 4)"
  puts "         1 => 未上架"
  puts "         2 => 審核中"
  puts "         3 => 已上架"
  puts "         4 => 已下架"
end

def print_app(code)
  appData = get_app_data(code)
  if appData.nil?
    puts "code #{code} not exist at backend"
  else
    appData.each { |key, value|
      puts "#{key} = #{value}"
    }
  end

end

args = parse_argv()

if args.length == 0 || args.key?('h') || args.key?('help')
  print_help()
  return
end

appCode = args['code']
appName = args['name']


if appCode.to_s.empty?
  puts "錯誤 - app code 不得為空"
  print_help()
  return
end

if args.key?('release')
  puts "環境 - 正式"
  sync_environment(true)
else
  puts "環境 - 測試"
  sync_environment(false)
end

if args.length == 1 && !appCode.to_s.empty?
  print_app(appCode)
  return
end

if args.key?('push_test')
  puts "測試推送 #{appCode}"
  push_test(appCode)
  puts "測試推送結束"
elsif args.key?('update')
  puts "更新 app 資訊"
  appStatus = change_step_to_state(args['state'])

  # puts "更新 app 資訊不需要帶入默認名稱"
  # appName = app_name_setting(appCode, appName)
  puts "search appCode = #{appCode}, appName = #{appName}, state: #{change_step_to_desc(args['s'])}"
  # 更新 app
  # code, new_name, new_status, new_xiaomi, new_umeng, new_qq, new_wechat, new_customer, new_redirect_switch, new_redirect_url
  update_app(appCode, appName, appStatus, args['xiaomi'], args['umeng'], args['qq'], args['wechat'], args['customer'], args['redirect_switch'], args['redirect_url'])
  puts "更新 app 資訊結束"
else 
  # 默認建立 app
  puts "建立 app"
  appStatus = change_step_to_state('1')
  appName = app_name_setting(appCode, appName)
  puts "create appCode = #{appCode}, appName = #{appName}"
  create_app(appCode, appName, appStatus, nil, nil)
  puts "建立 app 結束"
end


puts ""












































