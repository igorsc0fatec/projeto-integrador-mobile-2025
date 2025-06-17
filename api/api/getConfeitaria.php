<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: GET");
header("Access-Control-Max-Age: 3600");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");
header("Access-Control-Allow-Credentials: true"); // Adicione esta linha

include_once 'config.php';

session_start();

// Verifique se a sessão existe e tem o id_usuario
if (!isset($_SESSION['id_usuario'])) {
    http_response_code(401);
    echo json_encode(array("message" => "Usuário não autenticado."));
    exit;
}

$id_usuario = $_SESSION['id_usuario'];

$query = "SELECT * FROM tb_confeitaria WHERE id_usuario = ?";
$stmt = $conn->prepare($query);
$stmt->bind_param("i", $id_usuario);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows > 0) {
    $confeitaria = $result->fetch_assoc();
    http_response_code(200);
    echo json_encode($confeitaria);
} else {
    http_response_code(404);
    echo json_encode(array("message" => "Confeitaria não encontrada."));
}
?>