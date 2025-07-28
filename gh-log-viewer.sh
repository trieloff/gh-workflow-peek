#!/bin/bash

# Default values
CONTEXT=0
MAX=100
FROM=0
UPTO=0
MATCH=""
RUN_ID=""
REPO=""
JOB=""

# Get default repo from current directory
DEFAULT_REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner 2>/dev/null || echo "")
REPO="$DEFAULT_REPO"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --id)
            RUN_ID="$2"
            shift 2
            ;;
        --job|-j)
            JOB="$2"
            shift 2
            ;;
        --context|-c)
            CONTEXT="$2"
            shift 2
            ;;
        --max|-m)
            MAX="$2"
            shift 2
            ;;
        --from|-f)
            FROM="$2"
            shift 2
            ;;
        --upto|-u)
            UPTO="$2"
            shift 2
            ;;
        --match|-p)
            MATCH="$2"
            shift 2
            ;;
        --repo|-r)
            REPO="$2"
            shift 2
            ;;
        --help|-h)
            echo "GitHub Actions Log Viewer"
            echo ""
            echo "Usage: $0 [OPTIONS] [RUN_ID]"
            echo ""
            echo "Options:"
            echo "  --id RUN_ID          GitHub Actions run ID (or provide as first positional arg)"
            echo "  --job, -j JOB        Select job by index (3), ID (32141145124), or name (\"Python on Windows\")"
            echo "  --context, -c NUM    Lines of context around matches (default: 0)"
            echo "  --max, -m NUM        Maximum lines to show (default: 100)"
            echo "  --from, -f NUM       Start from line NUM (default: 0 = beginning)"
            echo "  --upto, -u NUM       End at line NUM (default: 0 = end)"
            echo "  --match, -p PATTERN  Custom pattern to search (highest priority)"
            echo "  --repo, -r REPO      Repository (default: current directory's repo)"
            echo "  --help, -h           Show this help message"
            echo ""
            echo "Severity levels (in priority order):"
            echo "  1. Custom match (--match)"
            echo "  2. fatal (red)"
            echo "  3. error (orange)"
            echo "  4. warn/warning (yellow)"
            echo "  5. fail/failed (yellow)"
            echo "  6. assert (magenta)"
            echo "  7. exception/traceback (cyan)"
            echo ""
            echo "Examples:"
            echo "  $0 16566617599"
            echo "  $0 --id 16566617599 --job 3"
            echo "  $0 --id 16566617599 --job \"Test Python on Windows\""
            echo "  $0 --id 16566617599 --match 'transaction_rollback' --max 50"
            exit 0
            ;;
        *)
            # Assume it's the run ID if not recognized
            if [[ -z "$RUN_ID" ]]; then
                RUN_ID="$1"
            fi
            shift
            ;;
    esac
done

# Check if REPO is set
if [[ -z "$REPO" ]]; then
    echo "Error: Could not determine repository. Please specify with --repo or run from a git repository"
    exit 1
fi

# Check if RUN_ID is provided
if [[ -z "$RUN_ID" ]]; then
    echo -e "${BOLD}No run ID specified. Looking for candidates...${NC}\n"

    # First try PR checks
    PR_CHECKS_JSON=$(gh pr checks --json name,state,link 2>/dev/null)

    if [[ -n "$PR_CHECKS_JSON" ]]; then
        # Filter for failed or pending checks
        FILTERED_CHECKS=$(echo "$PR_CHECKS_JSON" | jq -r '.[] | select(.state == "PENDING" or .state == "FAILURE") | "\(.name)\t\(.state)\t\(.link)"' | head -5)

        if [[ -n "$FILTERED_CHECKS" ]]; then
            echo -e "${BOLD}PR checks (failed/pending):${NC}"
            echo "$FILTERED_CHECKS" | column -t -s $'\t'
            echo ""

            # Extract the first failed/pending run ID from the link
            FIRST_LINK=$(echo "$FILTERED_CHECKS" | head -1 | awk -F'\t' '{print $3}')
            if [[ -n "$FIRST_LINK" ]]; then
                # Extract run ID from URL like https://github.com/owner/repo/actions/runs/123456/job/789
                FIRST_RUN_ID=$(echo "$FIRST_LINK" | grep -oE '/runs/[0-9]+' | cut -d'/' -f3)
                if [[ -n "$FIRST_RUN_ID" ]]; then
                    echo -e "${YELLOW}Auto-peeking run $FIRST_RUN_ID with --max 20...${NC}\n"
                    exec "$0" "$FIRST_RUN_ID" --max 20 "${@}"
                fi
            fi
        fi
    else
        # Fallback to recent failed runs
        echo -e "${BOLD}No PR checks found. Recent failed workflow runs:${NC}"

        # Get recent failed runs
        FAILED_RUNS=$(gh run list --status failure --limit 10 --json databaseId,displayTitle,workflowName,conclusion,createdAt | \
            jq -r '.[] | "\(.databaseId)\t\(.workflowName)\t\(.displayTitle)\t\(.createdAt)"' | \
            column -t -s $'\t')

        if [[ -n "$FAILED_RUNS" ]]; then
            echo "$FAILED_RUNS" | head -10
            echo ""

            # Extract the first run ID
            FIRST_RUN_ID=$(echo "$FAILED_RUNS" | head -1 | awk '{print $1}')
            if [[ -n "$FIRST_RUN_ID" ]]; then
                echo -e "${YELLOW}Auto-peeking run $FIRST_RUN_ID with --max 20...${NC}\n"
                exec "$0" "$FIRST_RUN_ID" --max 20 "${@}"
            fi
        else
            echo "No failed workflow runs found."
            echo ""
            echo "Usage: $0 <RUN_ID> [OPTIONS]"
            echo "To specify a workflow run, use: $0 --id <RUN_ID>"
            echo "Or provide the run ID as the first argument: $0 <RUN_ID>"
            exit 1
        fi
    fi
