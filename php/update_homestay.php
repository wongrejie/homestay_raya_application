<?php
	if (!isset($_POST)) {
    $response = array('status' => 'failed', 'data' => null);
    sendJsonResponse($response);
    die();
	}
	include_once("dbconnect.php");
	$homestayid = $_POST['homestayid'];
	$userid = $_POST['userid'];
   $hsname= addslashes($_POST['hsname']);
	$hsdesc= addslashes($_POST['hsdesc']);
	$hsaddress= addslashes($_POST['hsaddress']);
	$hsprice= $_POST['hsprice'];
  
  
	$sqlupdate = "UPDATE `table_homestay` SET `homestay_name`='$hsname',`homestay_desc`='$hsdesc',`homestay_address`='$hsaddress',`homestay_price`='$hsprice' WHERE `homestay_id` = '$homestayid' AND `user_id` = '$userid'";
	
  try {
		if ($conn->query($sqlupdate) === TRUE) {
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