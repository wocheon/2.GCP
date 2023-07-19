#!/bin/bash
# 매월 마지막주 일요일 오전 4시에 실행.
# 0 4 * * 0 [ $(date +"\%m") -ne $(date -d 7days +"\%m") ] && sh /etc/haproxy/cerbot_renew.sh
# log_path 디렉토리 생성확인 후 진행.

today_date=$(date '+%y%m%d')
log_path='/var/log/letsencrypt/ssl_renew_log'
log_file=$log_path/cert_renew_log_${today_date}.log
dup_chck=$(find $log_path -name cert_renew_log_$today_date* | wc -l)

if [ $dup_chck -ne 0 ]; then
        file_num=`expr $dup_chck + 1`
        mv $log_file $log_path/cert_renew_log_${today_date}_${file_num}.log
fi

echo -e "\E[;34m##JOB Start##\E[0m"
echo  "##JOB Start##" >> $log_file
echo "StartDate : " $(date) | tee -a $log_file
echo "LogFile : ${log_file}"  | tee -a $log_file
echo "" | tee -a $log_file


echo -e "\E[;34m##Certificate Info##\E[0m"
echo  "##Certificate Info##" >> $log_file
certbot certificates | tee -a $log_file
echo "" | tee -a $log_file

domain=$(tail -5 /var/log/letsencrypt/letsencrypt.log | grep Domains: | gawk -F': ' '{print $2}')
expiry_date=$(tail -5 /var/log/letsencrypt/letsencrypt.log | grep VALID: | gawk -F'VALID: ' '{print $2}' | gawk '{print $1}')

if [ $expiry_date -gt 30 ]; then
        echo -e "\E[41;37m *Expiry Date : ${expiry_date} Days Remain \E[0m"
        echo -e "\E[41;37m Renew Certificates Canceled  \E[0m"
#        rm -f $log_file
        exit
fi

echo -e "\E[;34m##Port 80 Open Check##\E[0m"
echo  "##Port 80 Open Check##" >> $log_file
port_chck=$( netstat -ntlp | grep -w '0.0.0.0.0:80' | wc -l)

if [ $port_chck -ne 0 ]; then
        process=$(netstat -tnlp | grep -w '0.0.0.0.0:80' | gawk '{print $7}' | gawk -F'/' '{print $2}')
        echo "Port 80 Used by $process" | tee -a $log_file
        echo "" | tee -a $log_file

        echo -e "\E[;34m##Renew Certificate##\E[0m"
        echo  "##Renew Certificate##" >> $log_file

        echo -e "\E[;31msystemctl stop haproxy\E[0m"
        echo "systemctl stop haproxy" >> $log_file
        systemctl stop haproxy

        certbot renew  | tee -a $log_file
#       certbot renew --force-renewal | tee -a $log_file

        echo -e "\E[;31msystemctl start haproxy\E[0m"
        echo "systemctl start haproxy" >> $log_file
        systemctl start haproxy
else
        echo "Port 80 Usable" | tee -a $log_file
        echo "" | tee -a $log_file
        echo -e "\E[;34m##Renew Certificate##\E[0m"
        echo  "##Renew Certificate##" >> $log_file
        certbot renew  | tee -a $log_file
#       certbot renew --force-renewal | tee -a $log_file

fi

echo "" | tee -a $log_file
echo -e "\E[;34m##Certificate Info##\E[0m"
echo  "##Certificate Info##" >> $log_file
certbot certificates | tee -a $log_file


certpath="/etc/letsencrypt/live/${domain}/"
cat ${certpath}cert.pem > ${certpath}site.pem
cat ${certpath}chain.pem >> ${certpath}site.pem
cat ${certpath}privkey.pem >> ${certpath}site.pem


echo "" | tee -a $log_file
echo -e "\E[;34m##JOB Finished##\E[0m"
echo "##JOB Finished##" >> $log_file
