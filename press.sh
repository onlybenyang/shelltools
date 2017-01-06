#! /bin/bash

if [ "$1" = "-d" ] ; then
	FileName=${2%/};
	FileName=${FileName##*/}
else
	FileName=${3%/};
	FileName=${FileName##*/}
fi

DirFileName=${FileName%.*}
FileType=${FileName##*.}

if [  -d $3 ] ;  then
 	DirFile=${FileName%.$2*}"."$2
 else
 	DirFile=$FileName
fi

## if compress tools not exist ,download and install
function checkAndDownloadTool(){
	which $FileType;
	if [ $FileType=="rar" -a "$1" = "-d" -a $?!=0 ]; then
		echo "no unrar, will install unrar";
		sudo apt-get install unrar ;
	fi

	which $FileType;
	if [ $? == 0 ]; then
		return 0
	else
		echo "no $1 tool, will install $1";
		sudo apt-get install $1
	fi
}


function main(){
	checkAndDownloadTool $1;

	case $1 in
	-d )
		case $2 in
			*.zip )
			if [ $3 ]; then
				unzip -r -P $3 $DirFile $2;
			else	
				unzip -r $DirFile $2  
			fi
			;;
			*.tar )
			tar xvf $2;;
			*.rar )
			unrar x  $2;;
			*.deb )
			mkdir $DirFileName ;
			dpkg-deb --fsys-tarfile $2 | tar vxfC -  $DirFileName ;;
		esac;;
	-c )
		case $2 in
			zip )
			if [ $4 ]; then
				zip -r -P $4 $DirFile $3;
			else	
				zip -r $DirFile $3  
			fi
			;;
			tar )
			tar -cvf  $DirFile $3 ;;
			rar )
			rar  a  $DirFile $3 ;;
			deb )
			dpkg -b  $3 $DirFile ;;
		esac;;
	--help|-h|* )
		echo "press.sh now support .zip/.deb/.tar/.rar file to current director and decompress them"
		echo "Encrypt and Decrypt zip file"
		echo "get more info with press.sh [--help]"
		echo "press.sh -d [FilePath] [PassWord]:  decompress the file to the cerrent path";
		echo "press.sh -c  [FileType] [FilePath] [PassWord]:  compress the file/folders to FileType on the cerrent path";
esac
}

main $1 $2 $3 $4
