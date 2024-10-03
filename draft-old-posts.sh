#!/bin/bash

# Log file for debugging
# LOGFILE="/var/log/draft_old_posts.log"
LOGFILE="draft_old_posts.log"

# Configuration file path
CONFIG_FILE="databases.conf"
# Function to execute SQL commands for each database
run_query() {
    local DB_GROUP=$1
    local SQL_QUERY=$2

    # Run the query using MySQL client, referencing the group in .my.cnf
    QUERY_OUTPUT=$(mysql --defaults-file=.my.cnf --defaults-group-suffix="_$DB_GROUP" "$DB_GROUP" -e "$SQL_QUERY")
    QUERY_EXIT_CODE=$?

    if [ $QUERY_EXIT_CODE -eq 0 ]; then
        # Count the number of lines in the output, excluding the header line
        ROWS_AFFECTED=$(echo "$QUERY_OUTPUT" | tail -n +2 | wc -l)
        echo "[$(date)] Query successful for $DB_GROUP." # Rows affected: $ROWS_AFFECTED" >> $LOGFILE #rows effected section only showing zero, not sure why
    else
        echo "[$(date)] Error in $DB_GROUP" >> $LOGFILE
    fi
}

# Read the configuration file line by line
while IFS='|' read -r DB_GROUP SQL_QUERY; do
    # Skip empty lines or lines starting with a comment (#)
    [[ -z "$DB_GROUP" || "$DB_GROUP" =~ ^# ]] && continue

    # Run the query for each database
    run_query "$DB_GROUP" "$SQL_QUERY"
done < "$CONFIG_FILE"

echo "[$(date)] Monthly post drafting completed." >> $LOGFILE