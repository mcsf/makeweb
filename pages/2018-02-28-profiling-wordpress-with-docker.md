# Profiling WordPress with Docker

_A quick recap of my steps._

## Build a custom Docker image

	# Make a temporary build directory
	$ mkdir -p /tmp/wordpress-xdebug; cd !$
	
	# Grab the source for the official WordPress Docker image
	$ curl -O https://raw.githubusercontent.com/docker-library/wordpress/618490d4bdff6c5774b84b717979bfe3d6ba8ad1/apache/{Dockerfile,docker-entrypoint.sh}
	$ chmod a+x docker-entrypoint.sh
	
	# Use an xdebug-enabled PHP image
	$ sed -i '' -e 's/php:5.6-apache/milk\/php-xdebug:7.1/' Dockerfile
	
	# Build it!
	$ docker build -t wordpress-xdebug .

## Run those containers!

	$ docker run --name wordpress-profiler-mysql -e MYSQL_ROOT_PASSWORD=password -d mysql:latest
	$ docker run --name wordpress-profiler --link wordpress-profiler-mysql:mysql -p 8001:80 -d wordpress-xdebug

## Profile the server

Open localhost:8001, set up WordPress. Maybe install Gutenberg, publish a couple of long posts. Alternatively, use WP-CLI for this. Then come back to the terminal.

	# Request profiling for a given route
	$ curl localhost:8001/?XDEBUG_PROFILE > /dev/null
	
	# Inspect the container
	$ CONT_ID=$(docker ps | grep wordpress-xdebug | awk '{ print $1 }')
	
	# Pick your files from the listing
	$ docker exec -t -i $CONT_ID /bin/bash -c "ls -ltr /tmp"
	
	# Assume you want `cachegrind.out.181`
	$ FILE="cachegrind.out.181"
	
	# Retrieve it to the desktop
	$ docker exec -t -i $CONT_ID /bin/bash -c "cat /tmp/$FILE" > ~/Desktop/$FILE

## Analyze

	$ brew install qcachegrind graphviz
	$ qcachegrind
