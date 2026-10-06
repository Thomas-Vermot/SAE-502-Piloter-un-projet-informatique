#make a backup from the last save
if [ -e save_database.sql ]
then
	sudo mv save_database.sql save_database_backup.sql
fi
#save the database as a dump
sudo docker exec -i mariadb mysqldump -u groupe7 -p"groupe7" hopital > save_database.sql
