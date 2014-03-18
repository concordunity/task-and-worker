# README

## TaskServer

	cd /etc/init.d/
	sudo ln -s /home/david/dms/bin/run-taskserver.sh taskserver
	#set shell as daemon
	sudo update-rc.d taskserver defaults

## Worker

	cd /etc/init.d/
	sudo ln -s /home/david/dms/bin/run-worker.sh celeryd
	#set shell as daemon
	sudo update-rc.d celeryd defaults
