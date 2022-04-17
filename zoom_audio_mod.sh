#!/bin/bash

m4a_list=(`ls -rt *.m4a`)
wav_list=()
out_file="all_in_one.mp3"

for file in ${m4a_list[@]}
do
  echo "[$file]"
  m4a_file="${file}"
  wav_file="${file%.m4a}.wav"
  tmp_file="tmp.wav"
  echo "converting m4a to wav ..."
  afconvert -f WAVE -d LEI16 $m4a_file $wav_file
  echo "accelerating speed of speech ..."
  sox $wav_file $tmp_file tempo -s 1.5 
  mv -v $tmp_file $wav_file
  tmp_head_file="tmp_head.wav"
  tmp_tail_file="tmp_tail.wav"
  ffmpeg -i $wav_file -af silencedetect=noise=-50dB:d=2 -f null - 2>&1 \
  | ./extract_time.py \
  | while read line
  do
    line=($line)
    echo "deleting silent part (${line[0]}--${line[1]}) ..."
    sox $wav_file $tmp_head_file trim 0 ${line[0]}
    sox $wav_file $tmp_tail_file trim ${line[1]} -0
    sox $tmp_head_file $tmp_tail_file $wav_file
    rm $tmp_head_file $tmp_tail_file
  done
  wav_list=(${wav_list[@]} ${wav_file})
done

num_wav_list="${#wav_list[@]}"
if ((num_wav_list==0)); then :
elif ((num_wav_list==1)); then
  echo "converting wav to mp3 ... (takes time)"
  sox ${wav_list} ${wav_list%.wav}.mp3
  echo "remove temporary wav file"
  rm ${wav_list}
else
  echo "concate all wav files ..."
  sox ${wav_list[@]} out.wav
  if [[ -f "$out_file" ]]; then
    rm -vi $out_file
  fi
  echo "converting wav to mp3 ... (takes time)"
  sox out.wav $out_file
  echo "remove temporary wav file"
  rm ${wav_list[@]} out.wav
fi
