
fn_exists(){ declare -f $1 >/dev/null; }

parse_flags() {  
  while (( "$#" )); do
    flag=
    case $1 in
      --)
        shift
        break
        ;;
      --*=*)
        a=${1##--}
        flag=${a%%=*};
        val=${a##*=}
        ;;
      --*)
        flag=${1/--/}
        val=$2
        ;;
      # -*)
      #   echo "short: ${1/-/}"
      #   ;;
      # *)
      #   echo "pos: $1"
      #   ;;
    esac
    echo ">> $flag -> $val" >&2
    if [[ $flag ]]; then
      if fn_exists "__handle_flag_$flag"; then
        eval "__handle_flag_$flag $val"
      else
        echo ">> invalid flag: $flag";
        exit 1
      fi
    fi
    shift
  done
  
  # return the remaining flags to the caller
  echo -n $@
}

define_flag() {
  local long_name=$1
  local default=$2
  local desc=$3
  local short_name=$4
  
  FLAGS_help_msg="$FLAGS_help_msg
  --$long_name  $desc" 
  
  eval "FLAGS_${long_name}=$default"
  
  eval "__handle_flag_${long_name}() { FLAGS_${long_name}=\$1; declare -x FLAGS_${long_name}; }"
  if [ -n "$short_name" ]; then
    eval "__handle_flag_${short_name}() { FLAGS_${long_name}=\$1; }"
  fi
}

__handle_flag_help() { echo "usage:$FLAGS_help_msg" >&2; exit 1; }
__handle_flag_h() { __handle_flag_help; }
