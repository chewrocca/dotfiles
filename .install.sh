#!/usr/bin/env bash
rsync --recursive --verbose --exclude '.git' ~/tmpdotfiles/ $HOME/ \
  && rm -rf ~/tmpdotfiles
