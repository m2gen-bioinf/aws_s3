#!/bin/bash
# monthly purge data and scratch
f () {
    errcode=$? # save the exit code as the first thing done in the trap function
    echo "error $errorcode"
    echo "the command executing at the time of the error was"
    echo "$BASH_COMMAND"
    echo "on line ${BASH_LINENO[0]}"
    # do some error handling, cleanup, logging, notification
    # $BASH_COMMAND contains the command that was being executed at the time of the trap
    # ${BASH_LINENO[0]} contains the line number in the script of that command
    # exit the script or return to try again, etc.
    exit $errcode  # or use some other value or do return instead
}
trap f ERR
pdays=${1:-180}

d=$(date +%Y-%m-%d)
pdate=$(date +%m/%d/%Y -d "-$pdays days")
rd="/home/ubuntu/monthly_purge"
# scan data
echo "Find the files to purge from /data not accessed since $pdate ..."
lf=$rd'/scan_data2purge_'$d'.txt'
jf=$rd'/data2purge_'$d'.json'
sudo scan_lastaccess.py -s /data -r --sizemin 0 -H -b $pdate -R $jf -e "*.py,*.R,*.bash" > $lf 2>&1
d2p=$rd'/data2purge_'$d'.txt'
d2s=$rd'/data2purge_s_'$d'.txt'
get_lastaccess_results.py -R $jf > $d2p
# sort and remove info lines
sed '/^>>> Info/d' $d2p | sort > $d2s
# get no. files and size
nf=`wc -l $d2s|awk '{print $1}'`
echo "Number of files: $nf"
echo "Calculating size of /data to purge ..."
cat $d2s | while read file;do    du -a "$file"; done | awk '{i+=$1} END {print i}'

# scan scratch
echo "Find the files to purge from /scratch not accessed since $pdate ..."
lf=$rd'/scan_scratch2purge_'$d'.txt'
jf=$rd'/scratch2purge_'$d'.json'
sudo scan_lastaccess.py -s /scratch -r --sizemin 0 -H -b $pdate -R $jf -e "*.py,*.R,*.bash" > $lf 2>&1
s2p=$rd'/scratch2purge_'$d'.txt'
s2s=$rd'/scratch2purge_s_'$d'.txt'
get_lastaccess_results.py -R $jf > $s2p
# sort and remove info lines
sed '/^>>> Info/d' $s2p | sort > $s2s
# get no. files and size
nf=`wc -l $s2s|awk '{print $1}'`
echo "Number of files: $nf"
echo "Calculating size of /scratch to purge ..."
cat $s2s | while read file;do    du -a "$file"; done | awk '{i+=$1} END {print i}'

echo "Purge /data ..."
sed 's/ data/ \/data/' /data/s3_logs/s3_data.log | awk '{for (i=5;i<=NF;i++) printf("%s ",$i)} {print ""}' > "$rd/s3_data.txt"
cat $d2s | while read file; do
    if ! grep "$file" "$rd/s3_data.txt" > /dev/null; then
        echo "$file not found; purge not done"
    else
        sudo rm "$file"
    fi
done

echo "Purge /scratch ..."
sed 's/ scratch/ \/scratch/' /data/s3_logs/s3_scratch.log | awk '{for (i=5;i<=NF;i++) printf("%s ",$i)} {print ""}' > "$rd/s3_scratch.txt"
cat $s2s | while read file; do
    if ! grep "$file" "$rd/s3_scratch.txt" > /dev/null; then
        echo "$file not found; purge not done"
    else
        sudo rm "$file"
    fi
done

# delete empty directories
echo "Delete empty directories on /data ..."
sudo find /data/ -type d -empty -delete
echo "Delete empty directories on /scratch ..."
sudo find /scratch/ -type d -empty -delete
