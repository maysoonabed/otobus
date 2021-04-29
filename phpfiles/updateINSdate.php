<?php 
    $connect = mysqli_connect("localhost","root","","otobus"); 
	if(!$connect){
		echo"Database connection failed";		
	}
   
    $Email = $_POST['email'];
    $stnewDATE = $_POST['endate'];
    $time = strtotime($stnewDATE);
    $enddate = date('Y-m-d',$time);
    $busid="";

    $q = "SELECT * FROM `driver` WHERE `email`='$Email'";
    $res = $connect->query($q);
    if($res->num_rows>0){
        $rrw = mysqli_fetch_assoc($res);
        $busid=$rrw['busid'];
    }
    $query = "UPDATE `bus` SET `insurend`='$enddate' WHERE busid ='$busid'";
    $result = mysqli_query($connect,$query);  
 ?>