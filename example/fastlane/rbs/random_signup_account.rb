require 'net/http'
require 'json'

def getRandomWord()
  o = [('a'..'z'), ('A'..'Z')].map(&:to_a).flatten
  string = (0...4).map { o[rand(o.length)] }.join
  string[0] = string[0].upcase
  string
end

def create_account()

  release_toekn = "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsImp0aSI6IjdlMmM2MDc2ZWI2MTk5ZWNkMmE1ZTM4Zjg0OTkxODk1MjBhODkxOTA4MjdhNWZhODZhOThhZDU5MDE3NDIyY2RhM2VmN2RlYWFlNDdmYzliIn0.eyJhdWQiOiJjMDllYmVkNC00YjZmLTQwNjItOTNiNS1iODZjN2M0MTNkODkiLCJqdGkiOiI3ZTJjNjA3NmViNjE5OWVjZDJhNWUzOGY4NDk5MTg5NTIwYTg5MTkwODI3YTVmYTg2YTk4YWQ1OTAxNzQyMmNkYTNlZjdkZWFhZTQ3ZmM5YiIsImlhdCI6MTUzOTg1NzE5MywibmJmIjoxNTM5ODU3MTkzLCJleHAiOjE1NzEzOTMxOTMsInN1YiI6IjE1Iiwic2NvcGVzIjpbXX0.XWuN4PmqC521Ui55oY8h_-xzycoVENQVmBuK6JRUQCuCT1J6kr-x22ZWouu6qYC3j1O-rZQxr02h3P0NqclGpfvzPfJeP1Q4VYEqTZ7u_1FVAnGI5zlU9ZenmEM1d82cWvNwWOoPi9XAk7mEaHxODZjxOYH_y49oHwl5MgP_hkeSeOJDnXXF8yU-e5cA-22N99k9TzkSiz6B0c3me_IU1O1TgJc6pHyHhSnhWVHKaAE9SEX3j7m9MO1asCieakeCjSUfF78MablsqA4O6YtPKhaFZmwE4qBuxnwmt6Z8zbtPsKbI4NuoakqD9HLDl0XjwtuW31XVN-2VYhe--J6kzqGiTMfQZ2ZIdqR98-9Hd--qsWqexGxQtQnA9U-y74IJp28l_E5V-_Ms8jtj7x-MLcf6epHrybejhIyLoUQ2HpbE3r36MDq1v4fqTpHY6xo28joPSP_rCRT9n3RhEuhyYx8UHLRuYOq4ed2ZOnHNtWzTT-ugJ3pf-L7OsVBD78jxoznHmUANrfRqSddC-Ev52yNdMnfEhi_cbN8lMFsRp8FguyB3mLWdGbCqAm1kp0tqvY9T-_AsIn4584z7i9agSqWjLfgF6Ev5x_NRZGS8_iiygjrw9upA2TRuIVHUMmWH85dbjokSU8Bu4BvlNLu7aaUshDDgtahHLB-QzvPICu0"
  debug_toekn = "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsImp0aSI6IjhlZDM1ODFmODE2NWNhM2U4NmIwZWRiZDM3ZTI3MmYxZDcwN2ViNGI5YzBkZGYwYTAwOWM4Yjg4OTZkOGM0NTg2M2E3Y2NhNjRlZDBmNmU1In0.eyJhdWQiOiI1ZWU3NGI4Mi04ZTNlLTQ4NzEtYTBhZi01YjJlMGU0NjQ1ZWIiLCJqdGkiOiI4ZWQzNTgxZjgxNjVjYTNlODZiMGVkYmQzN2UyNzJmMWQ3MDdlYjRiOWMwZGRmMGEwMDljOGI4ODk2ZDhjNDU4NjNhN2NjYTY0ZWQwZjZlNSIsImlhdCI6MTUzOTg1NzQ0OCwibmJmIjoxNTM5ODU3NDQ4LCJleHAiOjE1NzEzOTM0NDgsInN1YiI6IjEzIiwic2NvcGVzIjpbXX0.GunbRg5gWeMK1WOaI8RUVezf63y2-5uY0hLUvMaSrDoJBgq8CW5iKA9gOq9q3zFLlstokOOmeOlBqN_U6Z3za1_cadlONc_6-VNSBLVg8CAFAEMbPApq-MR5bTsYfIJnSgVY3Lea54-DZP8UAQ-zV8VzeCUlJ04ipNtlAsg4cDc6yo15g0_8NsgeK3hb5RacVtbeVhj6UOd0ptgq5GXRFaR2XN-qo26JGjsQKus_f5T15Nd5BavMSytTpy2mwk3NCUYX3kxICnHlIPCZuAMN3unKXkxYuWc33a8700QlvR151UJko6AzwpWhBiq-VKDLfFYK9S_3M-_kkhgmQOFZpaJfMeYo9OZzNM9FdELtn2ZBao2RQZJU_asRY26V2LWM39SgJxUG2XXY8Cog5yUCeO1mVFfz5NamQwLtVP0d0bZZYEMSAZA2b2NcIWIw2nHe8Bly4IrR9maTsR70T_4i8FQqKbNSwEjWqYP065Lz1-Qb7v9XB6DtY4plg1ZW9K_95FCJ7pulPQtB4BP2CIirUeXqwuZ_nXag9nujZ37CxOuSNGXJsx1Bd7PstzViRVAx9AkFpzmgU454Uv4xrCuGKaKjczV6UmP34nCrGAvZ5w1XtURgtmj4L4Rz7AfS81PgIf_bnFQvZwubx0BqGMGN-O47eLc1T8ybsXQkeURBTnU"

  release_url = "https://api.apps99.cc/account/member/sign_up"
  debug_url = "http://api.appcms.xing99.cc/account/member/sign_up"

  used_token = release_toekn
  used_url = release_url

  randomAccount = "User#{getRandomWord}"
  # randomAccount = "cccc"
  fixPassword = "123456"
  
  headerKey = "Authorization"
  headerValue = "Bearer #{used_token}"
  
  header = {headerKey: headerValue}
  
  body = URI.encode_www_form({
  	:account => randomAccount,
  	:password => fixPassword,
  	:confirm_password => fixPassword, 
  	:display_name => randomAccount
  })

  # puts "打印出: #{body.to_json}"
  
  url = URI.parse(used_url)
  req = Net::HTTP::Post.new(url.to_s, initheader = {headerKey => headerValue})
  req.body = body
  Net::HTTP.start(url.host, url.port, :use_ssl => true) do |http|
    response = http.request(req)
    repBody = response.body
    code = JSON.parse(repBody)["code"]
    success = code == 200 || code == 201
    tooMany = repBody.include? "Too Many Attempts"
    hash = {
    	'acc' => randomAccount,
    	'pwd' => fixPassword,
    	'response' => repBody,
    	'code' => code,
    	'success' => success,
    	'tooMany' => tooMany
    }
  end

end

# 最多重新創建幾次
retryCount = 5

# 當前次數
nowRetry = 0

responseHash = ""

while nowRetry < retryCount do
  responseHash = create_account
  nowRetry += 1
  break if responseHash['success'] || responseHash['tooMany']
end

if responseHash['success']
  puts "帳號: #{responseHash['acc']}"
  puts "密碼: #{responseHash['pwd']}"
elsif responseHash['tooMany'] 
  puts "產生太多次了, 請稍後再試"
else
  puts "發生錯誤 - 聯繫阿水"
  puts "打印錯誤信息"
  puts responseHash
end


