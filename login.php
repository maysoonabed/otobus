<?php
<<<<<<< HEAD:logpass.php
    $con = new mysqli("localhost","root","","otobus") or die('No connection');
=======
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
<<<<<<< HEAD
/*
    $con = mysqli_connect('localhost', 'root', '', 'otobus') or die('No connection');
>>>>>>> b1052d5ecfc829ca0d9759a2cd2e39095211e358:login.php
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
<<<<<<< HEAD:logpass.php
  
=======
    }else //****Driver***********************/
    {
        $query = "SELECT * FROM `driver` WHERE `phonenum`='$passphone' AND `password`='$password'";
        $result = $startConn->query($query);
        if ($result->num_rows > 0)
           echo json_encode($Status);//"passenger is exist"; //$Status->success = "YES";
        else
           echo json_encode($Status);
  }
  
    
>>>>>>> b1052d5ecfc829ca0d9759a2cd2e39095211e358:login.php
=======
>>>>>>> 972db1bdb4b8d3a5a712e5b1cb73fdbc00ee561f

?>


