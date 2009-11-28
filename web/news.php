<?php
$file        = "project_news.xml";
$state       = "initial";
$news_author_data = "";
$news_title_data = "";
$news_desc_data = "";

###############################################################################
# Parse State transition table

$transitions = array(
  "initial"     => array("ITEM"        => "item"       ),
  "item"        => array("TITLE"       => "title"      ),
  "title"       => array("DESCRIPTION" => "description"),
  "description" => array("AUTHOR"      => "author"     ),
  "author"      => array("PUBDATE"     => "pubdate"    ),
  "pubdate"     => array("ITEM"        => "item"       )
);

###############################################################################
# Filter functions

function filter_news_title(&$data) {
  global $news_title_data;
  $news_title_data = $data;
  $data = "";
}

function filter_news_author(&$data) {
  global $news_author_data;
  # Remove e-mail address
  $news_author_data = preg_replace("/@\w+(.\w+)+/", "", $data);
  $data = "";
}

function filter_news_desc(&$data) {
  global $news_desc_data;
  $news_desc_data = $data;
  $data = "";
}

function filter_news_pubdate(&$data) {
  global $news_title_data, $news_desc_data, $news_author_data;
  $pubdate = preg_replace("/.*(\d\d \w\w\w \d\d\d\d) .*/",
                       "&nbsp;&nbsp;$1", $data);
  $data = "<tr><td class='table-story-subject'>\n";
  $data .= "<table width='100%'><tr>\n";
  $data .= "<td width='60%'><p class='text-story-subject'>";
  $data .= $news_title_data."</p></td>\n";
  $data .= "<td width='25%' align='right'><p class='text-story-header'>";
  $data .= $news_author_data."</p></td>\n";
  $data .= "<td width='15%' align='right'>".$pubdate."</td>\n";
  $data .= "</tr></table></td></tr>\n";
  $data .= "<tr><td class='table-story-body'><p class='text-story-body'>\n";
  $data .= $news_desc_data."</p></td></tr>";
}

$filter_functions = array(
  "title"       => "filter_news_title",
  "author"      => "filter_news_author",
  "description" => "filter_news_desc",
  "pubdate"     => "filter_news_pubdate"
 );

###############################################################################
# Tag substitutions

$open_tags = array(
   "TITLE"       => "",
   "DESCRIPTION" => "",
   "AUTHOR"      => "",
   "PUBDATE"     => ""
);

$close_tags = array(
   "TITLE"       => "",
   "DESCRIPTION" => "",
   "AUTHOR"      => "",
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

<table border = '0' width='100%' cellspacing='5' cellpadding='0'>

<?php
while ($data = fread($fp, 4096)) {
   if (!xml_parse($xml_parser, $data, feof($fp))) {
       die(sprintf("XML error: %s at line %d",
                   xml_error_string(xml_get_error_code($xml_parser)),
                   xml_get_current_line_number($xml_parser)));
   }
}

# End the table
?>
</table>
<p class="darkbg">
<a href="http://sourceforge.net/news/?group_id=129764">Older News Items</a>
</p>

<?php

xml_parser_free($xml_parser);
?> 
