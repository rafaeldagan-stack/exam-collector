#!/bin/bash

# Check arguments
if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Usage: $0 {home|lab} HH:MM"
    echo "Example: $0 home 10:50"
    echo "Example: $0 lab 14:30"
    exit 1
fi

ENVIRONMENT="$1"
EXAM_TIME="$2"

# Validate environment
if [ "$ENVIRONMENT" != "home" ] && [ "$ENVIRONMENT" != "lab" ]; then
    echo "Environment must be home or lab"
    exit 1
fi

# Split HH:MM into hour and minute
HOUR=$(echo "$EXAM_TIME" | cut -d: -f1)
MINUTE=$(echo "$EXAM_TIME" | cut -d: -f2)

# Get today's date
DAY=$(date +%d)
MONTH=$(date +%m)

# Command that will run at exam end
COMMAND="/home/rafi/exam-collector/run-collector.sh $ENVIRONMENT >> /home/rafi/exam-collector/exam-scheduler.log 2>&1"

# Add the job to cron
(crontab -l 2>/dev/null; echo "$MINUTE $HOUR $DAY $MONTH * $COMMAND") | crontab -

echo "Exam collection scheduled for $ENVIRONMENT today at $EXAM_TIME"
