#!/bin/bash

#
# CIS Debian 7 Hardening
#

#
# 12.4 Verify User/Group Ownership on /etc/passwd (Scored)
#

set -e # One error, it's over
set -u # One variable unset, it's over

FILE='/etc/passwd'
USER='root'
GROUP='root'

# This function will be called if the script status is on enabled / audit mode
audit () {
    has_file_correct_ownership $FILE $USER $GROUP
    if [ $FNRET = 0 ]; then
        ok "$FILE has correct ownership"
    else
        crit "$FILE is not $USER:$GROUP ownership set"
    fi 
}

# This function will be called if the script status is on enabled mode
apply () {
    has_file_correct_ownership $FILE $USER $GROUP
    if [ $FNRET = 0 ]; then
        ok "$FILE has correct ownership"
    else
        info "fixing $FILE ownership to $USER:$GROUP"
        chown $USER:$GROUP $FILE
    fi
}

# This function will check config parameters required
check_config() {
    does_user_exist $USER
    if [ $FNRET != 0 ]; then
        crit "$USER does not exist"
        exit 128
    fi
    does_group_exist $GROUP
    if [ $FNRET != 0 ]; then
        crit "$GROUP does not exist"
        exit 128
    fi
    does_file_exist $FILE
    if [ $FNRET != 0 ]; then
        crit "$FILE does not exist"
        exit 128
    fi
}

# Source Root Dir Parameter
if [ ! -r /etc/default/cis-hardenning ]; then
    echo "There is no /etc/default/cis-hardenning file, cannot source CIS_ROOT_DIR variable, aborting"
    exit 128
else
    . /etc/default/cis-hardenning
    if [ -z $CIS_ROOT_DIR ]; then
        echo "No CIS_ROOT_DIR variable, aborting"
    fi
fi 

# Main function, will call the proper functions given the configuration (audit, enabled, disabled)
[ -r $CIS_ROOT_DIR/lib/main.sh ] && . $CIS_ROOT_DIR/lib/main.sh