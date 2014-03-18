#!/bin/bash
WD=$PWD
#SUBTITLECREATOR_DIR=`cygpath -u 'C:\Program Files (x86)\SubtitleCreator'`
FFMPEG=/usr/ffmpeg/bin/ffmpeg.exe
#LOG_LEVEL=-loglevel 3

function writeAssHeader
{
cat <<SETVAR | unix2dos > $1
[Script Info]
ScriptType: v4.00+

[V4+ Styles]
Format: Name, Fontname, Fontsize, PrimaryColour, SecondaryColour, OutlineColour, BackColour, Bold, Italic, Underline, BorderStyle, Outline, Shadow, Alignment, MarginL, MarginR, MarginV, AlphaLevel, Encoding
Style: Default,Arial,24,&Hffffff,&Hffffff,&H0,&H0,0,0,0,1,1,0,2,10,10,10,0,0

SETVAR

}

function procOneFile 
{
	MEDIA=${1%\.*} # it's glob
	echo $MEDIA # Show what i am processing
	SUBS=(`ls subtitles/$MEDIA.*`)
	SUB=${SUBS[0]}
	ORIG_CODING=`chardetect.py $SUB  | sed 's/^.*: *//;s/ *with.*$//'`
	#echo $ORIG_CODING
	if [ $ORIG_CODING != 'UTF-8' ]
	then
		# iconv --unicode-subst='_' --widechar-subst='_' --byte-subst='_' -f $ORIG_CODING -t 'UTF-8' $SUB > $SUB.utf8
		win_iconv -f $ORIG_CODING -t 'UTF8' $SUB > $SUB.utf8
	else
		cp $SUB $SUB.utf8
	fi

	# Simplified Chinese to Traditional Chinese
	pushd /usr/opencc
	./opencc -c zhs2zhtw_vp.ini -i `cygpath -w $WD/$SUB.utf8` > $WD/$SUB.utf8tc
	popd

	rm -f $SUB.utf8

	# larger font size
	if [ ${SUB:(-3)} = 'srt' ]
	then
		# FIX BUG: some srt don't start at time stamp 1
		sed -r '1s/[0-9]+/1/' -i $SUB.utf8tc
		${FFMPEG} -i $SUB.utf8tc $SUB.tmp.ass
		writeAssHeader $SUB.utf8tc
		tail -n+8 $SUB.tmp.ass >> $SUB.utf8tc
		rm $SUB.tmp.ass
	fi
 
	${FFMPEG} ${LOG_LEVEL} -f matroska -i ${1} -vf subtitles="filename=$SUB.utf8tc:original_size=1280x640" -c:v libx264 -crf 22 -c:a aac -ar 48k -ac 2 -strict -2 subbed/$MEDIA.mkv
	
}

mkdir -p subbed

for var in "$@"
do
    procOneFile "$var"
done

