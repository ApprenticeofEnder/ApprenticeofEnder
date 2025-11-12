#!/usr/bin/env sh

function divider(){
  echo "---------------------------------------"
}


TARGET=$1

which $TARGET

divider

where $TARGET

divider

brew list | grep $TARGET

divider

apt list | grep $TARGET

