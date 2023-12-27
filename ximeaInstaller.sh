#based on installation procedure in https://www.ximea.com/support/projects/apis/wiki/Linux_TX1_and_TX2_Support
# with a slight change since I would not get the camera recognized on my jetsonTX2NX carrier borad produced by Forecr (DSBOARD-NX2) [https://www.forecr.io/products/dsboard-nx2]

sudo apt update
sudo apt install ca-certificates
wget https://www.ximea.com/downloads/recent/XIMEA_Linux_ARM_SP.tgz
tar -xf XIMEA_Linux_SP.tgz
cd package
./install
sudo gpasswd -a "$(whoami)" plugdev
if [ -f /etc/rc.local ]
then
sudo sed -i '/^exit/ d' /etc/rc.local
else
echo '#!/bin/sh -e'                                            | sudo tee    /etc/rc.local > /dev/null
fi
echo 'echo 0 > /sys/module/usbcore/parameters/usbfs_memory_mb' | sudo tee -a /etc/rc.local > /dev/null
echo 'exit 0'                                                  | sudo tee -a /etc/rc.local > /dev/null
sudo chmod a+x /etc/rc.local
#enable controlling of memory frequency by user
echo 'KERNEL=="emc_freq_min", ACTION=="add", GROUP="plugdev", MODE="0660"' | sudo tee /etc/udev/rules.d/99-emc_freq.rules > /dev/null
#optional: allow user to use realtime priorities
sudo groupadd -fr realtime
echo '*         - rtprio   0' | sudo tee    /etc/security/limits.d/ximea.conf > /dev/null
echo '@realtime - rtprio  81' | sudo tee -a /etc/security/limits.d/ximea.conf > /dev/null
echo '*         - nice     0' | sudo tee -a /etc/security/limits.d/ximea.conf > /dev/null
echo '@realtime - nice   -16' | sudo tee -a /etc/security/limits.d/ximea.conf > /dev/null
sudo gpasswd -a "$(whoami)" realtime
#reboot
sudo reboot
