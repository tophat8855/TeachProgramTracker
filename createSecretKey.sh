#!/bin/bash
#This file is used to create a secret key which can be loaded into secret.yml
#secret.yml itself should not contain any secret information, but will refer to #other systemenvs.


#If you already have a secret key, don't run this.
#Instead, just export the key to SECRET_KEY_BASE

export SECRET_KEY_BASE=$(rake secret)
printenv | grep SECRET_KEY_BASE
