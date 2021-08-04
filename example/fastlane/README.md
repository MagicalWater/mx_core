fastlane documentation
================
# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```
xcode-select --install
```

Install _fastlane_ using
```
[sudo] gem install fastlane -NV
```
or alternatively using `brew install fastlane`

# Available Actions
### check_version
```
fastlane check_version
```
檢查腳本版本
### update_script
```
fastlane update_script
```
更新 腳本, 並且安裝必要套件, 可接受參數 verion - 指定版本, clear - 本地檔案完整清除
### construct_project
```
fastlane construct_project
```
初始構建專案
### auto_generate
```
fastlane auto_generate
```
自動生成 Route(三大組件) / assets / json, 最後會自動執行 build_runner
### build_runner
```
fastlane build_runner
```
封裝好快速執行 build_runner build的指令
### build_runner_clean
```
fastlane build_runner_clean
```
封裝好快速執行 build_runner clean的指令

----

## iOS
### ios auto_match_cert
```
fastlane ios auto_match_cert
```
自動證書管理
### ios resign_ipa
```
fastlane ios resign_ipa
```
重新簽名ipa(用於超級簽)
### ios register_debug_device
```
fastlane ios register_debug_device
```
註冊測試設備 ipa
### ios export_ipa
```
fastlane ios export_ipa
```
輸出ipa
### ios update_app
```
fastlane ios update_app
```
更新 ios 包名/app名稱
### ios create_itunes_app
```
fastlane ios create_itunes_app
```
在 iTunes Connect 以及 AppDeveloper 建立 App, 並且註冊測試裝置
### ios generate_push_cert
```
fastlane ios generate_push_cert
```
創建/取得 推送證書
### ios sign_auto
```
fastlane ios sign_auto
```
指定開發者帳號, 開啟自動簽名
### ios upload_appstore
```
fastlane ios upload_appstore
```
上傳 ipa 至 appstore
### ios export_account_info
```
fastlane ios export_account_info
```
輸出帳號的開發者相關資訊

----

## Android
### android update_app
```
fastlane android update_app
```
更新 android 包名/app名稱
### android update_key
```
fastlane android update_key
```
設置 key 資訊

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.
More information about fastlane can be found on [fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
