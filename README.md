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


### Advanced (actually understanding what's going on)

The `uwsampa/grappa` image expects two data containers, one which provides `/grappa` with the source code in it, and one which contains `/build`, with generated build files in it. We can see these two containers using `docker ps` (`-a` because these containers are data-only, so they aren't technically "running"):

~~~ bash
> docker ps -a | grep grappa-
38539cc5499f        busybox:latest      /bin/sh                11 days ago         Exited (0) 40 minutes ago                            grappa-build
80956d45fb92        busybox:latest      /bin/sh                11 days ago         Exited (0) 10 hours ago                              grappa-src
~~~


When you run `./shell`, you're pulling in these two containers and using them to host your source code and generated files *persistently* between runs.
