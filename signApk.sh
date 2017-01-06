#!/bin/bash

# Need a meta.txt which including the sha1 of android sign certificate if you want
# to check the apk belong to which Android version(Android 7.0 ro 5.0)。
# It doen't influnce the apk sign funtion

Projects=(ProjectsName1 ProjectsName2 ProjectsName3)
# The Path of Android Source Code at native
Projects_Path=('/home/../../'
               '/home/../../'
               '/home/../../')

signNow(){
	apkName=${2##*/}
	dirPath=~/temp_`date +%Y-%m-%d`
	if [ -d $dirPath ]; then
		echo ""
	else
		mkdir $dirPath;
	fi
	# java -jar out/host/linux-x86/framework/signapk.jar -w build/target/product/security/$1.x509.pem build/target/product/security/$1.pk8 $2 $dirPath/$apkName
	echo "在下列项目中选择一个进行签名："
	for item in ${Projects[*]}
	do
    		echo "     $item"
	done 
	read project_choose

	i=0;
	for pro in ${Projects[*]}
	do
    		if [ $pro == ${project_choose} ]; then
    			break
    		elif [ $pro != ${project_choose} ] && [ "$((++i))" = "${#Projects[@]}" ]; then
    			echo  "请输入正确的项目名称!";
    			exit 1
    		fi
	done 

	java -jar $Projects_Path/out/host/linux-x86/framework/signapk.jar -w $Projects_Pathbuild/target/product/security/$1.x509.pem $Projects_Pathbuild/target/product/security/$1.pk8 $2 $dirPath/$apkName
	 # java -jar `pwd`/keystore/$project_choose/signapk.jar -w `pwd`/keystore/$project_choose/security/$1.x509.pem `pwd`/keystore/$project_choose/security/$1.pk8 $2 $dirPath/$apkName
	if [ $? == 0 ]; then
		echo "签名成功，新签名的apk生成路径：$dirPath"
	else
		echo "签名失败"
	fi
}

getSignType(){
	orignSha=`keytool -printcert -file  $1 |grep SHA1:`;
	orignShaValue=${orignSha##*SHA1: };
	# echo $orignShaValue
	# echo `grep -o $orignShaValue ~/meta.txt`
	echo "签名类型"
	echo `cat ~/meta.txt |grep $orignShaValue`
	if [ $? == 0 ]; then
		# the key exist in meta.txt
		return 0;
	fi
}

while getopts :p:t:s: opt; 
do
	case $opt in
		p )
		rsaPath=$OPTARG;
		getSignType $rsaPath;
		# echo "RSAPath  $OPTARG"
			;;
		t )
		signType=$OPTARG
		# echo "signType  $OPTARG ";
		
			;;
		s )
		apkPath=$OPTARG;
		signNow $signType $apkPath
			;;
		\? )
		echo "apk签名改为XX版本，需要到本地相应项目根目录下执行该脚本";
		echo "相应项目需要事前成功编译过frameworks";
		echo "invalid options :`basename $0` [-p RSA_File_Path] [-t SignType][-s apkPath]"
			;;
		:) 
		echo "apk签名改为XX版本，需要到本地相应项目根目录下执行该脚本";
		echo "相应项目需要事前成功编译过frameworks";
		echo "invalid options :`basename $0` [-p RSA_File_Path] [-t SignType][-s apkPath]"
			;;
	esac
done

