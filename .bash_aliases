#
# az*
alias azoj="az config set core.output=jsonc >/dev/null 2>&1; echo 'az cli default output set to: jsonc'"
alias azoy="az config set core.output=yamlc >/dev/null 2>&1; echo 'az cli default output set to: yamlc'"
alias azot="az config set core.output=table >/dev/null 2>&1; echo 'az cli default output set to: table'"

#
# aw*
alias awc='arrange-windows code'
alias awjb='arrange-windows "JetBrains Rider"'

#
# cd(n) - cd is aliased to zoxide's 'z' via zoxide init --cmd cd in .bashrc
alias cd1="cd .."
alias cd2="cd ../../"
alias cd3="cd ../../../"
alias cd4="cd ../../../../"
alias cd5="cd ../../../../../"

# cc
# cc: claude with bypass permissions (uses Max Pro subscription, not API tokens)
# Usage: cc              - interactive claude (bypass mode)
#        cc -p "prompt"  - launch in tmux, auto-send prompt
cc() {
    if [[ "$1" == "-p" && -n "$2" ]]; then
        local prompt="$2"
        local session="cc-$(date +%s)"
        # Create detached tmux session running claude
        tmux new-session -d -s "$session" "claude --dangerously-skip-permissions"
        # Wait for claude to be ready (look for the ">" prompt)
        local attempts=0
        while [[ $attempts -lt 20 ]]; do
            if tmux capture-pane -t "$session" -p 2>/dev/null | grep -q ">"; then
                break
            fi
            sleep 0.5
            ((attempts++))
        done
        # Send the prompt as literal text, then Enter
        tmux send-keys -t "$session" -l "$prompt"
        tmux send-keys -t "$session" Enter
        # Attach to the session
        tmux attach -t "$session"
    else
        claude --dangerously-skip-permissions "$@"
    fi
}

# d*
alias d='docker'
alias dc='d container'
alias dcl='dps'
alias dcll='dps -a'
alias di='d image'
alias dil='d image ls'
alias dill='d image ls -a'
alias dps='d ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}"'

# dotfiles-update
if [[ $OSTYPE == 'darwin'* ]]; then alias dotfiles-update='cd ~ && curl -L https://raw.githubusercontent.com/spraguehouse/dotfiles/main/scripts/setup-dotfiles.zsh -o setup-dotfiles.zsh && source setup-dotfiles.zsh'
else alias dotfiles-update='cd ~ && curl -L https://raw.githubusercontent.com/spraguehouse/dotfiles/main/scripts/setup-dotfiles.bash -o setup-dotfiles.bash && source setup-dotfiles.bash'
fi

# flushdns
alias flushdns='sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder'

