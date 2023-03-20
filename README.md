# KodoVerdikto
Platform for coding challenges and code interviews

## Hello!
Please help to code this, any help is wanted :)

## Stack
Rails 7
- rspec
- guard
- devise
- active-admin
- active-record
- spring
- rubocop

## How to for devs

#### Project config

First set up an ssh key for you with `ssh-keygen -t rsa -b 4096` if you don't have any and clone the project with `git clone`.

Open the project with VS Code and **install the Dev Containers extension**.

Click on the green bar in the bottom-left corner and them select `Reopen in container`.

To run the server press `ctrl+B` to run the build task in vscode. Alternatively you can press `ctrl+p` and type `task ` (yes, `task` + an empty space) and select one of the custom tasks for the workspace. There is a ta

Then run `guard` on a separated terminal to automate testing, formatting and bundle gem updates.

#### ssh-forward

You may want to push commit inside dev-containers. For that, the extension already forward your local SSH agent if one is running. For more information in how to set up an ssh agent refer to [this link about sharing git credentials](https://code.visualstudio.com/remote/advancedcontainers/sharing-git-credentials) and [this link about the ssh agent itself](https://www.ssh.com/academy/ssh/agent).

In my case i just put the following inside my zprofile file:

```bash
SSH_ENV="$HOME/.ssh/agent-environment"

function start_agent {
    #echo "Initialising new SSH agent..."
    /usr/bin/ssh-agent | sed 's/^echo/#echo/' > "${SSH_ENV}"
    #echo succeeded
    chmod 600 "${SSH_ENV}"
    . "${SSH_ENV}" > /dev/null
    /usr/bin/ssh-add -q;
}

# Source SSH settings, if applicable
if [ -f "${SSH_ENV}" ]; then
    . "${SSH_ENV}" > /dev/null
    #ps ${SSH_AGENT_PID} doesn't work under cywgin
    ps -ef | grep ${SSH_AGENT_PID} | grep ssh-agent$ > /dev/null || {
        start_agent;
    }
else
    start_agent;
fi
```

#### DevContainer tips

The old cli for devcontainers was deprecated, so if you don't want to open vscode and only then reopen the code in the containers but do all together in the terminal, just download/install the [new devcontainer cli](https://github.com/devcontainers/cli) with:

```bash
npm install -g @devcontainers/cli
```

And then in the zprofile file add the following function:
```bash
function devopen() {
    local workspace_folder="$(readlink -f "$1")"

    if [ -d "$workspace_folder" ]; then
        local wsl_path="$(wslpath -w "$workspace_folder")"
        local path_id=$(printf "%s" "$wsl_path" | xxd -ps -c 256)

        code --folder-uri "vscode-remote://dev-container%2B${path_id}/$(basename "$workspace_folder")"
    else
        echo "Usage: devopen <directory>" 1>&2
        echo "" 1>&2
        echo "Error: Directory ${1@Q} does not exist" 1>&2
        false
    fi
}
```

Now you can open the code directly inside the devcontainer on the CLI with `devopen .` instead of `code .`.

It is a little gambit while [this issue](https://github.com/microsoft/vscode-remote-release/issues/2133) is not resolved.