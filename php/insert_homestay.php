<?php
	if (!isset($_POST)) {
    $response = array('status' => 'failed', 'data' => null);
    sendJsonResponse($response);
    die();
	}
	include_once("dbconnect.php");
	$userid = $_POST['userid'];
	$hsname= addslashes($_POST['hsname']);
	$hsdesc= addslashes($_POST['hsdesc']);
	$hsaddress= addslashes($_POST['hsaddress']);
	$hsprice= $_POST['hsprice'];
	$state= addslashes($_POST['state']); //addslashes avoid input that has coma
	$local= addslashes($_POST['local']);
	$lat= $_POST['lat'];
	$lon= $_POST['lon'];
	$image= $_POST['image'];
	
	$sqlinsert = "INSERT INTO `table_homestay`(`user_id`, `homestay_name`, `homestay_desc`, `homestay_address`, `homestay_price`, `homestay_state`, `homestay_local`, `homestay_lat`, `homestay_lng`) VALUES ('$userid','$hsname','$hsdesc','$hsaddress','$hsprice','$state','$local','$lat','$lon')";
  try {
		if ($conn->query($sqlinsert) === TRUE) {
			$decoded_string = base64_decode($image);
			$filename = mysqli_insert_id($conn);
			$path = '../assets/homestayImages/'.$filename.'.png';
			file_put_contents($path, $decoded_string);
			$response = array('status' => 'success', 'data' => null);
			sendJsonResponse($response);
		}
		else{
			$response = array('status' => 'failed', 'data' => null);
			sendJsonResponse($response);
		}
	}
	catch(Exception $e) {
		$response = array('status' => 'failed', 'data' => null);
		sendJsonResponse($response);
	}
	$conn->close();
	
	function sendJsonResponse($sentArray)
	{
    header('Content-Type= application/json');
    echo json_encode($sentArray);
	}
?>