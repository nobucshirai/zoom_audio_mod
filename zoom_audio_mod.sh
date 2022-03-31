#!/bin/bash

m4a_list=(`ls -rt *.m4a`)
wav_list=()

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
  echo "converting wav to mp3 ... (takes time)"
  sox out.wav all_in_one.mp3
  echo "remove temporary wav file"
  rm ${wav_list[@]} out.wav
fi
