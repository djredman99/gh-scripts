curl -s https://api.github.com/repos/actions/runner/releases/latest | grep '"tag_name":' | sed s/^.*\"\:// | cut -d\" -f2

curl -s https://api.github.com/repos/actions/runner/releases/latest | jq -r '.tag_name'

curl -s https://api.github.com/repos/actions/runner/releases/latest | grep '"tag_name":' 