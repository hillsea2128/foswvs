# free and open-source wifi vendo software

> preview https://foswvs.github.io/preview/
> backend http://10.0.0.1/a/

 This software may run on any distros, but i recommend using rpi device and flashing `Raspberry Pi OS Lite`.

 Note: Use php version 8 above.

# installation instructions
STEP 1:
 - download from https://www.raspberrypi.org/software/operating-systems/
 - flash `Raspberry Pi OS Lite` on your SDCard; and
 - in /boot directory add empty file named `ssh`
 - connect to `ssh pi@raspberrypi` using the password `raspberry` - don't forget to change the default password of your device.
 
STEP 2:
 - `sudo raspi-config` , `Localisation Options`, Set WLAN Country
 - `git clone https://github.com/hillsea2128/foswvs.git /home/pi/foswvs`
 - `chmod +x /home/pi/install.sh`
 - `/home/pi/./install.sh`
 - `sudo reboot`

