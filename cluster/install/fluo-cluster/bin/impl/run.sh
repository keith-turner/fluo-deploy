#!/usr/bin/env bash

# Copyright 2014 Fluo authors (see AUTHORS)
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific 

function echo_prop() {
  prop=$1
  echo "`grep $prop $CONF_DIR/apps.properties | cut -d = -f 2-`"
}

if [ -z $1 ]; then 
  echo "ERROR - The 'run' command expects an application name as an argument"
  exit 1
fi
export FLUO_APP_NAME=$1

APP_REPO=`echo_prop $FLUO_APP_NAME.repo`
APP_BRANCH=`echo_prop $FLUO_APP_NAME.branch`
APP_PRE_INIT=`echo_prop $FLUO_APP_NAME.command.pre.init`
APP_POST_START=`echo_prop $FLUO_APP_NAME.command.post.start`

if [ ! -d $FLUO_HOME/apps/$FLUO_APP_NAME ]; then
  $FLUO_HOME/bin/fluo new $FLUO_APP_NAME
else
  echo "Restarting '$FLUO_APP_NAME' application.  Errors may be printed if it's not running..."
  $FLUO_HOME/bin/fluo kill $FLUO_APP_NAME
  rm -rf $FLUO_HOME/apps/$FLUO_APP_NAME
  $FLUO_HOME/bin/fluo new $FLUO_APP_NAME
fi

mkdir -p $INSTALL_DIR/fluo-app-repos
cd $INSTALL_DIR/fluo-app-repos

rm -rf $FLUO_APP_NAME
git clone -b $APP_BRANCH $APP_REPO $FLUO_APP_NAME

cd $FLUO_APP_NAME

$APP_PRE_INIT "${@:2}"

$FLUO_HOME/bin/fluo init $FLUO_APP_NAME -f
$FLUO_HOME/bin/fluo start $FLUO_APP_NAME

$APP_POST_START "${@:2}"