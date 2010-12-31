#!/bin/sh

function co()
{
    if [ -d libs/$2 ]; then
        svn update libs/$2
    else
        svn co $1 libs/$2
    fi
}

if [ ! -d libs ]; then
    mkdir libs
fi
co 'svn://svn.wowace.com/wow/ace3/mainline/trunk/LibStub' 'LibStub'
co 'svn://svn.wowace.com/wow/ace3/mainline/trunk/CallbackHandler-1.0' 'CallbackHandler-1.0'
co 'svn://svn.wowace.com/wow/ace3/mainline/trunk/AceAddon-3.0' 'AceAddon-3.0'
co 'svn://svn.wowace.com/wow/ace3/mainline/trunk/AceEvent-3.0' 'AceEvent-3.0'

