Check out http://smashing.github.io/ for more information.

Installing Smashing - https://github.com/Smashing/smashing/wiki/How-to%3A-Install-Smashing-on-Ubuntu-16.04.1

Running Smashing as a service:
'sudo mkdir /**directory**/logs'


'sudo touch /**directory**/logs/thin.log'


'sudo nano /etc/init/thin.conf'

Looks like: 

'description "thin"
version "1.0"
author "Travis Reeder"

env LANG=en_US.UTF-8
env APP_HOME=/**directory**/rmm_hud

respawn
start on runlevel [23]

script
    cd $APP_HOME
    sudo thin start -e production -p 3030 > $APP_HOME/logs/thin.log 2>&1
end script'


run command 
'sudo thin -d start'
to stop: 
'sudo thin stop'
