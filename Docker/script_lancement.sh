 #install docker
sudo apt update 
sudo apt install ca-certificates curl -y
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/debian
Suites: $(. /etc/os-release && echo "$VERSION_CODENAME")
Components: stable
Signed-By: /etc/apt/keyrings/docker.asc
EOF
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

#launch dockers
sudo docker compose up -d

echo "Waiting for MariaDB to start..."
until sudo docker exec mariadb mysqladmin ping -u"groupe7" -p"groupe7" --silent; do
    sleep 2
done
#connect to database
#create database tables
sudo docker exec -i mariadb mysql -u root -p"mypass" -e "CREATE DATABASE IF NOT EXISTS hopital; GRANT ALL PRIVILEGES ON hopital.* TO 'groupe7'@'%';"
sudo docker exec -i mariadb mysql -u root -p"mypass" -e "CREATE TABLE IF NOT EXISTS hopital.RFID(id VARCHAR(50), jaune BOOLEAN, rouge BOOLEAN, PRIMARY KEY(id));"
#if save -> import it
if [ -e /home/tp/SAE_502_Groupe7/mariadb/save_database.sql ]
then
	sudo docker exec -i mariadb mysql -u root -p"mypass" hopital < /home/tp/SAE_502_Groupe7/mariadb/save_database.sql
	echo "Last save imported into the database"
fi

#launch database save script every two hours
SCRIPT_PATH="$(pwd)/script_sauvegarde.sh"
if [ -f "$SCRIPT_PATH" ]
then
	(crontab -l 2>/dev/null | grep -vF "$SCRIPT_PATH" ; echo "0 */2 * * * $SCRIPT_PATH") | crontab -
	echo "Crontab réussi !"
else
	echo "Crontab échoué..."
fi