# ghpr* (gh pull request)
# Creates per-scope PRs from dev→main with auto-generated squash commit titles.
# Commits are grouped by conventional commit scope, cherry-picked onto merge/<scope>
# branches from main, and opened as individual PRs in the browser.
ghprdevtomain() {
    git fetch origin main dev --quiet 2>/dev/null

    # Guard: if main has commits not in dev, sync first to avoid duplicate cherry-picks
    local main_ahead
    main_ahead=$(git rev-list --count origin/dev..origin/main 2>/dev/null || echo 0)
    if [[ "$main_ahead" -gt 0 ]]; then
        echo "main is ${main_ahead} commit(s) ahead of dev (likely from prior squash merges)."
        echo "Sync first: ghprdevsync"
        return 1
    fi

    # Use ancestry-path from merge-base to exclude commits already squash-merged.
    # After merging main into dev, commits before the sync point are not descendants
    # of the merge-base and are automatically excluded.
    local merge_base
    merge_base=$(git merge-base origin/main origin/dev)

    local commits
    commits=$(git log --ancestry-path --no-merges --format="%H %s" --reverse ${merge_base}..origin/dev)
    if [[ -z "$commits" ]]; then
        # Check if there are actual file differences (commits made before sync)
        local has_diff
        has_diff=$(git diff --stat origin/main..origin/dev 2>/dev/null)
        if [[ -n "$has_diff" ]]; then
            echo "No ancestry-path commits, but dev has changes vs main:"
            echo "$has_diff"
            echo ""
            echo "This happens when commits were made BEFORE syncing dev with main."
            echo "The --ancestry-path filter excludes pre-sync commits."
            echo ""
            echo "Options:"
            echo "  1. Create PR manually:"
            echo "     gh pr create --base main --head dev --title \"fix(scope): description\""
            echo ""
            echo "  2. See all commits (may include already-released):"
            echo "     git log --no-merges --oneline origin/main..origin/dev"
            return 1
        fi
        echo "No commits on dev ahead of main. Nothing to PR."
        return 1
    fi

    echo "Commits on dev → main:"
    echo "────────────────────────────────"
    git log --ancestry-path --no-merges --oneline --reverse ${merge_base}..origin/dev
    echo "────────────────────────────────"
    echo ""

    # Warn about scopeless commits (excluded from PRs)
    local scopeless
    scopeless=$(echo "$commits" | grep -vE '^[a-f0-9]+ [a-z]+!?\([^)]+\):')
    if [[ -n "$scopeless" ]]; then
        echo "WARNING: commits without scope (excluded from PRs):"
        echo "$scopeless" | awk '{hash=substr($1,1,8); $1=""; sub(/^ /,""); print "  " hash " " $0}'
        echo ""
    fi

    # Extract unique scopes
    local scopes
    scopes=$(echo "$commits" | sed -nE 's/^[a-f0-9]+ [a-z]+!?\(([^)]+)\):.*/\1/p' | sort -u)
    if [[ -z "$scopes" ]]; then
        echo "No conventional commit scopes found. Cannot auto-split."
        return 1
    fi

    # Type priority (highest first)
    local -a type_pri=('feat!' feat fix perf refactor chore docs style test ci build)

    # --- Single scope: direct merge (preserves original SHAs) ---
    local scope_count
    scope_count=$(echo "$scopes" | wc -l | tr -d ' ')
    if [[ "$scope_count" -eq 1 ]]; then
        local scope types best_type msgs title_msg title
        scope=$(echo "$scopes" | head -1)
        types=$(echo "$commits" | sed -E 's/^[a-f0-9]+ ([a-z]+!?)\(.*/\1/')
        best_type=""
        for t in "${type_pri[@]}"; do
            if echo "$types" | grep -qx "$t"; then best_type="$t"; break; fi
        done
        [[ -z "$best_type" ]] && best_type=$(echo "$types" | head -1)
        msgs=$(echo "$commits" | grep -F "${best_type}(${scope}):" | sed -E "s/^[a-f0-9]+ [a-z]+!?\([^)]+\): //")
        title_msg=$(echo "$msgs" | paste -sd ", " -)
        title="${best_type}(${scope}): ${title_msg}"

        echo "Single scope detected — direct dev→main merge (no cherry-pick)."
        echo ""
        echo "PR title: ${title}"
        echo ""
        printf "Create PR and open in browser? [Y/n] "
        read confirm
        if [[ "$confirm" =~ ^[Nn]$ ]]; then
            echo "Aborted."
            return 1
        fi

        git push origin dev --quiet 2>/dev/null
        gh pr create --base main --head dev --title "$title" --body "## Commits
$(echo "$commits" | awk '{hash=substr($1,1,8); $1=""; sub(/^ /,""); print "- " hash " " $0}')" --web
        echo ""
        echo "Done. Regular-merge the PR in browser (preserves commit history)."
        echo "Then run: ghprdevsync"
        return 0
    fi

    # --- Multiple scopes: cherry-pick per scope ---
    echo "Planned PRs:"
    while IFS= read -r scope; do
        local scope_commits types best_type msgs title_msg
        scope_commits=$(echo "$commits" | grep -F "(${scope}):")
        types=$(echo "$scope_commits" | sed -E 's/^[a-f0-9]+ ([a-z]+!?)\(.*/\1/')
        best_type=""
        for t in "${type_pri[@]}"; do
            if echo "$types" | grep -qx "$t"; then best_type="$t"; break; fi
        done
        [[ -z "$best_type" ]] && best_type=$(echo "$types" | head -1)
        msgs=$(echo "$scope_commits" | grep -F "${best_type}(${scope}):" | sed -E "s/^[a-f0-9]+ [a-z]+!?\([^)]+\): //")
        title_msg=$(echo "$msgs" | paste -sd ", " -)
        echo "  ${best_type}(${scope}): ${title_msg}"
    done <<< "$scopes"

    echo ""
    printf "Create PRs and open in browser? [Y/n] "
    read confirm
    if [[ "$confirm" =~ ^[Nn]$ ]]; then
        echo "Aborted."
        return 1
    fi

    # --- Execute phase ---
    local original_branch
    original_branch=$(git branch --show-current)

    while IFS= read -r scope; do
        local scope_commits hashes types best_type msgs title_msg title body_lines body branch
        scope_commits=$(echo "$commits" | grep -F "(${scope}):")
        hashes=$(echo "$scope_commits" | awk '{print $1}')
        types=$(echo "$scope_commits" | sed -E 's/^[a-f0-9]+ ([a-z]+!?)\(.*/\1/')
        best_type=""
        for t in "${type_pri[@]}"; do
            if echo "$types" | grep -qx "$t"; then best_type="$t"; break; fi
        done
        [[ -z "$best_type" ]] && best_type=$(echo "$types" | head -1)
        msgs=$(echo "$scope_commits" | grep -F "${best_type}(${scope}):" | sed -E "s/^[a-f0-9]+ [a-z]+!?\([^)]+\): //")
        title_msg=$(echo "$msgs" | paste -sd ", " -)
        title="${best_type}(${scope}): ${title_msg}"

        body_lines=$(echo "$scope_commits" | awk '{hash=substr($1,1,8); $1=""; sub(/^ /,""); print "- " hash " " $0}')
        body="## Commits
${body_lines}"

        branch="merge/${scope}"
        echo "Creating ${branch}..."
        git branch -D "$branch" 2>/dev/null || true
        git checkout -b "$branch" origin/main --quiet

        while IFS= read -r hash; do
            if ! git cherry-pick "$hash" --quiet 2>/dev/null; then
                echo "  ERROR: cherry-pick failed for $(echo $hash | cut -c1-8)"
                git cherry-pick --abort 2>/dev/null
                git checkout "${original_branch:-dev}" --quiet 2>/dev/null
                return 1
            fi
        done <<< "$hashes"

        git push origin "$branch" --force --quiet 2>/dev/null
        gh pr create --base main --head "$branch" --title "$title" --body "$body" --web
        echo "  Created: ${title}"
    done <<< "$scopes"

    git checkout "${original_branch:-dev}" --quiet 2>/dev/null
    echo ""
    echo "Done. Squash-merge each PR in the browser."
    echo "Then run: ghprdevsync"
}

