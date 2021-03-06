<?php
$file = "project_files.xml";

$title_data   = "";
$release_data = "";
$state        = "initial";

###############################################################################
# Parse State transition table

$transitions = array(
  "initial"     => array("ITEM"        => "item"        ),
  "item"        => array("TITLE"       => "title" ),
  "title"       => array("DESCRIPTION" => "description" ),
  "description" => array("PUBDATE"     => "pubdate"     ),
  "pubdate"     => array("ITEM"        => "item"        )
);

###############################################################################
# Package translation table to get ID from name
# The SF RSS feeds don't do this for us, jerks

$package_ids = array(
  "yellow-box-protocase"       => 303669,
  "power-supply"               => 300057,
  "docs-for-dummies"           => 302875,
  "ad9910_firmware"            => 265102,
  "sequencer2-python"          => 275122,
  "box-hardware"               => 154740,
  "breakout-hardware"          => 144776,
  "chain-hardware"             => 150996,
  "led-test-hardware"          => 144775,
  "programming-cable-hardware" => 144777,
  "pulse-manual"               => 144638,
  "sequencer-firmware"         => 142226,
  "sequencer-hardware"         => 144637,
  "sequencer-labview"          => 146530,
  "sequencer-python"           => 150869,
  "sequencer-thesis"           => 144730
);

###############################################################################
# Filter functions

function filter_title(&$data) {
  global $title_data, $release_data;
  $title_data = preg_replace("/(\w*(-\w*)*).*/", "$1", $data);
  $release_data = preg_replace("/\w*(-\w*)* ((\s|\w|\d|\.|-)*) released \(.*\)/",
                               "\n$2", $data);
  $data = "";
}

function filter_description(&$data) {
  global $title_data, $release_data, $package_ids;
  $url = preg_replace("/.*(http:\/\/sourceforge.net\/project\/showfiles\.php\?group_id=129764&package_id=\d\d\d\d\d\d&release_id=\d\d\d\d\d\d).*/", "$1", $data);
  # $url .= "&#38;package_id=".$package_ids["$title_data"];
  $data = "<table cellpadding='0' cellspace='0' width='100%'><tr>\n";
  $data .= "<td><a href='".$url."'>".$title_data."</a></td>\n";
  $data .= "<td align='right'>".$release_data."</td></tr></table>\n";
}

function filter_pubdate(&$data) {
  $data = preg_replace("/.*(\d\d \w\w\w \d\d\d\d) .*/",
                       "&nbsp;&nbsp;$1", $data);
}

$filter_functions = array(
  "title"       => "filter_title",
  "description" => "filter_description",
  "pubdate"     => "filter_pubdate"
);

###############################################################################
# Tag substitutions

$open_tags = array(
   "ITEM"        => "",
   "TITLE"       => "",
   "DESCRIPTION" => "",
   "PUBDATE"     => ""
);

$close_tags = array(
   "ITEM"        => "",
   "TITLE"       => "",
   "DESCRIPTION" => "",
   "PUBDATE"     => ""
);

###############################################################################
# Main function

$xml_parser = xml_parser_create();
// use case-folding so we are sure to find the tag in $map_array
xml_parser_set_option($xml_parser, XML_OPTION_CASE_FOLDING, true);
xml_set_element_handler($xml_parser, "startElement", "endElement");
xml_set_character_data_handler($xml_parser, "characterData");
if (!($fp = fopen($file, "r"))) {
   die("could not open XML input");
}

# Begin the table
?>
<table class="dark-cell" border="0" cellpadding="10" cellspacing="1"
       width="100%">
<tr valign="top">
<td class="light-cell">
<strong><big>&bull;</big></strong>
  <a href="http://sourceforge.net/project/showfiles.php?group_id=129764">
    <b>Downloads</b></a>:<br>
<strong><big>&bull;</big></strong>
<b>Recent Releases</b>:<br>
<?php
while ($data = fread($fp, 4096)) {
   if (!xml_parse($xml_parser, $data, feof($fp))) {
       die(sprintf("XML error: %s at line %d",
                   xml_error_string(xml_get_error_code($xml_parser)),
                   xml_get_current_line_number($xml_parser)));
   }
}

?>

</td>
</tr>
</table>
<br>

<?php
xml_parser_free($xml_parser);

?> 
