#!/bin/bash

if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <max_workers> <iterations> <command_path>"
    exit 1
fi

max_workers=$1
iterations=$2
command_path=$3

# Function to run the command in the background
run_command() {
    local cmd="$1"
    $cmd &
}1

# Function to measure total execution time in milliseconds
start_timer() {
    start_time=$(date +%s%N)
}

# Function to stop the timer and display total execution time in milliseconds
stop_timer() {
    end_time=$(date +%s%N)
    elapsed_time=$(( (end_time - start_time) / 1000000 ))
    echo "Execution time: $elapsed_time milliseconds."
    echo "Iteration $iterations with $max_workers parallelism"
}

# Function to manage workers
manage_workers() {
    local current_workers=0

    for ((i=1; i<=$iterations; i++)); do
        # Check if we can spawn more workers
        while [ "$current_workers" -lt "$max_workers" ]; do
            run_command "$command_path"
            ((current_workers++))
        done

        # Wait for all workers to finish before proceeding to the next iteration
        wait

        # Reset the worker count for the next iteration
        current_workers=0
    done
}

# Start measuring total execution time in milliseconds
start_timer

# Start managing workers
manage_workers

# Stop the timer and display total execution time in milliseconds
stop_timer
