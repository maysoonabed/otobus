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
        $data['msg'] = "DATA TIDAK ADA";
        echo json_encode("fail");
    }
   }
   else{}
   }
/*
    $con = mysqli_connect('localhost', 'root', '', 'otobus') or die('No connection');
    $passphone=$_POST["phone"];
    $password =$_POST["password"];
    $idtype =$_POST["id"];

    $startConn = mysqli_connect("localhost","root" ,"" , "otobus");
    $Status = new stdClass();
    if (!$startConn) {
       $Status-> startConn = 'fail';
    } else {
       $Status-> startConn = 'success';
   }
   //****Passenger***********************/
     if($idtype==1){
     $query = "SELECT * FROM `passenger` WHERE `phonenum`='$passphone' AND `password`='$password'";
     $result = $startConn->query($query);
     
     if ($result->num_rows > 0)
        echo json_encode('success');//"passenger is exist"; //$Status->success = "YES";
     else
        echo json_encode('fail'); //"passenger is not exist"//$Status->success = "NO";
    }else //****Driver***********************/
    {
        $query = "SELECT * FROM `driver` WHERE `phonenum`='$passphone' AND `password`='$password'";
        $result = $startConn->query($query);
        if ($result->num_rows > 0)
           echo json_encode($Status);//"passenger is exist"; //$Status->success = "YES";
        else
           echo json_encode($Status);
  }
  */
    

?>

