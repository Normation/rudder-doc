#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
# Usage: ./generate_info.py
#
# This is a Python module to generate html code for the manual.
# The parameter is the manual beeing built.

import requests
import sys
import re
from distutils.version import StrictVersion
from pprint import pprint

beginning = """<xsl:stylesheet        
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:d="http://docbook.org/ns/docbook"
        xmlns:exsl="http://exslt.org/common"
        xmlns:ng="http://docbook.org/docbook-ng"
        xmlns:db="http://docbook.org/ns/docbook"
        version="1.0" xmlns="http://www.w3.org/1999/xhtml"
	      exclude-result-prefixes="exsl ng db d">"""

end = "</xsl:stylesheet>"

# URL of the rudder_info api
release_info_url = "http://www.rudder-project.org/release-info/rudder/"

def get_current_version_info(manual_version):

  info = {}
  info["version"] = manual_version

  try:
    info["supported"] = bool(requests.get(release_info_url + "versions/" + manual_version + "/supported").content.decode('ascii'))
    info["released"] = bool(requests.get(release_info_url + "versions/" + manual_version + "/released").content.decode('ascii'))
    info["release-date"] = requests.get(release_info_url + "versions/" + manual_version + "/release-date").content.decode('ascii')
    info["eol-date"] = requests.get(release_info_url + "versions/" + manual_version + "/eol-date").content.decode('ascii')
    info["lts"] = bool(requests.get(release_info_url + "versions/" + manual_version + "/lts").content.decode('ascii'))
  except requests.exceptions.RequestException as e:
    print(e)
    sys.exit(1)

  return info

def get_supported_versions():
  "Get a list of all supported versions with the lts status"
  
  versions = []
  
  try:
    supported_versions = requests.get(release_info_url + "versions/supported").content.decode('ascii').splitlines()
  except requests.exceptions.RequestException as e:
    print(e)
    sys.exit(1)
  
  supported_versions.sort(key=StrictVersion)

  for rudder_version in supported_versions:
    try:
      esr_version_raw = requests.get(release_info_url + "versions/" + rudder_version + "/lts").content.decode('ascii')
      esr_version = (esr_version_raw == "true")
      
    except requests.exceptions.RequestException as e:
      print(e)
      sys.exit(1)

    versions.append((rudder_version, esr_version))

  return versions

def format_index(version_info, template):

  return template.format(rudder_version = version_info["version"])

def format_header(versions, manual_version):
  
  output = []
  first = True
  found = False

  output.append("""<xsl:template name="otherlinks">
    <div id="otherlinks">
      <span>Resources:
        <strong>User manual</strong> |
        <a href="http://www.rudder-project.org/changelog-{$rudder.version}">Changelog</a> |
        <a href="http://www.rudder-project.org/rudder-api-doc/">API reference</a>
      </span>
      <span>Version:""")
  
  for version in versions:
    (current_version, esr) = version
    
    if esr:
      esr_text = " (ESR)"
    else:
      esr_text = ""
    
    if current_version == manual_version:
      found = True
      output.append("<strong>" + manual_version + esr_text + "</strong>")
    else:     
      output.append("<a href=\"http://www.rudder-project.org/doc-" + current_version + "/\">" + current_version + esr_text + "</a>")
  
  # Unsupported version
  if not found:
    output.append("<strong>" + manual_version + esr_text + "</strong>")
  
  output.append("""</span>
    <xsl:choose>
      <xsl:when test="$webhelp.embedded != '1'">
        <span>Download as: <a href="http://www.rudder-project.org/rudder-doc-{$rudder.version}/rudder-doc.epub">epub</a> | <a href="http://www.rudder-project.org/rudder-doc-{$rudder.version}/rudder-doc.pdf">pdf</a></span>
      </xsl:when>
      <xsl:otherwise>
        <span>Download as: <a href="http://www.rudder-project.org/rudder-doc-{$rudder.version}/rudder-doc.epub">epub</a> | <a href="rudder-doc.pdf">pdf</a></span>
      </xsl:otherwise>
    </xsl:choose>
    </div>
    </xsl:template>""")

  return " | \n".join(output) + "\n"
  

if __name__ == '__main__':
  if len(sys.argv) != 3:
    print("usage: sys.argv rudder_version xsl_path")
    sys.exit(1)

  # Write header file
  versions = get_supported_versions()

  header_file = open(sys.argv[2] + "/links.xsl", "w")
  header_file.write(beginning)
  header_file.write(format_header(versions, sys.argv[1]))
  header_file.write(end)
  header_file.close()

  version_info = get_current_version_info(sys.argv[1])

  # Write index file
  template_file = open(sys.argv[2] + "/index.html.tpl", "r")
  template = template_file.read()
  template_file.close()

  index_file = open(sys.argv[2] + "/index.html", "w")
  index_file.write(format_index(version_info, template))
  index_file.close()


  
