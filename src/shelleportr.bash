
#
# Shelleportr snippets.
# * `j` shell function performs quick jumps.
# * `_shelleportr_add_curdir` upvotes $(pwd) as part of PROMPT_COMMAND.
#

function j {
  path=$(shelleportr ${1} 2>/dev/null)
  if [[ -d "${path}" ]]; then
    echo "${path}"
    cd "${path}"
  fi
}

function _shelleportr_add_curdir {
  shelleportr -a
}

case $PROMPT_COMMAND in
  *_shelleportr_add_curdir*)
    ;;
  '')
    PROMPT_COMMAND='_shelleportr_add_curdir'
    ;;
  *)
    PROMPT_COMMAND="$(awk '{gsub(/; *$/,"")}1' <<< ${PROMPT_COMMAND}) ; _shelleportr_add_curdir"
esac

