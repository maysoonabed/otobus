<?php
      $connect = mysqli_connect("localhost","root","","otobus");  
      $inspic=$_POST['insimg'];
      $insname=$_POST['insname'];
      $Email=$_POST['email'];
      $insImage= base64_decode($inspic);
      file_put_contents('cardlic/'.$insname, $insImage);
      $busid="";

      $q = "SELECT * FROM `driver` WHERE `email`='$Email'";
      $res = $connect->query($q);
      if($res->num_rows>0){
         $rrw = mysqli_fetch_assoc($res);
         $busid=$rrw['busid'];
      }

      $query = "UPDATE `bus` SET `insurname`='$insname',`insurencoded`='$inspic' WHERE `busid` ='$busid'";
      $result = mysqli_query($connect,$query);
      
      $que = "UPDATE `driver` SET `onofflag`=0b01 WHERE `email`='$Email' ";
      $resu = mysqli_query($connect,$que); 

      /* if($result->num_rows) {
            echo"yaah";
      }else{
           echo"nooooh";
      }   */                  
 ?>