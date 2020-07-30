<?php

if( $_POST['data_type'] =="Minap" ) {
   if ( isset($_FILES["file"])) {

        //errors uploading the file
        if ($_FILES["file"]["error"] > 0) {
            echo "Return Code: " . $_FILES["file"]["error"] . "<br />";
        }
        else {
            $storagename = "uploaded_file.csv";
            move_uploaded_file($_FILES["file"]["tmp_name"], "C:/xampp/htdocs/Qualdashv1-master/home/data/source/minap/" . $storagename);
            echo "<script>alert('File Uploaded Successfully');</script> ";
            exec("C:/xampp/htdocs/Qualdashv1-master/home/R/minap_rscript.R");
            header("Location: form_options_minap.php");
        }
     } else {
             echo "No file selected <br />";
     }
}

else{
	if ( isset($_FILES["file"])) {

        //errors uploading the file
        if ($_FILES["file"]["error"] > 0) {
            echo "Return Code: " . $_FILES["file"]["error"] . "<br />";
        }
        else {
            $storagename = "uploaded_file.csv";
            move_uploaded_file($_FILES["file"]["tmp_name"], "C:/xampp/htdocs/Qualdashv1-master/home/data/source/picanet/" . $storagename);
            echo "<script>alert('File Uploaded Successfully');</script> ";
            exec("C:/xampp/htdocs/Qualdashv1-master/home/R/picanet_rscript.R");
            header("Location: form_options_picanet.php");
        }
     } else {
             echo "No file selected <br />";
     }
}

?>