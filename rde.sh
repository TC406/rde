#!/bin/bash
echo "Reading config...." >&2
#source $PWD/.rde.config
#echo "$source_files" >&2
#Reading configuration
#RDE_CONFIG = $1
#WORK_ENV = $2

while getopts c:e:s:o: option
do
case "${option}"
in
c) RDE_CONFIG=${OPTARG};;
e) WORK_ENV=${OPTARG};;
s) EXECUTE_SH=${OPTARG};;
o) OUTPUTS=${OPTARG};;
esac
done
echo $RDE_CONFIG
. $PWD/$RDE_CONFIG

#Creating temporary file for absolute path.
touch .sources_files.abp
while IFS= read -r line; do echo "$PWD/$line" >> .sources_files.abp ; done < $PWD/$WORK_ENV

rsync -az --progress --compress-level=1 -e "ssh -p $port" `cat $PWD/.sources_files.abp`  $server:$remote_dir
rsync -az --progress --compress-level=1 -e "ssh -p $port" $execute_script $server:$remote_dir
rm .sources_files.abp

#KOSTYL TO EXECUTE execute_remote.sh in $remote_dir directrory
touch temp_kostyl_to_execute
echo "#!/bin/bash" >> temp_kostyl_to_execute
echo "ssh -p $port $server 'cd $remote_dir ; bash -s $execute_script'" >> temp_kostyl_to_execute
bash temp_kostyl_to_execute  < $EXECUTE_SH
rm temp_kostyl_to_execute
#echo "bash $remote_dir/$execute_script"
#ssh -p $port $server 'bash $remote_dir/$execute_script'

#Creating temporary file for absolute path.
touch .output_files.abp
echo "$server:$remote_dir/$line"
while IFS= read -r line; do echo "$server:$remote_dir/$line" >> .output_files.abp ; done < $PWD/$OUTPUTS
echo "reciving_back"
#z --compress-level=9
rsync -a --update --progress -e "ssh -p $port" `cat $PWD/.output_files.abp` $PWD
rm .output_files.abp
#rm .output_files.abp
#rsync -azvh --progress --compress-level=9 $server:$remote_dir `cat $PWD/.sources_files.abp`

#mapfile -t myArray < .sources_files
#echo "$myArray"
#echo "$myArray"

#cp "$myArray" $PWD/test


#a=()
#while IFS= read -r line; do
#   a+=( "$line" )
#   echo "$a"
#   # ...
#done < ".sources_files"
#echo "$a"
#while IFS= read -r line; do cp "$line" $PWD/test ; done < .sources_files

#while read .sources_files
#do
#    cp "$filename" $PWD/test
#done
