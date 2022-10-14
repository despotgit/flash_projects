<?php
class ScoreBroker
{
	
	protected $host; 
    protected $user; 
    protected $pass; 
    protected $db_name;
    protected $dbh; 
    
	public function __construct()
	{		
        //$this->host="localhost"; // Host name
        //$this->user="root"; // Mysql username
        //$this->pass=""; // Mysql password
        //$this->db_name="puzzle"; // Database name
        
        $this->host="mysql12.000webhost.com"; // Host name
        $this->user="a9045224_root"; // Mysql username
        $this->pass="sifra2"; // Mysql password
        $this->db_name="a9045224_db"; // Database name
                
        $this->dbh = mysqli_connect($this->host, $this->user, $this->pass, $this->db_name);  
	}
	
	public function insertScore($name_par, $email_par, $score_par, $score_hours_par, $score_minutes_par, $score_seconds_par, $score_tenths_par)
	{
		
		$insert_sql="INSERT INTO scores( `name`,    `email`,    `score`,    `score_hours`,    `score_minutes`,    `score_seconds`,     `score_tenths`)".
		 		                " VALUES('$name_par', '$email_par', $score_par, $score_hours_par, $score_minutes_par, $score_seconds_par, $score_tenths_par);";
        
		//echo "SQL za INSERT JE:".$insert_sql;
		
		$result = mysqli_query($this->dbh, $insert_sql);
		
	}
	
	public function fetchScoreByRank($rank_par)
	{
		$sql = "SELECT score from scores s1 where ((select count(*) from  scores s2 where s2.score<s1.score)=($rank_par-1));";
       
        $result = mysqli_query($this->dbh, $sql);
        // Mysql_num_row is counting table rows
        $count = mysqli_num_rows($result);
        if($count==1)
        {
           //  table row must be 1 row
           $row = mysqli_fetch_row($result);
           $sco = $row[0];
        }
        return $sco;
		
	}
	
	
	//Fetch first 100 results as array
	public function fetch10Contestants()
	{
		$sql = "SELECT name, 
		               email,
		               score,
		               CONCAT( (CASE length(score_hours) WHEN 1 THEN  CONCAT('0',score_hours)
                                                                                                        WHEN 2 THEN score_hours END),
                                                 ':',                                                 
                                                (CASE length(score_minutes) WHEN 1 THEN  CONCAT('0',score_minutes)
                                                                                                        WHEN 2 THEN score_minutes END),
                                                ':',
                                                 (CASE length(score_seconds) WHEN 1 THEN  CONCAT('0',score_seconds)
                                                                                                        WHEN 2 THEN score_seconds END),
                                                ':',
                                                 (CASE length(score_tenths) WHEN 1 THEN  CONCAT(score_tenths,'0')
                                                                                                        WHEN 2 THEN score_tenths END)) 
                                                                                                        as score_as_time
				FROM scores 
				ORDER BY score ASC LIMIT 10;";
       
        $result = mysqli_query($this->dbh, $sql);
        // Mysql_num_row is counting table rows
        $count = mysqli_num_rows($result);
        if($count>0)
        {
           return $result;           
        }
	}
}

?>