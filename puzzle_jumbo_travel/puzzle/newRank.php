<?php 
  echo "Cestitamo!!! Vas rezultat je dovoljno dobar da biste se upisali na TOP10 tabelu!!! Unesite vase podatke ispod. Kontaktiracemo vas preko mejla ako<br/>";
  echo "budete imali najbolji rezultat.<br/>";
  
  echo "Congratulations!!! Your score is good enough for the TOP10 table!!! Enter your info below. We will contact you through your email address if<br/>";
  echo "you are the best player at the end.<br/>";
?>
<form action = "InsertContestant.php" method="post">

<label for="name"> ime </label>
<input name="name">
<br/>

<label for="email"> email </label>
<input name="email">
<br/>


<input name="score" style="visibility: hidden;" value="<?php echo $calculated_score; ?>"  />
<br/>

<input name="hours" style="visibility: hidden;" value="<?php echo $hours; ?>"  />
<br/>

<input name="minutes" style="visibility: hidden;" value="<?php echo $minutes; ?>" />
<br/>

<input name="seconds" style="visibility: hidden;" value="<?php echo $seconds; ?>" />
<br/>

<input name="tenths" style="visibility: hidden;" value="<?php echo $tenths; ?>" />
<br/>

<button type="submit">
Posalji rezultat
</button>

</form>