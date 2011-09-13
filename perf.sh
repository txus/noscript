#!/bin/bash
#
# This script runs a given command over a range of Git revisions. Note that it
# will check past revisions out! Exercise caution if there are important
# untracked files in your working tree.
#
# This came from Gary Bernhardt's dotfiles:
#     https://github.com/garybernhardt/dotfiles
#
# Example usage:
#     $ run-command-on-git-revisions origin/master master 'python runtests.py'

set -e

start_ref=$1
end_ref=$2

run_benchmarks() {
    # Get git revsA

    revs=`log_command git rev-list --reverse --abbrev-commit ${start_ref}..${end_ref}`

    # Backup current benchmarks

    if [ -e "../__perf" ]; then
      rm -fR ../__perf
    fi

    mkdir -p ../__perf/perf
    cp -r perf/* ../__perf/perf/
    cp -r perf.sh ../__perf/perf.sh

    # Remove stats file if they exist
    if [ -e "../__perf/*.csv" ]; then
      log_command rm ../__perf/*.csv
    fi

    for rev in $revs; do
        echo "Checking out: $(git log --oneline -1 $rev)"
        log_command git checkout --quiet $rev

        for f in ../__perf/perf/*_bench.rb
        do
          name=`echo "$f" | sed -e "s/\// /g" | sed -e 's/_bench\.rb/ /g' | awk '{ print $4 }'`
          echo "$name benchmarks..."

          # Replace perf directory with our own

          if [ -e "perf" ]; then
            log_command rm -fR perf
          fi
          log_command cp -r ../__perf/perf perf

          stats_filename=${name}_stats.csv

          output=`ruby perf/${name}_bench.rb`

          lexer_time=`echo "$output" | grep '^LEXER' | awk '{print $2}'`
          parser_time=`echo "$output" | grep '^PARSER' | awk '{print $2}'`
          runtime=`echo "$output" | grep '^RUNTIME' | awk '{print $2}'`
          total_time=`echo "$output" | grep '^TOTAL' | awk '{print $2}'`

          timestamp=`git log -1 --pretty="format:%ai" $rev`

          log_command echo $timestamp,$rev,$lexer_time,$parser_time,$runtime,$total_time >> ../__perf/$stats_filename
        done

        # Cleanup the mess
        git clean -fd
    done
    log_command git checkout $end_ref

    echo "Restoring benchmarks..."
    log_command cp -r ../__perf/perf perf
    log_command cp -r ../__perf/perf.sh perf.sh

    echo "OK for all revisions!"
    echo "Stats are in: `ls ../__perf/*.csv`"
}

log_command() {
    echo "=> $*" >&2
    eval $*
}

run_benchmarks
