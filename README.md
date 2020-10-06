needs work

# Battery charging lvl controll notifyer. Works on Kali Linux.

Battery controll script for analizing battery state, turn off automatically computer when law battery and notify user when it is near 100% charge.

Make sure scripts are in /home/user-folder/bin

Make them autoloaded on start up. Thus add BAcontroll file to /etc/init.d/ or equivalent to your distr. system init folder, and then create symbol link to /etc/rc.d (or /etc/rc5.d/ for Kali)

You also need to install festival if you want audio notifying.

If you would want manually stop, start, restart and check status, you can type:

/etc/init.d/BAcontrol <start | stop | status | restart >
