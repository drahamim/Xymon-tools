#!/bin/bash

cd `dirname $0`

./check_cass_java_lang.sh #2>/dev/null
./check_cass_metrics.sh
./check_cass_request.sh
./check_cass_db.sh
./check_cass_internal.sh
