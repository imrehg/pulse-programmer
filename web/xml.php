<?php

# States are {initial,item,title,description,author,pubdate}
$discard = false;
$current_tag_cdata = "";

# Common filter functions

function startElement($parser, $name, $attrs)
{
   global $transitions, $open_tags, $state, $discard, $current_tag_cdata;
   # Make sure we are in a valid state
   if (isset($transitions[$state])) {
     $next_transition = $transitions[$state];
     if (isset($next_transition[$name])) {
       # Only echo the tag inside the check of valid transition
       if (isset($open_tags[$name])) {
         $current_tag_cdata = "";
         echo "$open_tags[$name]";
       }
       # Go to the next state
       $state = $next_transition[$name];
       $discard = false;
     }
     else {
       # If tag is not supported, ignore and swallow it
       $discard = true;
     }
   }
   else {
     error_log("Invalid state = ".$state);
   }
}

function endElement($parser, $name)
{
   global $close_tags, $current_tag_cdata, $state, $filter_functions, $discard;
   if (isset($close_tags[$name])) {
     if ($discard == false) {
       foreach ($filter_functions as $key_state => $function) {
         if ($state == $key_state) {
           call_user_func($function, &$current_tag_cdata);
         }
       }
       echo $current_tag_cdata;
     }
     echo "$close_tags[$name]";
   }
}

function characterData($parser, $data)
{
  global $discard, $current_tag_cdata;
  if ($discard == false) {
    $current_tag_cdata .= $data;
  }
}

?>
