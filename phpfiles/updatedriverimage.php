<?php
      $connect = mysqli_connect("localhost","root","","otobus");  
      $profpic=$_POST['profimg'];
      $profname=$_POST['profname'];
      $email=$_POST['email'];
      $profImage= base64_decode($profpic);
      file_put_contents('cardlic/'.$profname, $profImage);
      //echo $email , $profname ;
      $query = "UPDATE `driver` SET `picture`='$profname' WHERE email ='$email'";
      $result = mysqli_query($connect,$query);      
      /* if($result->num_rows) {
            echo"yaah";
      }else{
           echo"nooooh";
      }   */                  
 ?>