# Ianseo on Docker

An effort to run i@nseo archery tournament management software in a
Docker environment.

## Description

Ianseo is popular open source software used to manage archery
competitions. Given that the ianseo implementation can use Linux,
Apache, MySQL, and PHP I figured, as a learning experience, it would
be worthwhile to get ianseo running in a Docker environment. I chose
to use the official Docker php:apache and mysql offerings and use
docker-compose to define and run the resulting multi-container
environment.

The approach here is to use this project along with an ianseo release,
a zip file that can be downloaded from the ianseo site, and
docker-compose to create a containerized implementation of ianseo.

Docker volumes are used for the web back-end and the MySQL database so
results and updates are persisted.

## Warning

Note that this ianseo/Docker effort is not formally part of the ianseo
project, the intent here is only to provide a means to leverage the
ianseo implementation in a Docker environment. I have not tested all
of the ianseo software functionality in this Docker configuration but
suspect that what is provided here should be sufficient for a basic
ianseo evaluation.

## Getting Started

Getting a containerized ianseo instance up and running should be
simple once you have a sane Docker environment in place and have
downloaded the ianseo software (Ianseo_20220701.zip as of 2023-01-22).

You'll need to get the ianseo release in zip file format from the
ianseo site.  The current and previous releases have been available at
[http://www.ianseo.net/Release/](http://www.ianseo.net/Release/) and
the testing of this Docker effort has been against
[https://www.ianseo.net/Release/Ianseo_20220701.zip](https://www.ianseo.net/Release/Ianseo_20220701.zip).

The ianseo zip file is placed in the base directory of this project.
When _docker-compose build_ is issued, a support script will populate
the web server container/volume with the ianseo release and perform
the required installation steps.

## Dependencies

### Docker

You'll need Docker and docker-compose installed.  For testing I've
been using the Docker Community Edition, also referred to as
_docker-ce_.

See
[https://docs.docker.com/install/](https://docs.docker.com/install/) for details on how to install Docker.  On Ubuntu, for example, see [https://docs.docker.com/install/linux/docker-ce/ubuntu/](https://docs.docker.com/install/linux/docker-ce/ubuntu/).

### Docker Compose

You'll also need docker-compose. The Docker documentation for
obtaining docker-compose can be found at
[https://docs.docker.com/compose/install/](https://docs.docker.com/compose/install/) and for Linux this basically amounts to:

    sudo curl -L "https://github.com/docker/compose/releases/download/1.25.3/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose


The following instructions will get ianseo up and running on your
local machine for evaluation and testing purposes.

### Creating the Images/Containers

Summary, assumes you have a sane Docker / docker-compose environment:

1. Get this project (clone or download and extract)
2. Get the ianseo release in zip file format
3. Run _docker-compose build_ to build the containers

Starting at step 2.

Step 2. Get the ianseo release in zip file format

When this documentation was created the ianseo zip file site was
available from:
[https://www.ianseo.net/Releases.php](https://www.ianseo.net/Releases.php)

The ianseo release in zip file format can be downloaded from ianseo.
Testing was performed using Ianseo_20220701.zip.
   
    wget --quiet https://www.ianseo.net/Release/Ianseo_20220701.zip

The ianseo zip file goes into the base directory of this project.

Step 3. Run _docker-compose build_ to build the containers

Change into the directory where the project is, the files in this
directory include docker-compose.yml, Dockerfile and the ianseo zip
file from step 2. Depending on your user and Docker configuration you
may need to run the docker-compose command as root (or use sudo).

    [allan@localhost ianseo-docker]$ sudo /usr/local/bin/docker-compose build
    db uses an image, skipping
    Building web
    Step 1/9 : FROM php:7.4.2-apache
    7.4.2-apache: Pulling from library/php
    bc51dd8edc1b: Pull complete
    a3224e2c3a89: Pull complete
    [snipped large amount of output]
     ---> 41f56404153b
    Successfully built 41f56404153b
    Successfully tagged ianseo-docker_web:latest
    [allan@localhost ianseo-docker]$

### Starting and stopping the ianseo application

1. Run _docker-compose up_ to start the ianseo application
2. Use a browser to connect to and use ianseo
3. Run _docker-compose down_ to shutdown the ianseo application

Step 1. Run _docker-compose up_ to start the ianseo application

    [allan@localhost ianseo-docker]$ sudo /usr/local/bin/docker-compose up
    Creating network "ianseo-docker_default" with the default driver
    Creating volume "ianseo-docker_db_volume" with default driver
    Creating volume "ianseo-docker_web_volume" with default driver
    Pulling db (mysql:5.7.29)...
    5.7.29: Pulling from library/mysql
    [snipped large amount of output]
    db_1   | 2020-02-07T01:38:31.708104Z 0 [Note] Event Scheduler: Loaded 0 events
    db_1   | 2020-02-07T01:38:31.708221Z 0 [Note] mysqld: ready for connections.
    db_1   | Version: '5.7.29'  socket: '/var/run/mysqld/mysqld.sock'  port: 3306  MySQL Community Server (GPL)

Database and web server logging output will continue to be logged to
the terminal where the 'docker-compose up' was issued.

Step 2. Use a browser to connect to and use ianseo

Connect a web browser to the ianseo instance. If the browser is being
run on the same computer where you issued the _docker-compose up_ you
can specify the following URL:

http://localhost/ianseo/

Otherwise you'll need to get the IP address of computer running the
docker containers. One of my test systems running an instance of
ianseo is on 192.168.2.55 so, in my case. I'd use the following URL in
my web browser:

http://192.168.2.55/ianseo/

For the steps below use the IP address of the computer that performed
the _docker-compose up_ or if you are running the browser on that same
computer you can use _localhost_ instead of specifying the IP address.
In this example the IP address is 192.168.2.55:

a. Connect to http://192.168.2.55/ianseo and review the GPL3 License
Agreement.

b. On the _GPL3 License Agreement_ page mark the checkbox and click
the "I accept" button (Note: button appears after marking the
checkbox).

c. _PHP settings_ should be displayed showing various php.ini
parameters.  Click the _Continue_ at the bottom.

d. The _Database connection data_ should be displayed. Simply use the
default entries, the Host will be set to _ianseo\_docker\_db_ and the
ADMIN Password field at the bottom will be blank (not needed since we
have already created the ianseo MySQL database and user). Still, we
need to click the _Create user and database_ button to finish the
database initialization.

e. After a few seconds you should see an _Installation successful_
message. From here you can select _Modules->Update Ianseo_, agree to
the GPL3 license (if prompted), and then click the _Ok_ button which
proceeds with the online software update.

f. You should now be set to use the ianseo application. For example
you can select Competition->New.

Step 3. Run _docker-compose down_ to shutdown the ianseo application

From another shell on your Docker host you change into the same
directory where you issued the _docker-compose up_ and issue
_docker-compose down_ to stop the ianseo application. This will
gracefully shutdown the web and database containers.

    [allan@localhost ianseo-docker]$ sudo /usr/local/bin/docker-compose down
    Stopping ianseo-docker_web_1 ... done
    Stopping ianseo-docker_db_1  ... done
    Removing ianseo-docker_web_1 ... done
    Removing ianseo-docker_db_1  ... done
    Removing network ianseo-docker_default
    [allan@localhost ianseo-docker]$

## License

This project is licensed under the GPL 3.0 License - see the LICENSE
file for details.

## References

* [ianseo - Official Site](https://www.ianseo.net/)
* [ianseo How To - Manual_ENG.pdf](https://www.ianseo.net/Release/Manual_ENG.pdf)
* [ianseo Install-Linux-ENG.pdf](https://www.ianseo.net/Release/Install-Linux-ENG.pdf)
* [ianseo Release Area](http://www.ianseo.net/Release/)
* [Docker Engine overview](https://docs.docker.com/install/)
* [Install Docker Compose](https://docs.docker.com/compose/install/)
