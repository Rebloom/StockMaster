#!/bin/sh
#脚本说明：该脚本批量编译生成ipa，并自动修改info.plist中CHANNELID渠道字段
#使用说明：直接运行不需要添加参数，如“sh channel.sh”

#设置根目录为脚本所在目录
CONFIG_ROOT_PATH=$(cd "$(dirname "$0")"; pwd)
cd $CONFIG_ROOT_PATH
mkdir -p $CONFIG_ROOT_PATH/ipa
#从plist读取应用版本号
APP_VERSION=$(/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" "./StockMaster/StockMaster-Info.plist")
#修改plist，设置package_id为0
/usr/libexec/PlistBuddy -c "set :package_id 0" "./StockMaster/StockMaster-Info.plist"

#循环数组
CHANNELID=("0" "1" "2" "3" "4" "5" "1002" "1003" "1004" "1005" "2001" "2002" "10010" "360" "40001" "40002" "40003" "40004" "40005" "40006" "40007" "40008" "40009" "40010" "40011" "40012" "40013" "40014" "40015" "40016" "40017" "40018" "40019" "40020" "50001" "50002" "50003" "50004" "50005" "50006" "50007" "50008" "50009" "50010" "50011" "50012" "50013" "50014" "50015" "50016" "50017" "50018" "50019" "50020" "50021" "50022" "50023" "50024" "50025" "50026" "50027" "50028" "50029" "50030" "50031" "50032" "50033" "50034" "50035" "50036" "50037" "50038" "50039" "50040" "50041" "50042" "50043" "50044" "50045" "50046" "50047" "50048" "50049" "50050" "fromweixin" "91" "kuaiyong" "tongbutui" "itools" "gaoqu" "pingguoyuan" "xy" "wangyi")

#删除build目录
rm -rf "./build/"
#清除
xcodebuild -target StockMaster clean
#初始编译，主要是为了触发项目Run Script，如自动修改版本号等
xcodebuild -target StockMaster -configuration Distribution -sdk iphoneos build

for ((i=0;i<${#CHANNELID[@]};i++))
do
#修改plist
/usr/libexec/PlistBuddy -c "set :CHANNELID ${CHANNELID[$i]}" "./StockMaster/StockMaster-Info.plist"
#编译
xcodebuild -target StockMaster -configuration Distribution -sdk iphoneos build
#生成ipa
xcrun -sdk iphoneos PackageApplication -v "./build/Release-iphoneos/StockMaster.app" -o "$CONFIG_ROOT_PATH/ipa/StockMaster_${CHANNELID[$i]}.ipa"
done

#删除build目录
rm -rf "./build/"