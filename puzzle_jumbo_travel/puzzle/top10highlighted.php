<?php
//Ispisati top 100 tabelu 


 
//display of the table
$sb2 = new ScoreBroker();
$results = $sb2->fetch10Contestants();

?>
<table border="1" bordercolor="#FFCC00" class="highscore-table">
<?php
$index = 1;
while($row = $results->fetch_assoc()) 
{
	if( ($row["score"] == $score) && ($row["email"] == $email))
	{
?>
    <tr>
		<td class="highlighted_row"><?php echo $index;   ?> </td>    
		<td class="highlighted_row"><?php echo $row["name"]; ?> </td>		
		<td class="highlighted_row"><?php echo $row["score_as_time"]; ?></td>		
		
	
	</tr>
<?  }
    else 
    {
?>      
	<tr>
		<td><?php echo $index;   ?></td>    
		<td><?php echo $row["name"]; ?> </td>		
		<td><?php echo $row["score_as_time"]; ?></td>		
		
	
	</tr>
<?php
    } 
  $index++;
}	
?>
</table>
<p style="font-family:verdana,arial,sans-serif;font-size:10px;"></p>
<br/><br/><br/><br/><br/><br/><br/>
<a href="../../"> Back to website </a>
<br/>
<a href="AS3_PuzzleGame.swf"> Play again </a>

