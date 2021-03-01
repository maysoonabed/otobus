<?php
    $con = new mysqli("localhost","root","","otobus") or die('No connection');
    $passphone=$_POST["phone"];
    $password =$_POST["password"];
    $idtype =$_POST["id"];

    if($idtype==1)
   $query = "SELECT * FROM passenger WHERE ( phonenum='$passphone') AND password = '$Password' ";
   else 
        $query = "SELECT * FROM `driver` WHERE `phonenum`='$passphone' AND `password`='$password'";
   $result = mysqli_query($con, $query);
    
     
     if ($result->num_rows > 0)
        echo json_encode('success');//"passenger is exist"; //$Status->success = "YES";
     else
        echo json_encode('fail'); //"passenger is not exist"//$Status->success = "NO";
  

?>

