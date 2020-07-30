<!DOCTYPE html>
<html lang="en">
<head>
  <title>Upload Audit File</title>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.5.0/css/bootstrap.min.css">
  <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script>
  <script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.16.0/umd/popper.min.js"></script>
  <script src="https://maxcdn.bootstrapcdn.com/bootstrap/4.5.0/js/bootstrap.min.js"></script>
</head>
<body>

<div class="container mt-3">
  <h2>Upload File</h2>
  <p>Use the form below to upload an audit file to the server.</p>
  <form action="upload_audit_file.php" method="POST" enctype="multipart/form-data">

    <div class="mb-3">
      <select class="custom-select mb-3" id="data_type" name="data_type">
        <option value="Minap">Minap</option>
        <option value="Picanet">Picanet</option>
      </select>
    </div>

    <div class="custom-file mb-3">
      <input type="file" class="custom-file-input" id="customFile" name="file" accept=".csv" >
      <label class="custom-file-label" for="customFile">Upload Audit File</label>
    </div>
    <button type="submit" class="btn btn-secondary">Upload Audit File</i></button>
  </form>
</div>

<script>
// Add the following code if you want the name of the file appear on select
$(".custom-file-input").on("change", function() {
  var fileName = $(this).val().split("\\").pop();
  $(this).siblings(".custom-file-label").addClass("selected").html(fileName);
});
</script>

</body>
</html>
