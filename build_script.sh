#!/bin/bash

fvm flutter build appbundle
fvm flutter build ipa

sh upload_script.sh