#!/bin/bash
#
# Script is based on original work by
# Tecnalia Research & Innovation (https://www.tecnalia.com)
# https://github.com/hyperledger/blockchain-explorer/blob/release-3.5/deploy_explorer.sh
#
# SPDX-License-Identifier: Apache-2.0
#
# BASH CONFIGURATION
# Enable colored log
export TERM=xterm-256color

function banner(){
	echo ""
	echo "  _    _                       _          _                   ______            _                     "
	echo " | |  | |                     | |        | |                 |  ____|          | |                    "
	echo " | |__| |_   _ _ __   ___ _ __| | ___  __| | __ _  ___ _ __  | |__  __  ___ __ | | ___  _ __ ___ _ __ "
	echo " |  __  | | | | '_ \ / _ \ '__| |/ _ \/ _\` |/ _\` |/ _ \ '__| |  __| \ \/ / '_ \| |/ _ \| '__/ _ \ '__|"
	echo " | |  | | |_| | |_) |  __/ |  | |  __/ (_| | (_| |  __/ |    | |____ >  <| |_) | | (_) | | |  __/ |   "
	echo " |_|  |_|\__, | .__/ \___|_|  |_|\___|\__,_|\__, |\___|_|    |______/_/\_\ .__/|_|\___/|_|  \___|_|   "
	echo "          __/ | |                            __/ |                       | |                          "
	echo "         |___/|_|                           |___/                        |_|                          "
	echo ""
}

# HELPER FUNCTIONS
# Check whether a given container (filtered by name) exists or not
function existsContainer(){
	containerName=$1
	if [ -n "$(docker ps -aq -f name=$containerName)" ]; then
	    return 0 #true
	else
		return 1 #false
	fi
}

# HELPER FUNCTIONS
# Check whether a given network (filtered by name) exists or not
function existsNetwork(){
	networkName=$1
	if [ -n "$(docker network ls -q -f name=$networkName)" ]; then
	    return 0 #true
	else
		return 1 #false
	fi
}

# Check whether a given network (filtered by name) exists or not
function existsImage(){
	imageName=$1
	if [ -n "$(docker images -a -q $imageName)" ]; then
	    return 0 #true
	else
		return 1 #false
	fi
}

# Configure settings of HYPERLEDGER EXPLORER
function config(){
	# Default Hyperledger Explorer Database Credentials.
	explorer_db_user="hppoc"
	explorer_db_pwd="password"
	explorer_db_name="fabricexplorer"
	#configure explorer to connect to specific Blockchain network using given configuration
	network_config_file=$(pwd)/config.json
	#configure explorer to connect to specific Blockchain network using given crypto materials
	network_crypto_base_path=$(pwd)/crypto
	#specify directory containing Blockchain binaries
	network_bin_base_path=$(pwd)/bin
	#network version useful for pulling binaries
	hlf_version=2
	#network name, has to be similar to one where blockchain network is deployed
	docker_network_name="hlfgenerator_hlf"
	
	# database container configuration
	fabric_explorer_db_tag="bjowczarek/hyperledger-explorer-db:3.5"
	fabric_explorer_db_name="blockchain-explorer-db"

	# fabric explorer configuratio
	fabric_explorer_tag="bjowczarek/hyperledger-explorer:3.5"
	fabric_explorer_name="blockchain-explorer"
	# END: GLOBAL VARIABLES OF THE SCRIPT
}

function deploy_prepare_network(){
	if existsNetwork $docker_network_name; then
		echo "Removing old configured docker vnet for Hyperledger Explorer"
		stop_database
		stop_explorer
	fi

}

function stop_database(){
	if existsContainer $fabric_explorer_db_name; then
		echo "Stopping previously deployed Hyperledger Fabric Explorer DATABASE instance..."
		docker stop $fabric_explorer_db_name && \
		docker rm $fabric_explorer_db_name
	fi
}

function deploy_run_database(){
	stop_database

	# By default, since docker is used, there are no users created so default available user is
	# postgres/password
	echo "Deploying Database (POSTGRES) container at $docker_network_name network"
	docker run \
		-d \
		--name $fabric_explorer_db_name \
		--net $docker_network_name \
		-e POSTGRES_PASSWORD=$explorer_db_pwd \
		-e PGPASSWORD=$explorer_db_pwd \
		$fabric_explorer_db_tag
}

function deploy_load_database(){
	echo "Preparing database for Explorer"
	echo "Waiting...6s"
	sleep 1s
	echo "Waiting...5s"
	sleep 1s
	echo "Waiting...4s"
	sleep 1s
	echo "Waiting...3s"
	sleep 1s
	echo "Waiting...2s"
	sleep 1s
	echo "Waiting...1s"
	sleep 1s
	echo "Creating Default user..."
	docker exec $fabric_explorer_db_name psql -h localhost -U postgres -c "CREATE USER $explorer_db_user WITH PASSWORD '$explorer_db_pwd'"
	echo "Creating default database schemas..."
	
	docker exec $fabric_explorer_db_name psql -h localhost -U postgres -v dbname=$explorer_db_name -v user=$explorer_db_user -v passwd=$explorer_db_pwd -a -f /opt/explorerpg.sql
	docker exec $fabric_explorer_db_name psql -h localhost -U postgres -v dbname=$explorer_db_name -v user=$explorer_db_user -v passwd=$explorer_db_pwd -a -f /opt/updatepg.sql
}

function stop_explorer(){
	if existsContainer $fabric_explorer_name; then
		echo "Stopping previously deployed Hyperledger Fabric Explorer instance..."
		docker stop $fabric_explorer_name && \
		docker rm $fabric_explorer_name
	fi
}

function deploy_run_explorer(){
	stop_explorer

	echo "Deploying Hyperledger Fabric Explorer container at $docker_network_name network"
	cmd="node /opt/explorer/main.js"
	docker run \
		--name $fabric_explorer_name \
		--net $docker_network_name \
		-v $network_config_file:/opt/explorer/app/platform/fabric/config.json \
		-v $network_crypto_base_path:/data \
		-v $network_bin_base_path:/fabric-tools/bin \
		-p 8080:8080 \
		$fabric_explorer_tag \
		$cmd
}

function deploy(){

	deploy_prepare_network
	echo "Starting explorer in containers..."
	deploy_run_database
	deploy_load_database
	deploy_run_explorer
}

function main(){
	banner
	#checking if binaries in container's architecture exist
	if [ ! -f ./bin/cryptogen ] && [ ! -f ./bin/configtxgen ]; then
		./pullBinaries.sh Linux $hlf_version
	fi
	#Pass arguments to function exactly as-is
	config "$@"
	deploy
}

#Pass arguments to function exactly as-is
main "$@"