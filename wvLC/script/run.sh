#!/bin/
set -x
work_path=$(cd `dirname $0`; pwd)
rm -rf $work_path/../../wvLC_temp
cp -r -f $work_path/../../wvLC $work_path/../../wvLC_temp
# echo $work_path
lc_work_path=$work_path/../../wvLC_temp
lib_work_path=$work_path/../../wvlib

$work_path/HYCodeScan.app/Contents/MacOS/HYCodeScan --redefine -i $lc_work_path/wvLC/Classes/cocock.h -i $lc_work_path/wvLC/Classes/cocockCplus.h -i $lc_work_path/wvLC/Classes/realprefix.pch -i $lib_work_path/prefix.pch
$work_path/HYCodeScan.app/Contents/MacOS/HYCodeScan --xcode --config $work_path/appConfig.json -p $lc_work_path/Example/Pods/Pods.xcodeproj

cp -rf $lc_work_path/wvLC/Classes/cocock.h $lc_work_path/Example/Pods/Headers/Public/notho/
cp -rf $lc_work_path/wvLC/Classes/cocock.h $lc_work_path/Example/Pods/Headers/Public/notho_jg/
cp -rf $lc_work_path/wvLC/Classes/cocock.h $lc_work_path/Example/Pods/Headers/Public/notho_nowv/
cp -rf $lc_work_path/wvLC/Classes/cocockCplus.h $lc_work_path/Example/Pods/Headers/Public/notho/
cp -rf $lc_work_path/wvLC/Classes/cocockCplus.h $lc_work_path/Example/Pods/Headers/Public/notho_jg/
cp -rf $lc_work_path/wvLC/Classes/cocockCplus.h $lc_work_path/Example/Pods/Headers/Public/notho_nowv/

xcodebuild -workspace $lc_work_path/Example/wvLC.xcworkspace -scheme wvLC_JG -sdk iphonesimulator -configuration Release build -jobs 8
xcodebuild -workspace $lc_work_path/Example/wvLC.xcworkspace -scheme wvLC_JG -sdk iphoneos -configuration Release build -jobs 8
xcodebuild -workspace $lc_work_path/Example/wvLC.xcworkspace -scheme wvLC -sdk iphonesimulator -configuration Release build -jobs 8
xcodebuild -workspace $lc_work_path/Example/wvLC.xcworkspace -scheme wvLC -sdk iphoneos -configuration Release build -jobs 8
xcodebuild -workspace $lc_work_path/Example/wvLC.xcworkspace -scheme wvLC_time -sdk iphonesimulator -configuration Release build -jobs 8
xcodebuild -workspace $lc_work_path/Example/wvLC.xcworkspace -scheme wvLC_time -sdk iphoneos -configuration Release build -jobs 8
xcodebuild -workspace $lc_work_path/Example/wvLC.xcworkspace -scheme wvLC_NoWV -sdk iphonesimulator -configuration Release build -jobs 8
xcodebuild -workspace $lc_work_path/Example/wvLC.xcworkspace -scheme wvLC_NoWV -sdk iphoneos -configuration Release build -jobs 8

sh $lib_work_path/updateVersion.sh

productFolder="Example/Pods/Products/notho"
for i in `ls $lc_work_path/$productFolder`; do
cp -rf $lc_work_path/$productFolder/$i $lib_work_path/wvLC/
done

productFolder="Example/Pods/Products/notho_jg"
for i in `ls $lc_work_path/$productFolder`; do
cp -rf $lc_work_path/$productFolder/$i $lib_work_path/wvLC_JG/
done

productFolder="Example/Pods/Products/notho_time"
for i in `ls $lc_work_path/$productFolder`; do
cp -rf $lc_work_path/$productFolder/$i $lib_work_path/wvLC_Time/
done

productFolder="Example/Pods/Products/notho_nowv"
for i in `ls $lc_work_path/$productFolder`; do
cp -rf $lc_work_path/$productFolder/$i $lib_work_path/wvLC_NoWV/
done

cp -rf $lc_work_path/wvLC/Classes/cocock.h $lib_work_path/wvLC/
cp -rf $lc_work_path/wvLC/Classes/cocock.h $lib_work_path/wvLC_JG/
cp -rf $lc_work_path/wvLC/Classes/cocock.h $lib_work_path/wvLC_Time/
cp -rf $lc_work_path/wvLC/Classes/cocock.h $lib_work_path/wvLC_NoWV/
cp -rf $lc_work_path/wvLC/Classes/cocockCplus.h $lib_work_path/wvLC/
cp -rf $lc_work_path/wvLC/Classes/cocockCplus.h $lib_work_path/wvLC_JG/
cp -rf $lc_work_path/wvLC/Classes/cocockCplus.h $lib_work_path/wvLC_Time/
cp -rf $lc_work_path/wvLC/Classes/cocockCplus.h $lib_work_path/wvLC_NoWV/

function comit()
{
	cd $lib_work_path
	git add -u && git commit -m 'autobuild' && git push origin master
}

comit

sh $work_path/clean.sh
