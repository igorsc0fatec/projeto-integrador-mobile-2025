<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Max-Age: 3600");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

include_once '../config.php';
include_once '../objects/massa.php';

$database = new Database();
$db = $database->getConnection();

$massa = new Massa($db);

$data = json_decode(file_get_contents("php://input"));

// Validar dados de entrada
if (
    !empty($data->id) &&
    !empty($data->descricao) &&
    isset($data->valor_por_peso) &&
    !empty($data->confeitaria_id)
) {
    // Setar valores do objeto
    $massa->id = $data->id;
    $massa->descricao = $data->descricao;
    $massa->valor_por_peso = $data->valor_por_peso;
    $massa->confeitaria_id = $data->confeitaria_id;

    // Tentar atualizar
    if ($massa->atualizar()) {
        http_response_code(200);
        echo json_encode(array(
            "status" => "success",
            "message" => "Massa atualizada com sucesso."
        ));
    } else {
        http_response_code(503);
        echo json_encode(array(
            "status" => "error",
            "message" => "Não foi possível atualizar a massa."
        ));
    }
} else {
    http_response_code(400);
    echo json_encode(array(
        "status" => "error",
        "message" => "Dados incompletos para atualização.",
        "error_details" => $data
    ));
}
?>