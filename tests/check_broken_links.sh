#!/bin/sh
# A recursion level of 2 is enough because all pages are referenced in the left tree.
# Add an exception for build.opensuse.org as they appear to have retrictions based on User-Agent
linkchecker -r 2 --check-extern --ignore-url=^https://build.opensuse.org --ignore-url=^http://localhost --ignore-url=^https://your.rudder.server --ignore-url=^https://social.technet.microsoft.com webhelp/index.html
