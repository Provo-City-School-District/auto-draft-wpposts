#!/bin/bash

# Log file for debugging
LOGFILE="draft_old_posts.log"

# Configuration file path
CONFIG_FILE="databases.conf"

# Function to execute SQL commands for each database
run_query() {
    local DB_GROUP=$1
    local SQL_QUERY=$2

    echo "Running query for DB_GROUP: $DB_GROUP" >> $LOGFILE

    # Run the query using MySQL client, referencing the group in .my.cnf
    mysql --defaults-file=.my.cnf --defaults-group-suffix="_$DB_GROUP" "$DB_GROUP" -e "$SQL_QUERY"
    QUERY_EXIT_CODE=$?

    if [ $QUERY_EXIT_CODE -eq 0 ]; then
        echo "[$(date)] Query successful for $DB_GROUP." >> $LOGFILE
    else
        echo "[$(date)] Error in $DB_GROUP" >> $LOGFILE
    fi
}

# Read the configuration file line by line
while IFS='|' read -r DB_GROUP SQL_QUERY; do
    # Skip empty lines or lines starting with a comment (#)
    [[ -z "$DB_GROUP" || "$DB_GROUP" =~ ^# ]] && continue

    echo "Processing line: $DB_GROUP" >> $LOGFILE

    # Run the query for each database
    run_query "$DB_GROUP" "$SQL_QUERY"
done < "$CONFIG_FILE"

echo "[$(date)] Monthly post drafting completed." >> $LOGFILE