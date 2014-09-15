#!/bin/bash
##############################################################
# Launch a shell in a Grappa container using data containers
##############################################################
DIR="${BASH_SOURCE%/*}"
source $DIR/util/common.sh

define_flag 'name' 'grappa' "core grappa container"
define_flag 'ssh' '' "Identity file (private SSH key) to use in the container"

parse_flags $@

docker pull uwsampa/grappa:latest

# create new Grappa container (start detached so we can customize it some more)
id=$(docker run --name=$FLAGS_name -ti -d --privileged uwsampa/grappa)

# copy ssh key into container if specified
if [ -n "$FLAGS_ssh" ]; then
  
  echo "#> copying SSH keys into Docker container"
  
  # copy desired keys into new temporary directory
  cd $(mktemp -d)
  cp "$FLAGS_ssh"{,.pub} .
  
  # copy keys into their rightful place in docker
  # if on OSX, must copy them first into boot2docker and do the copy inside 
  # using raw docker filesystem as workaround
  # TODO: use `docker cp` once it works for copying *into* containers
  container="/var/lib/docker/aufs/mnt/$id/"
  copy_keys_cmd="
    sudo mkdir -p $container/root/.ssh
    sudo cp * $container/root/.ssh
  "
  case $(uname) in
    Darwin) # Mac OSX
      host=$(boot2docker ip 2>/dev/null)
      identity_file="$HOME/.ssh/id_boot2docker"
      tar cf - . | ssh -C docker@$host -i $identity_file "
        cd \$(mktemp -d); tar xpsfm -
        $copy_keys_cmd
      "
      ;;
    
    *) # Linux
      eval $copy_keys_cmd      
  esac
  
  # run command inside docker container to setup grappa repo to use ssh
  # (uwsampa/grappa image uses https so that it works without ssh)
  echo "git remote set-url origin git@github.com:uwsampa/grappa.git" | docker attach $FLAGS_name
  
fi

echo "#> setup complete; hit <enter>"
docker attach $FLAGS_name
