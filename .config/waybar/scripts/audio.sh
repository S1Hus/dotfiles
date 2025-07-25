#!/bin/bash

if pgrep pavucontrol >/dev/null; then
  pkill pavucontrol
else
  pavucontrol &
fi
