#!/usr/bin/env sh

./installer.py  -f run_linux.cfg -f run_ubuntu.cfg -f run_u64-med.cfg -f run_nightly_linux.cfg -f compiler.cfg --doc

./installer.py -f run_linux.cfg -f run_ubuntu.cfg -f run_u64-med.cfg -f run_nightly_linux.cfg -f compiler.cfg -f debug.cfg --no-update-dirs --no-package --no-package-deps &> /dev/null
