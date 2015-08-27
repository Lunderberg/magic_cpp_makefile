# Define all the colors I'll need

NO_COLOR   = \033[m

BLUE       = \033[1;34m
YELLOW     = \033[1;33m
GREEN      = \033[1;32m
RED        = \033[1;31m
BLACK      = \033[1;30m
MAGENTA    = \033[1;35m
CYAN       = \033[1;36m
WHITE      = \033[1;37m

DBLUE      = \033[0;34m
DYELLOW    = \033[0;33m
DGREEN     = \033[0;32m
DRED       = \033[0;31m
DBLACK     = \033[0;30m
DMAGENTA   = \033[0;35m
DCYAN      = \033[0;36m
DWHITE     = \033[0;37m

BG_WHITE   = \033[47m
BG_RED     = \033[41m
BG_GREEN   = \033[42m
BG_YELLOW  = \033[43m
BG_BLUE    = \033[44m
BG_MAGENTA = \033[45m
BG_CYAN    = \033[46m

# Define the colors to be used in run_and_test

COM_COLOR   = $(DBLUE)
OBJ_COLOR   = $(DCYAN)
OK_COLOR    = $(DGREEN)
ERROR_COLOR = $(DRED)
WARN_COLOR  = $(DYELLOW)

OK_STRING    = "[OK]"
ERROR_STRING = "[ERROR]"
WARN_STRING  = "[WARNING]"

ifdef VERBOSE

    define run_and_test
        echo "$(1)"
        mkdir -p $(@D)
        $(1)
    endef

else

    define run_and_test
        mkdir -p $(@D)
        printf "%b" "$(COM_COLOR)$(2) $(OBJ_COLOR)$(@F)$(NO_COLOR)\r"; \
        $(1) 2> $@.log; \
        RESULT=$$?; \
        printf "%b" "$(COM_COLOR)$(2) $(OBJ_COLOR)"; \
        if [ $$RESULT -ne 0 ]; then \
          printf "%-40b%b" "$@" "$(ERROR_COLOR)$(ERROR_STRING)$(NO_COLOR)\n"; \
        elif [ -s $@.log ]; then \
          printf "%-40b%b" "$@" "$(WARN_COLOR)$(WARN_STRING)$(NO_COLOR)\n"; \
        else  \
          printf "%-40b%b" "$(@F)" "$(OK_COLOR)$(OK_STRING)$(NO_COLOR)\n"; \
        fi; \
        cat $@.log; \
        rm -f $@.log; \
        exit $$RESULT
    endef

endif
