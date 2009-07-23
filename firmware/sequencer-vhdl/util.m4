dnl Utility macros for M4
dnl ---------------------------------------------------------------------------
dnl MIT-NIST-ARDA Pulse Sequencer
dnl http://qubit.media.mit.edu/sequencer
dnl Paul Pham
dnl MIT Center for Bits and Atoms
dnl ---------------------------------------------------------------------------
dnl
dnl Divert output to null to get rid of newlines.
divert(-1)dnl

changequote([,])

###############################################################################
# Count the number of arguments in the argument; use this as a dummy
# macro call to derefence an argument that is a quoted list of arguments.
#
# Ex:  count_args_([a,b,c]) -> 3

define([count_args_], [ifelse(0, len([$1]), 0, [$#])])

###############################################################################
# Extract the first argument from a quoted list of arguments.
#
# Ex:  first_arg_([a,b,c]) -> a

define([first_arg_], _first_arg($1))
define([_first_arg], $1)

###############################################################################
# Dereference a quoted list of arguments by returning them as an unquoted list.
#
# Ex:  deref_([a,b,c]) -> a,b,c

define([deref_], $*)

###############################################################################
# Loop definition
#   $1 = loop variable
#   $2 = start index
#   $3 = end index
#   $4 = string argument
#
# Ex: forloop_([i], 1, 3, [i ])
#     =>1 2 3

define([forloop_],
       [pushdef([$1], [$2])_forloop([$1], [$2], [$3], [$4])popdef([$1])])
define([_forloop],
       [$4[]ifelse($1, [$3], ,
                   [define([$1], incr($1))_forloop([$1], [$2], [$3], [$4])])])

###############################################################################
# String indentation function
#   $1 = number of spaces to indent
#   $2 = string to indent

define([indent_],
       [forloop_([i], 1, [$1], [ ])[$2]])

###############################################################################
# Maps a macro name on a variable number of arguments, incrementing the given
# loop variable which can be used for substitution in the transform.
#   $1    = loop variable name (quote to prevent expansion)
#   $2    = starting value of $1
#   $3    = transform name (optionally uses $1) (quote to prevent expansion)
#   $4..n = arguments to transform
#
# Ex:  map_loop_([i], 1, [transform], a, b, c)

define([map_loop_],
       [pushdef([$1], eval($2-1))_map_loop([$1], [$3], [$4])[]popdef([$1])])
define([_map_loop],
       [ifelse(1, count_args_($3), [$2](first_arg_($3)),
               define([$1], incr($1))[$2](first_arg_($3))[[]][_map_loop([$1], [$2], [shift(deref_($3))])])])

###############################################################################
# The old version of map_loop_ works on all succeeding arguments and doesn't
# require them to be in a quoted list. However, this wasn't as useful as I
# thought it would be
#define([map_loop_],
#       [pushdef([$1], eval($2-1))_map_loop($@)[]popdef([$1])])
#define([_map_loop],
#       [ifelse(4, $#, [$3]([$4]),
#               [$3]([$4])[[]][_map_loop(postshift_(3, $@))]define([$1], incr($1)))])

###############################################################################
# Maps the first argument as a macro name on all other arguments, quoted
#    $1    = macro name (quote to prevent substitution)
#    $2..n = arguments to call the first macro on.
#
# Ex:  map_([transform], a, b, c)

define([map_],
       [ifelse(2, $#, [$1]([$2]), [$1]([$2])[[]][map_(postshift_(1, $@))])])

###############################################################################
# Preserves the first n arguments and shifts the remainder by 1
#    $1       = number of beginning arguments whose order to preserve
#    $2 ..$$1 = arguments with preserved order
#    $$1..n   = arguments to shift left by one.
#
# Ex:  postshift_(1, do_not_shift, shift1, shift2, shift3)

define([postshift_],
       [pushdef([i], [$1])][_postshift(shift($@))popdef([i])])
define([_postshift],
       [ifelse(0, i, [shift($@)],
               define([i], decr(i))[[$1]][,_postshift(shift($@))])])

###############################################################################
# Performs the given definition only if it isn't already defined.
#    $1 = definition name
#    $2 = definition value

define([define_check_],
       [ifdef([$1], , [define([$1], [$2])])])

dnl Renable output for processed file
divert(0)dnl
