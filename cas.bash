#!/bin/bash
programname=$0
DEFAUTL_CAS_VERSION=0.9.1


function printLogo
{
	echo "                                                                        ";
	echo "                                                                        ";
	echo "        CCCCCCCCCCCCC               AAA                 SSSSSSSSSSSSSSS ";
	echo "     CCC::::::::::::C              A:::A              SS:::::::::::::::S";
	echo "   CC:::::::::::::::C             A:::::A            S:::::SSSSSS::::::S";
	echo "  C:::::CCCCCCCC::::C            A:::::::A           S:::::S     SSSSSSS";
	echo " C:::::C       CCCCCC           A:::::::::A          S:::::S            ";
	echo "C:::::C                        A:::::A:::::A         S:::::S            ";
	echo "C:::::C                       A:::::A A:::::A         S::::SSSS         ";
	echo "C:::::C                      A:::::A   A:::::A         SS::::::SSSSS    ";
	echo "C:::::C                     A:::::A     A:::::A          SSS::::::::SS  ";
	echo "C:::::C                    A:::::AAAAAAAAA:::::A            SSSSSS::::S ";
	echo "C:::::C                   A:::::::::::::::::::::A                S:::::S";
	echo " C:::::C       CCCCCC    A:::::AAAAAAAAAAAAA:::::A               S:::::S";
	echo "  C:::::CCCCCCCC::::C   A:::::A             A:::::A  SSSSSSS     S:::::S";
	echo "   CC:::::::::::::::C  A:::::A               A:::::A S::::::SSSSSS:::::S";
	echo "     CCC::::::::::::C A:::::A                 A:::::AS:::::::::::::::SS ";
	echo "        CCCCCCCCCCCCCAAAAAAA                   AAAAAAASSSSSSSSSSSSSSS   ";
	echo "                                                                        ";
	echo "                                                                        ";
	echo "                                                                        ";
	echo "                                                                        ";
	echo "                                                                        ";
	echo "                                                                        ";
	echo "                                                                        ";
}

# Print usage guide
function usage {
  echo "usage: $programname COMMAND"
  echo "  -------- COMMANDS -------"
  echo "  -i {site url} [version number]   Verify requirements and start installation"
  echo "  -r                               Start the system"
  echo "  -s                               Stop the system"
  echo "  -d                               Remove the system"
  echo "  -u {version number}              Search for updates"
  echo "  -h                               Show help"
  exit 1
}

function install() {
	echo "Starting CAS System Installation v. $1"
  # Checking for requirements
  echo "  [INSTALL 1/10] Checking requirements.."
  if exists docker; then
    echo "    DOCKER .............................. OK";
  else
    echo "    DOCKER .............................. NOT FOUND";
    exit 1;
  fi
  if exists docker-compose; then
    echo "    DOCKER-COMPOSE ...................... OK";
  else
    echo "    DOCKER-COMPOSE ...................... NOT FOUND";
    exit 1;
  fi
  
  if exists nginx; then
    echo "    NGINX ............................... OK";
  else
    echo "    NGINX ............................... NOT FOUND";
    sudo apt-get install nginx;
  fi

  # Start Gitlab INSTALLATION
  echo "  [INSTALL 3/10] Installing GitLab"
  git clone https://github.com/ciambialonso/cas-gitlab.git
  cd cas-gitlab
  echo "Creating volumes for GitLab..."
  sudo docker volume create gitlab-data
  sudo docker volume create gitlab-config
  sudo docker-compose up -d

  # Start Mattermost INSTALLATION
  cd ../
  echo "  [INSTALL 4/10] Installing Mattermost"
  git clone https://github.com/mattermost/mattermost-docker.git
  cd mattermost-docker
  sudo rm docker-compose.yml
  cd ..
  git clone https://github.com/ciambialonso/cas-mattermost.git
  cd cas-mattermost
  cp docker-compose.yml cas-mattermost 
  cd ..
  sudo rm -rf cas-mattermost
  mv mattermost-docker cas-mattermost
  cd cas-mattermost
  echo "Spostamenti di cartelle fatti ......"
  docker-compose build
  mkdir -pv ./volumes/app/mattermost/{data,logs,config,plugins,client-plugins}
  sudo chown -R 2000:2000 ./volumes/app/mattermost/
  sudo docker-compose build
  sudo docker-compose up -d

  # Start Sonarqube INSTALLATION
  cd ../
  echo "  [INSTALL 5/10] Installing Sonarqube"
  git clone https://github.com/ciambialonso/cas-sonarqube.git
  cd cas-sonarqube
  sudo docker-compose up -d

  # Start Taiga INSTALLATION
  cd ../
  echo "  [INSTALL 6/10] Installing Taiga"
  git clone https://github.com/ipedrazas/cas-taiga.git
  cd cas-taiga
  sudo docker-compose up -d


    
  # Operation completion, print information data
  echo "  [INSTALL 10/10] Installation Completed"
}



