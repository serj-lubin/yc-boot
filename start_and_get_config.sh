set -e
if [[ ! -z $1 || $(yc compute instance list |grep test-1 |grep RUNNI)  ]]; then
#yc compute instance start  test-1  2>&1 >  /tmp/start.log
echo " skip starting instatnce"
yc compute instance list  |grep RUNN |grep test-1 | awk {' print $10 '}  > /tmp/address.log
else
yc compute instance start  test-1  2>&1 >  /tmp/start.log
cat /tmp/start.log |grep " address: " |grep -v 10. |  awk {' print $2 '} > /tmp/address.log
fi
#cat /tmp/start.log |grep " address: " |grep -v 10. |  awk {' print $2 '} > /tmp/address.log
ServerXY_W=1
srv=$(cat /tmp/address.log)

echo -n "waiting for Server $srv ..."
while (($ServerXY_W == 1))
do
   if ping -c 1  $srv &> /dev/null
   then
      echo "Server $srv is back online!"
      ServerXY_W=0
   else
      echo -n "."
   fi
done
#sleep 15
ServerXY_W=1

echo -n "waiting for Server $srv  port allow connect..."
while (($ServerXY_W == 1))
do
   if nc -z  $srv 943 &> /dev/null
   then
      echo "Server $srv  port is avaliable "
      ServerXY_W=0
   else
      echo -n "."
   fi
done


curl -k -u openvpn:R3nFRQW2ejefa https://$srv:943/rest/GetAutologin >  /etc/openvpn/client.conf

            wt=$(    cat /etc/openvpn/client.conf |grep "remote " |awk {' print $2 '} |head -n 1)
            echo  $wt
            echo $srv
                sed -i "s/$wt/$srv/g" /etc/openvpn/client.conf

systemctl restart  openvpn@client
sleep 20
echo " Yor ip for all now: "
curl ifconfig.me && echo
