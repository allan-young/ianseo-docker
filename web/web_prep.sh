#!/bin/bash

# This file is part of ianseo-docker, which is distributed under
# the terms of the General Public License (GPL), version 3. See
# LICENSE.txt for details.
#
# Copyright (C) 2020 Allan Young

# This script is run during the initial web container image creation,
# primarily to setup the content that will be provided to the web
# container and be served up by that container's apache instance.
# Essentially we:
#
# 1. Clear/create a www directory to hold the web server's content.
# 2. Extract the files from the Ianseo zip file into that directory
# 3. Tweak the Install/index.php file to simplify the initial
#    configuration.
# 4. Set ownership and access for the ianseo files.
# 5. Remove the the ianseo/Common/config.inc.php file so we'll get the
#    initial configuration page(s) when we first connect to the
#    server.
# 6. Delete the zip Ianseo file to save space.
IANSEO_ZIP=/tmp/Ianseo_20190701.zip
INSTALL_DIR=/var/www/html/ianseo
INDEX_PHP=$INSTALL_DIR/Install/index.php

directory_prep()
{
    # Make sure we have the zip file that contains the Ianseo
    # implementation.
    if [ ! -f $IANSEO_ZIP ]; then
	echo "Did not find required file $IANSEO_ZIP."
	exit 1
    fi

    # Remove previous remnants, if they exist.
    if [ -d $INSTALL_DIR ]; then
	echo "Removing old install directory: $INSTALL_DIR"
	rm -rf $INSTALL_DIR
    fi

    if [ ! -d $INSTALL_DIR ]; then
	echo "Creating install directory: $INSTALL_DIR"
	mkdir -p $INSTALL_DIR
    fi
}

extract_ianseo_zip()
{
    if [ -f $IANSEO_ZIP ]; then
	echo -n "Extracting $IANSEO_ZIP file... "
	UNZIP_OUT=$(unzip $IANSEO_ZIP -d $INSTALL_DIR)
	RC=$?
	if [ $RC -ne 0 ]; then
	    echo ""
	    echo "Failed to unzip $IANSEO_ZIP.  unzip output:"
	    echo "$UNZIP_OUT"
	    exit 1
	fi
	# No need to keep the zip file around.
	rm -f $IANSEO_ZIP
	echo "done."
    fi
}

ianseo_tweaks()
{
    # As per the ianseo Linux install guide we delete the
    # config.inc.php file.  With this file removed we'll get the
    # initial configuration page(s).
    if [ -f $INSTALL_DIR/Common/config.inc.php ]; then
	echo "Removing $INSTALL_DIR/Common/config.inc.php"
	rm -f "$INSTALL_DIR/Common/config.inc.php"
    fi

    # We'll make the default database Host name match the name for our
    # Docker database instance on the "Database connection data" page,
    # the user will be able to use the page's default entries and
    # simply click "Create user and database".
    if [ -f $INDEX_PHP ]; then
	echo "Tweaking ${INDEX_PHP}"
	sed -i.orig "s/W_HOST='localhost'/W_HOST='ianseo_docker_db'/" $INDEX_PHP
    fi

    # There's a tiny one character typo/bug in UpdateDb.inc.php
    # included in Ianseo_20190701.zip.  Note that the problematic
    # UpdateDb.inc.php file gets replaced when you perform your online
    # update and the implementation issue is moved to and corrected in
    # UpdateDb-2019.inc.php provided with the update.  Regardless,
    # we'll apply a fix to the original problem UpdateDb.inc.php, if
    # present.
    UPDATE_DB_FILE=$INSTALL_DIR/Common/UpdateDb.inc.php
    UPDATE_DB_MD5SUM=$(md5sum "$UPDATE_DB_FILE" | awk '{ print $1 }')
    if [ "$UPDATE_DB_MD5SUM" = "9b97ce0acf64cdd6df6dadfd5e72bead" ]; then
	# Yep, this is the UpdateDb.inc.php with the typo bug.
	echo "Fixing typo in UpdateDb.inc.php."
	# Change unique line in the file, use sed for in-place
	# adjustment, $q becomes $t.
	# shellcheck disable=SC2016
	sed -i 's/if($u=safe_fetch($q))/if($u=safe_fetch($t))/' "$UPDATE_DB_FILE"
	RC=$?
	if [ $RC -ne 0 ]; then
	    echo "sed returned non-zero, UpdateDb.inc.php typo/fix may not be applied."
	fi
    fi
}

set_permissions()
{
    # The ianseo Linux install guide provides instructions to
    # explicitly open up file/directory write access to _all_ users.
    # Since the web container's PHP implementation is driven by apache
    # we'll simply restrict the file/directory ownership to the
    # www-data user/group and be less permissive.
    echo "Adjusting ianseo file ownership and access."
    chown -R www-data.www-data $INSTALL_DIR
    chmod -R u+wX $INSTALL_DIR
}

echo "web_prep script starting:"
directory_prep
extract_ianseo_zip
ianseo_tweaks
set_permissions

# Useful for debugging, checking the PHP configuration.
cp /tmp/phpinfo.php /var/www/html/phpinfo.php
chown www-data.www-data /var/www/html/phpinfo.php

# Enable the ianseo apache configuration.
a2enconf -q ianseo

echo "web_prep script completed."