# Sync dev with main after squash-merge PRs land.
# Merges main into dev so the merge-base advances past already-squashed commits.
# ghprdevtomain uses --ancestry-path from the merge-base, which automatically
# excludes pre-sync commits (they aren't descendants of the new merge-base).
ghprdevsync() {
    git fetch origin main dev --quiet 2>/dev/null

    local main_ahead
    main_ahead=$(git rev-list --count origin/dev..origin/main 2>/dev/null || echo 0)
    if [[ "$main_ahead" -eq 0 ]]; then
        echo "dev is already up to date with main."
    else
        echo "Merging ${main_ahead} commit(s) from main into dev..."
        git checkout dev --quiet
        git merge origin/main --no-edit
        git push origin dev --quiet
        echo "dev synced with main."
    fi

    # Clean up merge/ branches (local and remote)
    local merge_branches
    merge_branches=$(git branch --list 'merge/*' 2>/dev/null)
    if [[ -n "$merge_branches" ]]; then
        echo "Cleaning up local merge branches..."
        echo "$merge_branches" | while IFS= read -r b; do
            b=$(echo "$b" | tr -d ' *')
            git branch -D "$b" 2>/dev/null && echo "  Deleted local: $b"
        done
    fi

    local remote_merge_branches
    remote_merge_branches=$(git branch -r --list 'origin/merge/*' 2>/dev/null)
    if [[ -n "$remote_merge_branches" ]]; then
        echo "Cleaning up remote merge branches..."
        echo "$remote_merge_branches" | while IFS= read -r b; do
            b=$(echo "$b" | tr -d ' *' | sed 's|^origin/||')
            git push origin --delete "$b" --quiet 2>/dev/null && echo "  Deleted remote: $b"
        done
    fi

    echo "Done."
}

# g* (git)
alias gp='git push --follow-tags origin main'

#
# k*
alias k='kubectl'
alias ks='echo -e "context: $(k config current-context)\nnamespace: $(k config view --minify --output jsonpath={..namespace})"'
alias kc='kubechoose'
alias kns='f(){ k config set-context --current --namespace="$@"; unset -f f; }; f'
alias kga='kubectl get all,cm,secret,ing'
if [[ $SHELL != '/bin/zsh'* ]]; then complete -F __start_kubectl k; fi

#
# l*
if [[ $OSTYPE == 'darwin'* ]]; then alias l="ls -cl -hp --color=always"
else alias l="ls -cl -hp --time-style=long-iso --group-directories-first --color=always"; fi
alias ll="l -a"

# ma-observe (multi-agent observability)
alias ma-observe='f(){ if [ "$1" = "start" ]; then ~/.claude/observability/start.sh; elif [ "$1" = "stop" ]; then ~/.claude/observability/stop.sh; elif [ "$1" = "logs" ]; then tail -f ~/.claude/observability/server.log; elif [ "$1" = "dashboard" ]; then open http://localhost:5173; else echo "Usage: ma-observe [start|stop|logs|dashboard]"; fi; unset -f f; }; f'

# mk
alias mk='minikube'

# open
if [[ $OSTYPE != 'darwin'* ]]; then alias open="xdg-open"; fi

# p
alias p='python'

# path
alias path='echo -e ${PATH//:/\\n}'

## ssha
alias ssha='eval $(ssh-agent) && ssh-add'

# start
start() { nohup $1 &> /dev/null & disown; }

# sv*
alias sv='standard-version'
alias svp='sv; git push --follow-tags origin main'

# tree
alias tree='tree -I ".git|node_modules"'

# uuidgen
if [[ $OSTYPE == 'darwin'* ]]; then alias uuidgen='uuidgen | tr A-F a-f'; fi
