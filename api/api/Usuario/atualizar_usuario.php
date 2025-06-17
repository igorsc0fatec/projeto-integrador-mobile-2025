<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Max-Age: 3600");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

include_once '../config.php';
include_once '../objects/usuario.php';

$database = new Database();
$db = $database->getConnection();

$usuario = new Usuario($db);

$data = json_decode(file_get_contents("php://input"));

// Validar dados
if (
    !empty($data->id_usuario) &&
    !empty($data->email_usuario) &&
    isset($data->email_verificado) &&
    isset($data->conta_ativa) &&
    !empty($data->senha_usuario) &&
    isset($data->id_tipo_usuario)
) {
    $usuario->id_usuario = $data->id_usuario;
    $usuario->email_usuario = $data->email_usuario;
    $usuario->email_verificado = $data->email_verificado;
    $usuario->conta_ativa = $data->conta_ativa;
    $usuario->senha_usuario = password_hash($data->senha_usuario, PASSWORD_DEFAULT);
    $usuario->id_tipo_usuario = $data->id_tipo_usuario;

    if ($usuario->atualizar()) {
        http_response_code(200);
        echo json_encode([
            "status" => "success",
            "message" => "Usuário atualizado com sucesso."
        ]);
    } else {
        http_response_code(503);
        echo json_encode([
            "status" => "error",
            "message" => "Não foi possível atualizar o usuário."
        ]);
    }
} else {
    http_response_code(400);
    echo json_encode([
        "status" => "error",
        "message" => "Dados incompletos para atualização.",
        "error_details" => $data
    ]);
}
?>
