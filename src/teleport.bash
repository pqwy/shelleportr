
#
# Teleport snippets.
# * `j` shell function performs quick jumps.
# * `_teleport_add_curdir` upvotes $(pwd) as part of PROMPT_COMMAND.
#

function j {
  path=$(teleport ${1} 2>/dev/null)
  if [[ -d "${path}" ]]; then
    echo "${path}"
    cd "${path}"
  fi
}

function _teleport_add_curdir {
  teleport -a
}

case $PROMPT_COMMAND in
  *_teleport_add_curdir*)
    ;;
  '')
    PROMPT_COMMAND='_teleport_add_curdir'
    ;;
  *)
    PROMPT_COMMAND="$(awk '{gsub(/; *$/,"")}1' <<< ${PROMPT_COMMAND}) ; _teleport_add_curdir"
esac

