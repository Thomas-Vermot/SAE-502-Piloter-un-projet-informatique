#make a backup from the last save
if [ -e /home/tp/SAE_502_Groupe7/mariadb/save_database.sql ]
then
	sudo mv /home/tp/SAE_502_Groupe7/mariadb/save_database.sql /home/tp/SAE_502_Groupe7/mariadb/save_database_backup.sql
fi
#save the database as a dump
sudo docker exec -i mariadb mysqldump -u groupe7 -p"groupe7" hopital > /home/tp/SAE_502_Groupe7/mariadb/save_database.sql