fi

# Get all jobs for the run
echo "Fetching jobs for run $RUN_ID..."
JOBS_JSON=$(gh api "repos/$REPO/actions/runs/$RUN_ID/jobs" --jq '.jobs')

# Extract failed jobs
FAILED_JOBS=$(echo "$JOBS_JSON" | jq -r '.[] | select(.conclusion == "failure") | "\(.id)|\(.name)"')

if [[ -z "$FAILED_JOBS" ]]; then
    echo "No failed jobs found in run $RUN_ID"
    exit 0
fi

# Convert to arrays
IFS=$'\n' read -r -d '' -a FAILED_JOB_ARRAY <<< "$FAILED_JOBS"

# Display failed jobs
echo -e "\n${BOLD}Failed Jobs:${NC}"
INDEX=1
for job_info in "${FAILED_JOB_ARRAY[@]}"; do
    IFS='|' read -r job_id job_name <<< "$job_info"
    echo -e "  ${INDEX}. [${job_id}] ${job_name}"
    INDEX=$((INDEX + 1))
done

# Select job based on --job parameter
SELECTED_JOB_ID=""
SELECTED_JOB_NAME=""

if [[ -z "$JOB" ]]; then
    # Default to first failed job
    IFS='|' read -r SELECTED_JOB_ID SELECTED_JOB_NAME <<< "${FAILED_JOB_ARRAY[0]}"
    echo -e "\n${YELLOW}➤ Showing logs for job 1: ${SELECTED_JOB_NAME}${NC}"
