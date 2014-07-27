Running Grappa is super easy with Docker. Our docker image includes all the dependencies, libraries, tools, compilers that you'll need to build and run Grappa, and this repository contains scripts to make it easy to setup and use the containers.

# Getting started

## Install docker
First, [install Docker](https://docs.docker.com/installation) for your platform.

### OSX
On OSX, this is made a bit more complicated because you'll actually have to setup a Linux virtual machine to run the docker daemon in. You can follow the instructions on their website, it's pretty easy. If you have [homebrew](http://brew.sh), it's as simple as:

~~~ bash
# if you don't have virtualbox already:
> brew tap phinze/homebrew-cask && brew install brew-cask
> brew cask install virtualbox
# then install docker and its companion vm
> brew install docker boot2docker
# initialize and fire up the Linux VM we'll run docker in
> boot2docker init
> boot2docker start
> export DOCKER_HOST=tcp://$(boot2docker ip 2>/dev/null):2375
~~~

### Verify docker is running

~~~ bash
# verify that the docker command now works
> docker version
Client version: 0.11.1
Client API version: 1.11
Go version (client): go1.2.1
Git commit (client): fb99f99
Server version: 1.1.1
Server API version: 1.13
Git commit (server): bd609d2
Go version (server): go1.2.1
~~~

## Setup Grappa

Now we'll actually take advantage of what's in this repository, so clone the repo:

~~~ bash
# clone this docker helper repo
> git clone git@github.com:uwsampa/grappa-docker.git
> cd grappa-docker
~~~

Now we're going to download the pre-built Grappa environment, create a new container, and clone the source code into it.

~~~ bash
> ./clone
~~~

This may take a while — it is, after all, downloading all of the dependencies, including a build of GCC, Boost, MPI, etc. Next, we need to run "configure" on the grappa source code we just cloned. Because this is Docker, we'll create another container to hold the generated build files to keep them separate from the clean source code. The configure script here does this as well as setting the right flags for the docker environment.

~~~ bash
> ./configure
~~~

Now we have everything we need to build and run Grappa, so let's create an interactive shell in the Grappa environment and try building and running something:

~~~ bash
> ./shell
docker /build $
# your prompt is now that of the shell running in the grappa environment
# look at the grappa source code:
docker /build $ ls /grappa
AUTHORS   CMakeLists.txt  NOTICE     applications  configure  scratch  third-party
BUILD.md  COPYING	  README.md  bin	   doc	      system   util

# build the hello-world demo app (with 4 cores, cuz who's only got one, right?)
docker /build $ make -j4 demo-hello_world


~~~


### Advanced: actually understanding what's going on

The `uwsampa/grappa` image expects two data containers, one which provides `/grappa` with the source code in it, and one which contains `/build`, with generated build files in it. We can see these two containers using `docker ps` (`-a` because these containers are data-only, so they aren't technically "running"):

~~~ bash
> docker ps -a | grep grappa-
38539cc5499f        busybox:latest      /bin/sh                11 days ago         Exited (0) 40 minutes ago                            grappa-build
80956d45fb92        busybox:latest      /bin/sh                11 days ago         Exited (0) 10 hours ago                              grappa-src
~~~


When you run `./shell`, you're pulling in these two containers and using them to host your source code and generated files *persistently* between runs.

------------------

Notes on how I installed and used Docker and set up the Grappa VM stuff

# OSX

## Quick Start
### Setup docker
First, [install Docker](https://docs.docker.com/installation/mac/), but stop after running the install script -- we will use a custom Vagrant VM rather than boot2docker out of the box. This is because even though Docker containers aren't VM's, Docker only works in Linux, so in OSX, we need a Linux VM to run it. On OSX, Docker uses a VM, and the `docker` command just sends commands to the Docker daemon running in the VM.

On OSX, you'll also want [Vagrant](http://www.vagrantup.com/downloads.html). Quick tip: you can download the .dmg and install, or if you have [homebrew](http://brew.sh/), you can install them using casks:

~~~ bash
> brew tap phinze/homebrew-cask && brew install brew-cask
> brew cask install vagrant
~~~

Now we need to fire up our VM which will run Docker for us.

~~~ bash
# from grappa root
> cd docker

# setup and start our Docker VM
> vagrant up

# verify that the docker command now works
> docker version
Client version: 0.11.1
Client API version: 1.11
Go version (client): go1.2.1
Git commit (client): fb99f99
Server version: 1.1.1
Server API version: 1.13
Git commit (server): bd609d2
Go version (server): go1.2.1
~~~

### Run Grappa in Docker
~~~ bash
# from grappa root:

# download 'grappa-base' image which contains things like gcc, ruby,
# and boost needed to build Grappa
> ./docker/local/build

# run 'configure' from inside the Docker container
> ./docker/local/configure
# verify that it has created a new build directory
> ls build
Ninja+Release

# you can also just launch a shell in the container and run these commands yourself:
> ./docker/local/run

~~~

# Notes

Docker doesn't run natively on OSX, but they have nice support via a lightweight `boot2docker` VM to run Docker in a VM and proxy those through the `docker` command in OSX.

Sharing files between them, however, is not supported by default. I got this working using Vagrant's NFS support. Vagrant recommends NFS over VirtualBox shared folders for better performance, and they make it really simple to set up. To set up the NFS-enabled boot2docker VM, I started from [yungsang/boot2docker][]'s VM.

	$ mkdir /opt/docker
	$ vagrant init yungsang/boot2docker

This downloads a `Vagrantfile` to your current directory, which I then needed to adjust to enable NFS by uncommenting/adding these two lines:

~~~ ruby
# share current directory (/opt/docker in this example) with the VM, mounted at /vagrant
config.vm.synced_folder ".", "/vagrant", type: "nfs"
# Vagrant needs a private host-only network interface for running the NFS shared folder
config.vm.network "private_network", ip: "192.168.33.10"
~~~

And then fire up the VM (downloads and configures and launches the VM defined by the Vagrantfile):

	$ vagrant up

Test the shared directory:

	$ echo hello > hello.txt
	$ vagrant ssh
	docker@boot2docker:~$ ls /vagrant
	Vagrantfile  hello.txt

To run Docker from OSX, then, tell the docker proxy how to connect to the boot2docker VM, and try it out:

	$ export DOCKER_HOST=tcp://localhost:2375
	$ docker version
	Client version: 0.11.1
	Client API version: 1.11
	Go version (client): go1.2.1
	Git commit (client): fb99f99
	Server version: 0.11.1
	Server API version: 1.11
	Git commit (server): fb99f99
	Go version (server): go1.2.1
	Last stable version: 0.11.1

> Note: got hit by Docker changing their default port. Or maybe it was boot2docker. Anyway, fixed by `vagrant ssh`ing into boot2docker and calling `docker info` and it listed the sockets, with the port number.

And, docker can also share directories with its own host, which on OSX is the Vagrant boot2docker VM, so to share files all the way from OSX to a Docker container, you must share the shared directory (`/vagrant`) as a volume to the container. For instance, you can run an interactive shell in the `ubuntu` container with a shared volume like so:

	$ docker run -i -t -v /vagrant:/vagrant /bin/bash
	root@ddedd95bfd10:/#
	root@ddedd95bfd10:/# ls /vagrant
	Vagrantfile  hello.txt

And there you have it! Two levels of VM sharing a directory...

Btw, this is what our `Vagrantfile` and `docker/local/run` scripts do to use the container to build from the source directory on the host.

If you get this error (which happens quite frequently for me right now):

    2014/07/10 18:16:06 Error: Cannot start container f1d4be8a78b76a1280ace529a70d760fba418f25d4ac247115e8f0921cdc7907:
    stat /grappa: stale NFS file handle

Then fix it by just restarting the Vagrant VM:

    > vagrant reload


## Running Grappa
- First, you need to re-provision Vagrant's VM to have more memory. Grappa seems to be able to run at SHMMAX=1GB, so I made my VM have 2 GB...
	- (also adjusted cores up to 4... assuming this can be configured in Vagrantfile?)
- run in privileged mode to set SHMMAX for a container:

		$ docker run -ti --privileged grappa-base /bin/bash
		grappa-base$ sysctl -w kernel.shmmax=$((1<<30))

## Additional tools/notes
### Tools To Investigate
- Fig: http://orchardup.github.io/fig/
  - Creates and runs Docker images automatically
- Shipyard: https://github.com/shipyard/shipyard
  - GUI for Docker
- Drone: https://github.com/drone/drone
  - Docker-based Continuous Integration (should work better for us than Jenkins once we have a Dockerfile setup working)

### Running distributed jobs
- [bittorrent-sync][]

---
[yungsang/boot2docker]: https://vagrantcloud.com/yungsang/boot2docker
[bittorrent-sync]: http://www.centurylinklabs.com/persistent-distributed-filesystems-in-docker-without-nfs-or-gluster/