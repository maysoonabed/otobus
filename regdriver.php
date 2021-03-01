<?php 
    $connect = mysqli_connect("localhost","root","","otobus"); 
	if(!$connect){
		echo"DAtabase connection failed";		
	}
	   $card=$_FILES['idcard']['type'];
	   $type=$_POST['type'];
	   $path='uploads/'.$image;
	   $tmp=$_FILES['idcard']['tmp'];
	   move_uploaded_file($tmp,$path);
	   $connect->query("INSERT INTO bus (type, busid,numofpass,idcard) VALUES ('".$type."','".$type."','".$type."','".$card."')");



?>