#!/bin/bash

if [ -d "_site" ]; then
    echo "Removing existing _site directory..."
    rm -rf _site
fi

bundle exec jekyll clean

bundle exec jekyll serve --trace