# Run all services
function startAll {
  echo "Starting CAS System..."

  # Start Gitlab
  echo "  [START 1/8] Starting GitLab"
  cd cas-gitlab
  sudo docker-compose start


  # Start Mattermost
  cd ../
  echo "  [START 2/8] Starting Mattermost"
  cd cas-mattermost
  sudo docker-compose start

  # Start Sonarqube
  cd ../
  echo "  [START 3/8] Starting Sonarqube"
  cd cas-sonarqube
  sudo docker-compose start

  # Start Taiga
  cd ../
  echo "  [START 4/8] Starting Taiga"
  cd cas-taiga
  sudo docker-compose start

  # Wait for operation completion
  echo "  [START 7/8] Waiting for operations' completion"
  sleep 10


  # Operation completion, print information data
  echo "  [START 8/8] All services are now running"
}


# Stop all services
function stopAll {
  echo "Stopping CAS System..."

  # Stop Gitlab
  echo "  [STOP 1/8] Stopping GitLab"
  cd cas-gitlab
  sudo docker-compose stop

  # Stop Mattermost
  cd ../
  echo "  [STOP 2/8] Stopping Mattermost"
  cd cas-mattermost
  sudo docker-compose stop

  # Stop Sonarqube
  cd ../
  echo "  [STOP 3/8] Stopping Sonarqube"
  cd cas-sonarqube
  sudo docker-compose stop

  # Stop Taiga
  cd ../
  echo "  [STOP 4/8] Stopping Taiga"
  cd cas-taiga
  sudo docker-compose stop

  # Wait for operation completion
  echo "  [STOP 7/8] Waiting for operations' completion"
  sleep 10


  # Operation completion, print information data
  echo "  [STOP 8/8] All services are now stopped"
}




# Delete all services
function deleteAll {
  echo "Deleting CAS System..."
  cd cas-components

  # Delete Gitlab
  echo "  [DELETE 1/8] Deleting GitLab"
  cd cas-gitlab
  sudo docker-compose rm


  # Delete Mattermost
  cd ../
  echo "  [DELETE 2/8] Deleting Mattermost"
  cd cas-mattermost
  sudo docker-compose rm

  # Delete Sonarqube
  cd ../
  echo "  [DELETE 3/8] Deleting Sonarqube"
  cd cas-sonarqube
  sudo docker-compose rm

  # Delete Taiga
  cd ../
  echo "  [DELETE 4/8] Deleting Taiga"
  cd cas-taiga
  sudo docker-compose rm

  # Wait for operation completion
  echo "  [DELETE 7/8] Waiting for operations' completion"
  sleep 10


  # Operation completion, print information data
  echo "  [STOP 8/8] All services has been removed"
}

exists()
{
  command -v "$1" >/dev/null 2>&1
}

printLogo
sleep 5

if [ "$#" -lt 1 ]; then
  usage
fi

while getopts ":hirsdu:" opt; do
  case $opt in
    h)
      usage
      ;;
    i)
      shift $(($OPTIND - 1))
	  site_url=$@
	  shift $(($OPTIND - 1))
	  cas_ver=$@
      if [ -z "$cas_ver" ]
      then
        install $site_url $DEFAUTL_CAS_VERSION
      else
        install $site_url $cas_ver
      fi
      ;;
    r)
      startAll
      ;;
    s)
      stopAll
      ;;
    d)
      deleteAll
      # Remove all volumes with persistent data
      sudo docker volume prune
      sudo docker network prune
      ;;
    u)
      cas_ver=$OPTARG
      deleteAll
      install $cas_ver
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
    ;;
  esac
done

exit 1
