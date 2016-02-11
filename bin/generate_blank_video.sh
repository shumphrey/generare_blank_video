#!/usr/bin/env bash

## This generates a blank video that is a valid transport steam file
## Options can be changed to produce a smaller file, longer file, etc.
## It creates multiple (blank) audio tracks with different languages
## Does not create *working* subtitles currently, this requires vobsub files
## See https://code.google.com/archive/p/srt2vob/

## Command line options can be separated into a few sections:
## input, output and general
## Input for video:
# -t 60                 -> 60 seconds of video
# -s 640x480            -> resolution
# -f rawvideo           -> the input is rawvideo bytes
# -pix_fmt rgb24        -> How it should intepret the bytes? removing this makes it green.
# -r 25                 -> 25 frames per second. I don't think this really matters. ffmpeg ignores low values.
# -i /dev/zero          -> get the bytes from linux /dev/zero device
## Input for audio:
# -ar 48000             -> audio sampling frequency
# -ac 2                 -> number of audio channels
# -f s16le              -> audio input format (no idea why this one, but it works. Got it from stackoverflow question on generating blank audio)
# -i /dev/zero          -> get the audio bytes from /dev/zero
## General options
# -shortest             -> Everything should only be as long as the shortest thing (60s)
# -metadata:s:a:0 <opts>-> the metadata from the first audiotrack (language=eng)
# -map <num>            -> Not really sure, but this allows me to have multiple audio tracks

## Video output options
# -vcodec mpeg2video    -> the video codec to output
# -acodec mp2           -> the audio codec to output
# -b:v 10M              -> video bitrate to output
# -b:a 192Kb            -> audio bitrate to output
# -muxrate 10M          -> combined audio and video stream is 10Mbps
# -f mpegts             -> the output file is an mpegts file
# -metadata service_provider="Inview"
# -metadata service_name="InfraOne"
# other settings of interest to ts files
# -mpegts_original_network_id 0x1122 / -mpegts_transport_stream_id 0x3344 / -mpegts_service_id 0x5566 /

LENGTH=60
RESOLUTION=640x480
PROVIDERNAME="MyTest"
SERVICENAME="MyTestOne"

OUTFILE=/tmp/empty.ts
if [ "$1" ]; then
    OUTFILE=$1
fi

VIDEOINPUT="-t $LENGTH -s $RESOLUTION -f rawvideo -pix_fmt rgb24 -r 25 -i /dev/zero"
AUDIOINPUT1="-ar 48000 -ac 2 -f s16le -i /dev/zero"
AUDIOINPUT2="-ar 48000 -ac 2 -f s16le -i /dev/zero"
GENERAL="-shortest -map 0 -map 1 -map 2" # -map 3" #  -c:s dvbsub"
#OUTPUT="-vcodec mpeg2video -acodec mp2 -scodec dvbsub -b:v 10M -b:a 192k -muxrate 10M -f mpegts $OUTFILE"
OUTPUT="-vcodec mpeg2video -acodec mp2 -scodec dvbsub -pix_fmt yuv420p -f mpegts -y $OUTFILE"
METADATA="-metadata:s:a:0 language=eng -metadata:s:a:1 language=fra -metadata:s:s:0 language=spa -metadata service_provider='$PROVIDERNAME' -metadata service_name='$SERVICENAME'"

## TODO: The video file should be interlaced.
## TODO: Create a vobsub file for working subtitles

## To do subtitles, we need to convert an srt file to vobsub, this could be done
## with srt2vob (see link above) but probably not worth the hassle
## For now, we'll create *broken* subtitles, mediainfo will still list them
# SUBTITLES="-f srt -i /tmp/subtitles.srt"
# #SUBTITLES="-f microdvd -i /tmp/subtitles.sub"

# ## Create some fake subtitles
# echo "1"                             > /tmp/subtitles.srt
# echo "00:00:05,000 --> 00:00:34,400" >> /tmp/subtitles.srt
# echo "Howdy!"                        >> /tmp/subtitles.srt
# echo ""                              >> /tmp/subtitles.srt
# echo "2"                             >> /tmp/subtitles.srt
# echo "00:00:35,000 --> 00:00:50,400" >> /tmp/subtitles.srt
# echo "None more black!"              >> /tmp/subtitles.srt

# ffmpeg $VIDEOINPUT $AUDIOINPUT1 $AUDIOINPUT2 $SUBTITLES $GENERAL $METADATA $OUTPUT
ffmpeg $VIDEOINPUT $AUDIOINPUT1 $AUDIOINPUT2 $GENERAL $METADATA $OUTPUT
