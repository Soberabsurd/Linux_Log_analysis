#!/bin/bash
mylogs=/data/weblog/myaccess/myaccess-`date -d  yesterday +%Y-%m-%d`_00000
systime=`date -d yesterday +"%Y-%m-%d"`
loganalysis=/data/loganalysis/my-results
echo "Shell Start Time : "`date` >> $loganalysis/"my-"$systime"-results.txt"
############################ 总访问量 #############################
echo "Number of visit :">> $loganalysis/"my-"$systime"-results.txt"
awk '{print FNR}' $mylogs |wc -l >> $loganalysis/"my-"$systime"-results.txt"
############################ my.51wan.com访问量 #############################
echo "my.51wan.com of visit : ">> $loganalysis/"my-"$systime"-results.txt"
awk '$6~/my.51wan.com/{print i++}' $mylogs |wc -l >> $loganalysis/"my-"$systime"-results.txt"
############################ PV数量 #############################
echo "PV of Number :" >> $loganalysis/"my-"$systime"-results.txt"
awk '$8~/.html/{i++}END{print i}' $mylogs >> $loganalysis/"my-"$systime"-results.txt"
############################ 访问IP的个数（不重复）  ####################
echo "visit web ip :" >> $loganalysis/"my-"$systime"-results.txt"
awk '{++S[$1]}END{for(x in S) print S[x]}' $mylogs | wc -l >> $loganalysis/"my-"$systime"-results.txt"
############################ 消耗流量  #############################
echo "web visit of flow(G) :" >> $loganalysis/"my-"$systime"-results.txt"
awk '{sum+=$11}END{print sum/1024/1024/1024"G"}' $mylogs >> $loganalysis/"my-"$systime"-results.txt"
############################ ÿСʱ������  #############################
echo ------------------------- Each hour of access ---------------------->> $loganalysis/"my-"$systime"-results.txt"
awk -F ":" '{++S[$2]}END{for (x in S) print S[x],x}' $mylogs |sort -nr >> $loganalysis/"my-"$systime"-results.txt"
############################ 并发量的前十名（时间排算） ###########################
echo -------------------------- visits top 10 -------------------------- >> $loganalysis/"my-"$systime"-results.txt"
awk '{++S[$4]}END{for(x in S)print S[x],x}' $mylogs |sort -nr |head >> $loganalysis/"my-"$systime"-results.txt"
echo --------------------------Visit web top 10--------------------------- >> $loganalysis/"my-"$systime"-results.txt"
############################## 访问量前十的页面 ############################
awk '{++V[$8]}END{for(z in V)print V[z],(V[z]/FNR)*100"%",z}' $mylogs |sort -nr|head >> $loganalysis/"my-"$systime"-results.txt"
######################### 获取404的页面 ##############################
echo ---------------------------- error 404 ----------------------------- >> $loganalysis/"my-"$systime"-results.txt"
awk '$10~/^404$/{++S[$10]}END{for(x in S)print x" error :",S[x]}' $mylogs >> $loganalysis/"my-"$systime"-results.txt"
awk '$10~/^404$/{print $8}' $mylogs |sort|uniq -c|sort -nr >> $loganalysis/"my-"$systime"-results.txt"
######################### 获取500的页面 ##############################
awk '$10~/^500$/{print $8}' $mylogs |sort|uniq -c |sort -nr >> $loganalysis/"my-"$systime"-results.txt"
######################### Nginx向后端建立连接开始到关闭的最长时间（前十个） ##############################
echo --------------------------response_time------------------------- >> $loganalysis/"my-"$systime"-results.txt"
awk '{print $NF,$1,$7,$8}' $mylogs |sort -nr |head >> $loganalysis/"my-"$systime"-results.txt"
######################### 客户端请求使用最长时间（前十个） ##############################
echo ---------------------------request_time------------------------- >> $loganalysis/"my-"$systime"-results.txt"
awk '{print $(NF-2),$1,$7,$8}' $mylogs |sort -nr |head >> $loganalysis/"my-"$systime"-results.txt"
######################### 百度蜘蛛爬行次数 ##############################
echo -------------------------Baiduspider------------------------------ >> $loganalysis/"my-"$systime"-results.txt"
awk -F ";" '$2~/Baiduspider/{++S[$2]}END{for(x in S)print x"  :",S[x]}' $mylogs >> $loganalysis/"my-"$systime"-results.txt"
######################### 百度蜘蛛爬行页面次数 ##############################
awk '$0~/Baiduspider/{print $8,$4}' $mylogs| sort | uniq -c | sort -nr >> $loganalysis/"my-"$systime"-results.txt"
######################## 每个IP访问的次数 #############################
echo ------------------------IP Visit of Number--------------------------------------->> $loganalysis/"my-"$systime"-results.txt"
awk '{++S[$1]}END{for(a in S) print S[a],a}' $mylogs |sort -nr | head -50 >> $loganalysis/"my-"$systime"-results.txt"
echo "Shell Over Time : "`date` >> $loganalysis/"my-"$systime"-results.txt"
/usr/local/bin/mailx -s $systime" myaccess results " yunwei@51wan.com < $loganalysis/"my-"$systime"-results.txt"
