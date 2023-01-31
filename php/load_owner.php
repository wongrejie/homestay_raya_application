<?php
if (!isset($_POST)) {
    $response = array('status' => 'failed', 'data' => null);
    sendJsonResponse($response);
    die();
}
include_once("dbconnect.php");
$ownerid = $_POST['ownerid'];
$sqlloadowner = "SELECT * FROM table_users WHERE user_id = '$ownerid'";
$result = $conn->query($sqlloadowner);

if ($result->num_rows > 0) {
	while ($row = $result->fetch_assoc()) {
		$userlist = array();
		$userlist['id'] = $row['user_id'];
		$userlist['name'] = $row['user_name'];
    $userlist['email'] = $row['user_email'];
    $userlist['phone'] = $row['user_phone'];
    $userlist['address'] = $row['user_address'];
    $userlist['regdate'] = $row['user_dateReg'];
    $response = array('status' => 'success', 'data' => $userlist);
    sendJsonResponse($response);
	}
}else{
	$response = array('status' => 'failed', 'data' => null);
  sendJsonResponse($response);
}
	
function sendJsonResponse($sentArray)
{
    header('Content-Type: application/json');
    echo json_encode($sentArray);
}


?>