Running Grappa is super easy with Docker. Our docker image includes all the dependencies, libraries, tools, compilers that you'll need to build and run Grappa, and this repository contains scripts to make it easy to setup and use the containers.

# Getting started

## Install docker
First, [install Docker](https://docs.docker.com/engine/installation/) for your platform.

### OSX
On OSX, this is made a bit more complicated because you'll actually have to setup a Linux virtual machine to run the docker daemon in. You can follow the [instructions on their website](https://docs.docker.com/engine/installation/mac/), it's pretty easy. 

### Verify docker is running

~~~ bash
# verify that the docker command now works
> docker version
Client version: 1.2.0
Client API version: 1.14
Go version (client): go1.3.1
Git commit (client): fa7b24f
OS/Arch (client): darwin/amd64
Server version: 1.2.0
Server API version: 1.14
Go version (server): go1.3.1
Git commit (server): fa7b24f
~~~

##  Running Grappa in Docker

Once you have Docker a docker install ready to go, we're ready to try running Grappa in a Docker container. This repository contains scripts to help you run Grappa in Docker (in addition to the Dockerfiles used to create the Docker images we'll be using). So clone the repo to get these scripts:

~~~ bash
# clone this docker helper repo
> git clone git@github.com:uwsampa/grappa-docker.git
> cd grappa-docker
~~~

Now we simply need to create a new container from the base Grappa image. The `create_container.sh` script will download the image, create a new container, and then attach your shell to the new container's shell:

~~~ bash
> ./create_container.sh
Pulling repository uwsampa/grappa
#> setup complete; hit <enter>
docker /grappa >
~~~

The `create_container.sh` script provides other options to help setup your development environment, such as copying in SSH keys to use to push changes to Github. To see these options, run `./create_container.sh --help`.

While attached to the running container, you can poke around at the Grappa source code. Try pulling the latest code into the container (this will often already be up-to-date, but just in case).

~~~ bash
docker /grappa > git pull
docker /grappa > ls
AUTHORS   CMakeLists.txt  NOTICE     applications  build      doc      system       util
BUILD.md  COPYING         README.md  bin           configure  scratch  third-party
~~~

From this code, we can run `./configure` to create a new build, but we actually already have a configuration started, so let's go to that, build the demo application, and run it.

~~~ bash
# cd into the pre-existing build directory
docker /grappa > cd build/Ninja+Release
# build the demo `hello_world` app
docker /grappa/build/Ninja+Release > ninja demo-hello_world
# run hello world with 2 processes:
docker /grappa/build/Ninja+Release > bin/grappa_run --nnode=1 --ppn=2 -- applications/demos/hello_world.exe
I0915 14:07:14.033941   396 Grappa.cpp:581]
-------------------------
Shared memory breakdown:
  locale shared heap total:     1 GB
  locale shared heap per core:  0.5 GB
  communicator per core:        0.125 GB
  tasks per core:               0.0156631 GB
  global heap per core:         0.125 GB
  aggregator per core:          0.00247955 GB
  shared_pool current per core: 4.76837e-07 GB
  shared_pool max per core:     0.125 GB
  free per locale:              0.463702 GB
  free per core:                0.231851 GB
-------------------------
I0915 14:07:14.065598   396 hello_world.cpp:34] Hello world from locale 0 core 0
I0915 14:07:14.065692   397 hello_world.cpp:34] Hello world from locale 0 core 1
~~~

At some point, you'll likely need to exit this container. To detach and keep the container running, you can hit the key combo: `ctrl+p` & `ctrl+q` (don't ask why Docker doesn't use standard screen key bindings). You can also stop the container by exiting the shell (`ctrl+d` or `exit`). In either case, the container is still around, with any changes you've made. You can find it with `docker ps -a` (`-a` shows stopped containers, which ):

~~~ bash
> docker ps -a
CONTAINER ID        IMAGE                   COMMAND               CREATED             STATUS                          PORTS               NAMES
82382fe297b9        uwsampa/grappa:latest   "/bin/bash --login"   37 minutes ago      Exited (0) About a minute ago                       grappa
~~~

Unless you specified a different name when creating the container, it will be called `grappa`. This makes it easy for us to work with the container. To re-attach to the container, first make sure it's started, then attach. *You'll have to hit `<enter>` after attaching to see the prompt*:

~~~ bash
> docker start grappa
> docker attach grappa
<enter>
docker /grappa > 
~~~

You may also at some point want to start from a fresh Grappa container. To do that, you can either create a new container with a new name (`create_container.sh --name=grappa2`, or you can delete the old container (`docker rm grappa`) and re-run `create_container.sh` to create a new one named `grappa`.

### Mounting the code on the host
While working on Grappa in Docker, you may want to be able to access the source code from the host machine. To do this, you can just run the `mount.sh` script. This will mount the directory `/grappa` from inside container at the specified mount point:

~~~ bash
# Usage: ./mount.sh <image> <mount_point>
> ./mount.sh grappa /shares/grappa
> ls /shares/grappa
AUTHORS   CMakeLists.txt  NOTICE     applications  build      doc      system       util
BUILD.md  COPYING         README.md  bin           configure  scratch  third-party
~~~
