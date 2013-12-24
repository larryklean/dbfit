#!/usr/bin/env bash

RPM_PATH=/var/dbfit
ORACLE_ENV_SCRIPT=/u01/app/oracle/product/11.2.0/xe/bin/oracle_env.sh
ORACLE_SQL_SCRIPT=/var/dbfit/dbfit-java/oracle/src/test/resources/acceptancescripts-Oracle.sql 
ORACLE_PW=oracle
ORACLE_ZIP=$(ls $RPM_PATH/oracle-xe-*.rpm.zip)
ORACLE_RPM=$(ls $RPM_PATH/Disk1/oracle-xe-*.rpm)

cd "${RPM_PATH}" || { echo "Cannot change to ${RPM_PATH} dir!"; exit 1; }

if [[ -f "$ORACLE_RPM" ]]; then
    echo "Oracle rpm found and already unzipped. Going on..."
elif [[ -f $ORACLE_ZIP ]]; then
    echo "Oracle rpm zip found. Unzipping ..."
    unzip -o $RPM_PATH/oracle-xe-*.rpm.zip
else
    echo
    echo "Go to http://www.oracle.com/technetwork/products/express-edition/downloads/index.html, download oracle-xe-*.rpm"
    echo "and put it into $RPM_PATH (= root path of dbfit git repo)"
    echo
    exit 2
fi

sudo yum install -y $RPM_PATH/Disk1/oracle-xe-*.rpm
if [[ $? != 0 ]]; then
    echo "rpm installation failed"
    exit 1
fi

sudo /etc/init.d/oracle-xe configure<<EOF
8080
1521
$ORACLE_PW
$ORACLE_PW
y
EOF

sudo -u oracle /bin/bash -c ". $ORACLE_ENV_SCRIPT; sqlplus /nolog @$ORACLE_SQL_SCRIPT"

rm -rf $RPM_PATH/Disk1