else
    # Check if JOB is a number (index)
    if [[ "$JOB" =~ ^[0-9]+$ ]] && [[ ${#JOB} -le 3 ]]; then
        # It's an index
        JOB_INDEX=$((JOB - 1))
        if [[ $JOB_INDEX -ge 0 ]] && [[ $JOB_INDEX -lt ${#FAILED_JOB_ARRAY[@]} ]]; then
            IFS='|' read -r SELECTED_JOB_ID SELECTED_JOB_NAME <<< "${FAILED_JOB_ARRAY[$JOB_INDEX]}"
            echo -e "\n${YELLOW}➤ Showing logs for job $JOB: ${SELECTED_JOB_NAME}${NC}"
        else
            echo "Error: Job index $JOB is out of range (1-${#FAILED_JOB_ARRAY[@]})"
            exit 1
        fi
    elif [[ "$JOB" =~ ^[0-9]+$ ]]; then
        # It's a job ID
        for job_info in "${FAILED_JOB_ARRAY[@]}"; do
            IFS='|' read -r job_id job_name <<< "$job_info"
            if [[ "$job_id" == "$JOB" ]]; then
                SELECTED_JOB_ID="$job_id"
                SELECTED_JOB_NAME="$job_name"
                echo -e "\n${YELLOW}➤ Showing logs for job: ${SELECTED_JOB_NAME}${NC}"
                break
            fi
        done
        if [[ -z "$SELECTED_JOB_ID" ]]; then
            echo "Error: Job ID $JOB not found in failed jobs"
            exit 1
        fi
    else
        # It's a job name (partial match)
        for job_info in "${FAILED_JOB_ARRAY[@]}"; do
            IFS='|' read -r job_id job_name <<< "$job_info"
            if [[ "$job_name" == *"$JOB"* ]]; then
                SELECTED_JOB_ID="$job_id"
                SELECTED_JOB_NAME="$job_name"
                echo -e "\n${YELLOW}➤ Showing logs for job: ${SELECTED_JOB_NAME}${NC}"
                break
            fi
        done
        if [[ -z "$SELECTED_JOB_ID" ]]; then
            echo "Error: No job found matching '$JOB'"
            exit 1
        fi
    fi
fi

echo ""

# Get logs for the selected job and process
gh run view "$RUN_ID" --job "$SELECTED_JOB_ID" --log --repo "$REPO" 2>/dev/null | \
awk -v context="$CONTEXT" -v max="$MAX" -v from="$FROM" -v upto="$UPTO" -v pattern="$MATCH" '
BEGIN {
    # Color codes
    RED = "\033[0;31m"
    ORANGE = "\033[0;33m"
    YELLOW = "\033[1;33m"
    MAGENTA = "\033[0;35m"
    CYAN = "\033[0;36m"
    BLUE = "\033[0;34m"
    NC = "\033[0m"
    BOLD = "\033[1m"

    # Severity patterns and priorities (0 = highest)
    severity[0] = "custom"; colors[0] = BLUE; names[0] = "match"
    severity[1] = "fatal"; colors[1] = RED; names[1] = "fatal"
    severity[2] = "error"; colors[2] = ORANGE; names[2] = "error"
    severity[3] = "warn|warning"; colors[3] = YELLOW; names[3] = "warn"
    severity[4] = "fail|failed"; colors[4] = YELLOW; names[4] = "fail"
    severity[5] = "assert"; colors[5] = MAGENTA; names[5] = "assert"
    severity[6] = "exception|traceback"; colors[6] = CYAN; names[6] = "exception"

    total_lines = 0
    header_lines = int(max / 10)
    footer_lines = int(max / 10)
    middle_lines = max - header_lines - footer_lines
}

# Store all lines (strip existing ANSI color codes)
{
    total_lines++
    # Remove ANSI escape sequences
    gsub(/\033\[[0-9;]*m/, "", $0)
    lines[NR] = $0
}

END {
    # Apply FROM/UPTO filtering
    start = (from > 0) ? from : 1
    end = (upto > 0) ? upto : total_lines

    # First pass: find all matches with severity
    for (i = start; i <= end && i <= total_lines; i++) {
        line = tolower(lines[i])
        matched = 0

        # Check custom match first (highest priority)
        if (pattern != "" && match(line, tolower(pattern))) {
            severity_counts[0]++
            severity_matches[0, severity_counts[0]] = i
            matched = 1
        } else {
            # Check other severities
            for (s = 1; s <= 6; s++) {
                if (match(line, severity[s])) {
                    severity_counts[s]++
                    severity_matches[s, severity_counts[s]] = i
                    matched = 1
                    break
                }
            }
        }
    }

    # Print header
    for (i = start; i < start + header_lines && i <= end; i++) {
        printf "%4d: %s\n", i, lines[i]
    }

    print "===="

    # Build a sorted list of all matches with their severity
    match_count = 0
    for (s = 0; s <= 6; s++) {
        for (m = 1; m <= severity_counts[s]; m++) {
            line_num = severity_matches[s, m]
            # Skip if in header/footer zones
            if (line_num < start + header_lines || line_num > end - footer_lines) continue

            match_count++
            all_matches[match_count] = line_num
            all_severities[match_count] = s
        }
    }

    # Sort matches first by severity, then by line number
    for (i = 1; i <= match_count; i++) {
        for (j = i + 1; j <= match_count; j++) {
            if (all_severities[i] > all_severities[j] ||
                (all_severities[i] == all_severities[j] && all_matches[i] > all_matches[j])) {
                # Swap
                temp_line = all_matches[i]
                temp_sev = all_severities[i]
                all_matches[i] = all_matches[j]
                all_severities[i] = all_severities[j]
                all_matches[j] = temp_line
                all_severities[j] = temp_sev
            }
        }
    }

    # Print sorted matches
    lines_printed = 0
    last_printed_line = 0

    for (m = 1; m <= match_count && lines_printed < middle_lines; m++) {
        line_num = all_matches[m]
        s = all_severities[m]
        color = colors[s]

        # Initialize severity_shown if needed
        if (!(s in severity_shown)) severity_shown[s] = 0

        # Calculate context range
        ctx_start = line_num - context
        if (ctx_start < start + header_lines) ctx_start = start + header_lines
        ctx_end = line_num + context
        if (ctx_end > end - footer_lines) ctx_end = end - footer_lines

        # Print separator if needed
        if (last_printed_line > 0 && ctx_start > last_printed_line + 1) {
            print "..."
        }

        # Track if we actually showed this match
        match_shown = 0

        # Print context
        for (i = ctx_start; i <= ctx_end && lines_printed < middle_lines; i++) {
            if (i <= last_printed_line) continue

            if (i == line_num) {
                # Highlight the matching line
                printf "%s%s%4d: %s%s\n", BOLD, color, i, lines[i], NC
                match_shown = 1
            } else {
                # Context line
                printf "%4d: %s\n", i, lines[i]
            }
            lines_printed++
        }

        last_printed_line = ctx_end
        if (match_shown) severity_shown[s]++
    }

    # Print remaining counts
    print ""
    for (s = 0; s <= 6; s++) {
        if (severity_counts[s] > 0) {
            # Calculate actual remaining unshown matches
            remaining = severity_counts[s] - severity_shown[s]
            if (remaining > 0) {
                printf "- %d more %s\n", remaining, names[s]
            }
        }
    }

    print "==="

    # Print footer
    for (i = end - footer_lines + 1; i <= end; i++) {
        if (i >= start) {
            printf "%4d: %s\n", i, lines[i]
        }
    }
}'
