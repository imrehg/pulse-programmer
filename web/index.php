<?php
if (!array_key_exists("page", $_GET)) {
	$include_page="home.html";
}
else {
$page = $_SERVER['DOCUMENT_ROOT'] . '/' . basename($_GET['page']);
        #$page = $_GET["page"];
	$include_page=$page.".html";
}
$menu = "menu";
$menu_width = "210";

# Include once for all later XML parsers
include("xml.php");

# Everything else is in here
include("subindex.php");
?>
</body>
</html>
