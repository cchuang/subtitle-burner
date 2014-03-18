subtitle-burner
===============

Burn-in subtitles into a video by ffmpeg

Depends on
==========
* chardetect.py: determine which encoding is
* win_iconv: some subtitles have both BIG5 & UTF8 encoding characters
* opencc: simplified to traditional Chinese
* ffmpeg: str -> ass. burn-in subtitles

Usage
=====
Put subtitles in ./subtitles
  suburnin *.mkv
