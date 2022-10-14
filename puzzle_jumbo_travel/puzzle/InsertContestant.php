<html>
<head>
  <link rel="stylesheet" type="text/css" href="css/styles.css" />
</head>
<?php

include_once "ScoreBroker.php";

$name = $_POST["name"];
$email = $_POST["email"];
$score = $_POST["score"];

$hours = $_POST["hours"];
$minutes = $_POST["minutes"];
$seconds = $_POST["seconds"];
$tenths = $_POST["tenths"];

$sb = new ScoreBroker();

$sb->insertScore($name, $email, $score, $hours, $minutes, $seconds, $tenths);

include "top10highlighted.php";

?>

</html>