#!/bin/bash
d=$(date +%Y-%m-%d)
SMAIL=roy.m2gen@gmail.com
#
lf='/home/ubuntu/upload_work2s3_'$d'.txt'
sudo upload_tree_s3.py -s /work -r -S > $lf 2>&1
echo -e "To:$SMAIL \nSubject:backup \nBackup work to s3" | /usr/sbin/sendmail $SMAIL
#
lf='/home/ubuntu/upload_scratch2s3_'$d'.txt'
sudo upload_tree_s3.py -s /scratch -r -S > $lf 2>&1
echo -e "To:$SMAIL \nSubject:backup \nBackup scratch to s3" | /usr/sbin/sendmail $SMAIL
#
lf='/home/ubuntu/upload_data2s3_'$d'.txt'
sudo upload_tree_s3.py -s /data -r -S > $lf 2>&1
echo -e "To:$SMAIL \nSubject:backup \nBackup data to s3" | /usr/sbin/sendmail $SMAIL
#
lf='/home/ubuntu/upload_bioinformatics2s3_'$d'.txt'
sudo upload_tree_s3.py -s /bioinformatics -r -S > $lf 2>&1
echo -e "To:$SMAIL \nSubject:backup \nBackup bioinformatics to s3" | /usr/sbin/sendmail $SMAIL
# create the lists
aws s3 ls s3://m2gen-bioinformatics-data/data --recursive --human --summarize > /data/s3_logs/s3_data.log
aws s3 ls s3://m2gen-bioinformatics-data/scratch --recursive --human --summarize > /data/s3_logs/s3_scratch.log
aws s3 ls s3://m2gen-bioinformatics-data/work --recursive --human --summarize > /data/s3_logs/s3_work.log
aws s3 ls s3://m2gen-bioinformatics-data/bioinformatics --recursive --human --summarize > /data/s3_logs/s3_bioinformatics.log
echo -e "To:$SMAIL \nSubject:backup \nS3 file lists created" | /usr/sbin/sendmail $SMAIL
