#!/bin/bash

set -eu

nim compile --run main.nim
rm main
