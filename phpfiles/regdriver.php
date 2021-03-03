<?php 
    $connect = mysqli_connect("localhost","root","","otobus"); 
	if(!$connect){
		echo"Database connection failed";		
	}
    $idcardimg = $_POST['idcardimg'];
    $idcardname= $_POST['idcardname'];
    $licenseimg = $_POST['licenseimg'];
    $licensename = $_POST['licensename'];

    'busId': busId,
    'numpass': numpass,
    'type': type,
    
    $idcardImage = base64_decode($idcardimg);
    $licenseImage= base64_decode($licenseimg);
 
    file_put_contents('cardlic/'.$idcardname, $idcardImage);
    file_put_contents('cardlic/'.$licensename, $licenseImage);

 
    echo "Image Uploaded Successfully.";
?>