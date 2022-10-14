<?php 
include_once "ScoreCalculator.php";
include_once "ScoreBroker.php";

$hours = $_POST["hors"];
$minutes = $_POST["mins"];
$seconds = $_POST["secs"];
$tenths = $_POST["tens"];

//echo "<br/>hors: ".$_POST["hors"];
//echo "<br/>mins: ".$_POST["mins"];
//echo "<br/>secs: ".$_POST["secs"];
//echo "<br/>tens: ".$_POST["tens"];

//1.Calculate number of seconds (0.1 precision),
//2.Fetch the tenth score from the DB 
//4.a)If score is better than 10th score, take me to the page for contestant info entry. Upon clicking ok, go to top10 table with his name in red
//  b)If score is not good enough for top 10, take me to the top10 table.

$sc = new ScoreCalculator();
$sb = new ScoreBroker();

$calculated_score = $sc->calculate_score($hours, $minutes, $seconds, $tenths);

$tenth_score = $sb->fetchScoreByRank(10);

//echo "your calculated score is: ".$calculated_score;
//echo "hundredth score is: ".$tenth_score;

if($calculated_score<$tenth_score)
{
	//echo "<br/>new rank";
	include "newRank.php";
	
}
else 
{
	//echo "<br/>no new rank";
	include "top10.php";
	
	
}

 



?>