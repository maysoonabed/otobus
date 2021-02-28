<?php
    $con = mysqli_connect('localhost', 'root', '', 'otobus') or die('No connection');
    $passphone=$_POST["phone"];
    $password =$_POST["password"];

    $startConn = mysqli_connect("localhost","root" ,"" , "otobus");
    $Status = new stdClass();
    if (!$startConn) {
       $Status-> startConn = 'fail';
    } else {
       $Status-> startConn = 'success';
}
     $query = "SELECT * FROM `passenger` WHERE `phonenum`='$passphone' AND `password`='$password'";
     $result = $startConn->query($query);

     if ($result->num_rows > 0)
        echo "passenger is exist"; //$Status->success = "YES";
     else
        echo "passenger is not exist"//$Status->success = "NO";

     //echo json_encode($Status);
?>

/*
if($_SERVER['REQUEST_METHOD'] == "POST"){
//$data = array();
$username = $_POST['username'];
$password = $_POST['password'];

$cek =mysqli_query($con, "SELECT * FROM `passenger` WHERE `name`='$username' AND `password`='$password'");
if(isset($cek) && $cek != null){
//$data['msg'] = "DATA ADA";
//$data['level'] = $cek['level'];
//$data['username'] = $cek['username'];
//echo json_encode($data);
echo "exist";
}else{
//$data['msg'] = "DATA TIDAK ADA";
//echo json_encode($data);
echo "not exist";
}
}
*/
