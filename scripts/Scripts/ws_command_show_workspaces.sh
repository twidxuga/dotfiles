#!/bin/sh
# Modified from https://github.com/i3/i3/issues/3818
# The while loop in those examples didn't work!
function i3_get_workspaces {
  i3-msg -t get_workspaces | sed -e 's/\"output\":\"[^\"]*\"/\"output":\"primary\"/g'
}

i3_get_workspaces
i3-msg -t subscribe -m '["workspace"]' | while read
do 
  i3_get_workspaces
done 

### Additional examples from the URL

# # Default command
# #!/bin/sh
# i3-msg -t subscribe -m '["workspace"]' | {
# 	i3-msg -t get_workspaces;
# 	while read; do i3-msg -t get_workspaces; done;
# }

# # hide workspace named foo unless it is visible.
# #!/bin/sh
# i3-msg -t subscribe -m '["workspace"]' | {
# 	i3-msg -t get_workspaces;
# 	while read; do i3-msg -t get_workspaces; done;
# } | jq -c '[ .[] | select(.name != "foo" or .visible) ]'

# # show empty workspaces foo and bar on LVDS1 even if they do not exist at the moment.
# #!/bin/sh
# i3-msg -t subscribe -m '["workspace"]' | {
# 	i3-msg -t get_workspaces;
# 	while read; do i3-msg -t get_workspaces; done;
# } | jq -c '
# 	def fake_ws(name): {
# 		num: -1, name: name,
# 		visible: false,
# 		focused: false,
# 		urgent: false,
# 		output: "LVDS1",
# 		"colors":["#191919", "#111111", "#444444"], # dimmed inactive_workspace
# 	};
# 	. + [ fake_ws("foo"), fake_ws("bar") ] | unique_by(.name)
# '

