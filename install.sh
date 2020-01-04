#! /bin/bash

read -p "Enter the frps version you want to install(example: 0.30.0):" FRP_VERSION
read -p "Enter the frps platform you want to install(amd64\arm\arm64):" FRP_PLATFORM
read -p "Server for Client(frps\frpc):" FRP_CORS

FILE="frp_${FRP_VERSION}_linux_${FRP_PLATFORM}"

if [ ! -f "${FILE}.tar.gz" ]
then
  echo -e "Downloading!\n"
  wget https://github.com/fatedier/frp/releases/download/v${FRP_VERSION}/${FILE}.tar.gz
fi

tar -xf ${FILE}.tar.gz

mv ${FILE}/${FRP_CORS} /usr/bin/${FRP_CORS}


mv ${FILE}/systemd/${FRP_CORS}.service /etc/systemd/system/${FRP_CORS}.service

# make some change to .ini
if [ ${FRP_CORS} == "frps" ]
then
  touch frps.ini
  cat frps_template.ini >> frps.ini
  read -p "Enter authentic token" TOKEN
  read -p "Enter dashboard_user:" DASH_USER
  read -p "Enter dashboard_passwd:" DASH_PASSWD
  sed -i "s/TOKEN/${TOKEN}/g" frps.ini
  sed -i "s/DASH_USER/${DASH_USER}/g" frps.ini
  sed -i "s/DASH_PASSWD/${DASH_PASSWD}/g" frps.ini

else
  touch frpc.ini
  cat frpc_template.ini >> frpc.ini
  read -p "Enter authentic token:" TOKEN
  read -p "Enter server address:" SERVER_ADDR
  sed -i "s/TOKEN/${TOKEN}/g" frpc.ini
  sed -i "s/SERVER_ADDR/${SERVER_ADDR}/g" frpc.ini
fi


mkdir /etc/frp/
mv ${FRP_CORS}.ini /etc/frp/${FRP_CORS}.ini

echo "config systemd"
systemctl enable ${FRP_CORS}.service
systemctl start ${FRP_CORS}.service

# clean files
rm -rf ${FILE}





