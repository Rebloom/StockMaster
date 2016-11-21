#!/bin/sh
#脚本说明：该脚本批量编译生成ipa，并自动修改info.plist中package_id字段
#使用说明：参数设置package_id的起止范围，如，“sh package.sh 100 200”

#设置渠道号起始范围
PACKAGEID_BEGIN=0
PACKAGEID_END=0
if [ "$1" != "" ];
then PACKAGEID_BEGIN=$1
else echo "Set begin package_id"
exit
fi

if [ "$2" != "" ];
then PACKAGEID_END=$2
else echo "Set end package_id"
exit
fi
#设置根目录为脚本所在目录
CONFIG_ROOT_PATH=$(cd "$(dirname "$0")"; pwd)
cd $CONFIG_ROOT_PATH
mkdir -p $CONFIG_ROOT_PATH/ipa
#从plist读取应用版本号
APP_VERSION=$(/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" "./StockMaster/StockMaster-Info.plist")
#修改plist，设置CHANNELID为invite
/usr/libexec/PlistBuddy -c "set :CHANNELID invite" "./StockMaster/StockMaster-Info.plist"

#删除build目录
rm -rf "./build/"
#清除
xcodebuild -target StockMaster clean
#初始编译，主要是为了触发项目Run Script，如自动修改版本号等
xcodebuild -target StockMaster -configuration Distribution -sdk iphoneos build

#遍历渠道，生成ipa
for ((i=$PACKAGEID_BEGIN;i<=PACKAGEID_END;i++))
do
#修改plist
/usr/libexec/PlistBuddy -c "set :package_id $i" "./StockMaster/StockMaster-Info.plist"
#编译
xcodebuild -target StockMaster -configuration Distribution -sdk iphoneos build
#生成ipa
xcrun -sdk iphoneos PackageApplication -v "./build/Release-iphoneos/StockMaster.app" -o "$CONFIG_ROOT_PATH/ipa/zhangzhang_v"$APP_VERSION"_$i.ipa"
done

#删除build目录
rm -rf "./build/"