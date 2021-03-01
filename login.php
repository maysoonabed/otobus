<?php
$con = mysqli_connect('localhost', 'root', '', 'otobus') or die('No connection');
if($_SERVER['REQUEST_METHOD'] == "POST"){
    $passphone=$_POST["phone"];
    $password =$_POST["password"];
    $idtype =$_POST["id"];

    if($idtype==1){
      $query = mysqli_query($con,"SELECT * FROM `passenger` WHERE `phonenum`='$passphone' AND `password`='$password'");
      $cek = mysqli_fetch_array($query);
     
    if(isset($cek) && $cek != null){
        echo json_encode("success");
    }else{
        echo json_encode("fail");
    }
   }
   else{}
   }

?>


