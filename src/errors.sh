function AppNotFound() {
    echo '{"items": [
    {
        "uid": "",
        "type": "",
        "title": "Visual Studio Code is not installed",
        "subtitle": "Please check that if Visual Studio Code APP is already installed.",
        "arg": "",
        "icon": {
            "path": "./warning.png"
        },
        "autocomplete": "",
    }]}'
}

function CommandLineNotFound() {
    echo '{"items": [
    {
        "uid": "",
        "type": "",
        "title": "Can'\''t find command line launcher for 'code'",
        "subtitle": "You need to manually run the Shell Command: Install 'code' command in PATH command",
        "arg": "",
        "icon": {
            "path": "./warning.png"
        },
        "autocomplete": "",
    }]}'
}

function UnSupportVersion() {
    echo '{"items": [
    {
        "uid": "",
        "type": "",
        "title": "Not supported the version of Visual Studio Code",
        "subtitle": "This version of Visual studio Code is not supported, Please use 1.118.0 or later.",
        "arg": "",
        "icon": {
            "path": "./warning.png"
        },
        "autocomplete": "",
    }]}'
}

