<?php
$file = "photos.txt";

if (!($fp = fopen($file, "r"))) {
   die("could not open photos file");
}

# Begin the table
?>

<table border = '0' width='100%' cellspacing='5' cellpadding='0'>
<tr>
<?php
while ($data = fgets($fp, 256)) {
   printf("<td><img src=\"%s\"/></td>\n", $data);
}

# End the table
?>
</tr>
</table>

