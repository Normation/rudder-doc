#!/bin/sh
# A recursion level of 2 is enough because all pages are referenced in the left tree.
linkchecker -q -r 2 --check-extern --ignore-url=^http://localhost --ignore-url=^https://you-rudder webhelp/index.html
