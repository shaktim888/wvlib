set -x
work_path=$(cd `dirname $0`; pwd)

rm -rf $work_path/../../wvlib_temp
cp -r -f $work_path/../../wvlib $work_path/../../wvlib_temp
cd $work_path/../../wvlib

git filter-branch --force --index-filter 'git rm --cached -r --ignore-unmatch wvLC_Time' --prune-empty --tag-name-filter cat -- --all
git filter-branch --force --index-filter 'git rm --cached -r --ignore-unmatch wvLC_NoWV' --prune-empty --tag-name-filter cat -- --all
git filter-branch --force --index-filter 'git rm --cached -r --ignore-unmatch wvLC_JG' --prune-empty --tag-name-filter cat -- --all
git filter-branch --force --index-filter 'git rm --cached -r --ignore-unmatch wvLC' --prune-empty --tag-name-filter cat -- --all

git push origin master:master --tags --force

rm -rf $work_path/../../wvlib/wvLC_Time
rm -rf $work_path/../../wvlib/wvLC_NoWV
rm -rf $work_path/../../wvlib/wvLC_JG
rm -rf $work_path/../../wvlib/wvLC

cp -r -f $work_path/../../wvlib_temp/wvLC_Time $work_path/../../wvlib/wvLC_Time
cp -r -f $work_path/../../wvlib_temp/wvLC_NoWV $work_path/../../wvlib/wvLC_NoWV
cp -r -f $work_path/../../wvlib_temp/wvLC_JG $work_path/../../wvlib/wvLC_JG
cp -r -f $work_path/../../wvlib_temp/wvLC $work_path/../../wvlib/wvLC

git add -A && git commit -m 'autoClean' && git push origin master
