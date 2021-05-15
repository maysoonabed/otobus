<?php
    $connect = mysqli_connect("localhost","root","","otobus");      
    if (!$connect) {
      echo"Database connection failed";	
    }
    $Email = $_POST['email'];
    $todayDate=date("Y-m-d");
    $insurDate;
    $insMinusTod;
    $onofflag;
    $query = "SELECT * FROM `driver` WHERE `email`='$Email'"; 
    $result = $connect->query($query);
       
      if($result->num_rows>0){
               $rrw = mysqli_fetch_assoc($result);
               $busid=$rrw['busid'];
               $quy = "SELECT * FROM `bus` WHERE `busid`='$busid'";
               $resu = $connect->query($quy);
               $rw=mysqli_fetch_assoc($resu);
               $insurDate=$rw['insurend'];
      }
    //echo $todayDate;
    //echo $insurDate;
    $diff= abs(strtotime($insurDate)-strtotime($todayDate));
    $insMinusTod= floor($diff / (60*60*24));
    //echo $insMinusTod;
    $json['insdate']=$insMinusTod;

    /* $onofflag=(String)$rrw['onofflag'];
    if(strcmp( $onofflag ,'0001')==0)//bindec()
    $onofflag=1;
    else
    $onofflag=0; */

    $qqq = "SELECT * FROM `driver` WHERE `email`='$Email' AND `onofflag`=0b1"; 
    $rrr = $connect->query($qqq);
    if($rrr->num_rows>0)
      $onofflag=1;
    else
      $onofflag=0;

    $json['onofflag']=$onofflag;
    
    echo json_encode($json);
    mysqli_close($connect);  
?>


