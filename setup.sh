sudo DEBIAN_FRONTEND=noninteractive apt-get -y update
sudo DEBIAN_FRONTEND=noninteractive apt-get -y upgrade

#install necessary packages
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y mininet
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y python3-pip
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y iperf3
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y python3-tk
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y traceroute
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y bridge-utils
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y iputils-ping
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y python3-psutil
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y python3-netifaces
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y default-jdk
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y dovecot-pop3d
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y postfix

pip3 install --upgrade pip 
pip3 install cpunetlog
pip3 install matplotlib
pip3 install ipykernel
cd /
sudo git clone https://github.com/bekl1011/CPUnetPLOT
cd /home/labrat
sudo mkdir -m 777 /home/labrat/Maildir
sudo mkdir -m 777 /home/labrat/Maildir/new
sudo mkdir -m 777 /home/labrat/Maildir/cur
sudo mkdir -m 777 /home/labrat/Maildir/tmp

#delete all existing dovecot and postfix config files and replace them with the config fils from the repo
sudo rm -rf /etc/postfix
sudo cp -r /home/labrat/kn1labBW/msConfig/postfix /etc
sudo rm -rf /etc/dovecot
sudo cp -r /home/labrat/kn1labBW/msConfig/dovecot /etc
sudo rm -rf /etc/aliases
sudo cp -r /home/labrat/kn1labBW/msConfig/aliases /etc
sudo rm -rf /etc/aliases.db
sudo cp -r /home/labrat/kn1labBW/msConfig/aliases.db /etc
sudo rm -rf /etc/mailcap
sudo cp -r /home/labrat/kn1labBW/msConfig/mailcap /etc
sudo rm -rf /etc/mailcap.order
sudo cp -r /home/labrat/kn1labBW/msConfig/mailcap.order /etc
sudo rm -rf /etc/mailname
sudo cp -r /home/labrat/kn1labBW/msConfig/mailname /etc

#After giving the new config files restart the services
sudo service dovecot restart
sudo service postfix restart

#generate a ssh key pair for versuch4
rm $HOME/.ssh/id_rsa*
ssh-keygen -N "" -f $HOME/.ssh/id_rsa
cat $HOME/.ssh/id_rsa.pub >> $HOME/.ssh/authorized_keys


#setup the Hostnames in the bash for versuch4 and add the cpunetlog scripts to PATH
sudo tee -a ~/.bashrc << EOF

### custom additions
# change prompt for mininet hosts
if [ ! -z \${SSH_CONNECTION+x} ]; then
  MyIP=\$(echo \$SSH_CONNECTION | awk '{print \$3}')

  case \$MyIP in
  "10.0.0.1")
    MyHostName="c1"
    ;;
  "10.0.0.2")
    MyHostName="c2"
    ;;
  "10.0.0.3")
    MyHostName="sv1"
    ;;
  *)
    MyHostName="unknown"
    ;;
  esac

  PS1="\e[01;32m\u@\$MyHostName:\e[m\e[01;34m\w\a\e[m\$ "
  PROMPT_COMMAND='echo -ne "\033]0;\$USER@\$MyHostName\007"'

  alias cnl_plot.py="echo \"Can't plot from an ssh session\""
fi

PATH=\$PATH:\$HOME/cpunetlog
EOF

#Assign the necessary IP-addresses to the given hosts
sudo tee -a /etc/hosts << EOF

127.0.1.1 kn1-lab.net.fail
10.0.0.1 c1
10.0.0.2 c2
10.0.0.3 sv1
EOF

#Change the congestion control algorithm for tcp from cubic to reno, to better see som congestion control mechanisms in versuch4
echo "net.ipv4.tcp_congestion_control = reno" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

#Automatically install the necessary Visual Studio Code extensions
code --install-extension vscjava.vscode-java-pack
code --install-extension ms-python.python
code --install-extension ms-toolsai.jupyter
