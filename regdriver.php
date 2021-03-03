<?php 
    $connect = mysqli_connect("localhost","root","","otobus"); 
	if(!$connect){
		echo"Database connection failed";		
	}
	   $card=$_FILES['image']['name'];
	   $type=$_POST['name'];
	   $path='uploads/'.$card;
	   $tmp=$_FILES['image']['tmp'];
	   move_uploaded_file($tmp,$path);
	   $connect->query("INSERT INTO bus (type, busid,numofpass,idcard) VALUES ('".$type."','".$type."','".$type."','".$card."')");
	  
?>