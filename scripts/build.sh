#!/bin/bash
set -x 
SELFDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TOPDIR=$(dirname $SELFDIR)
WEBDIR=$TOPDIR"/web"
export JEKYLL_ENV=production
cd $WEBDIR && bundle exec jekyll build