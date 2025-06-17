<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Max-Age: 3600");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

include_once '../config.php';
include_once '../objects/cobertura.php';

$database = new Database();
$db = $database->getConnection();

$cobertura = new Cobertura($db);

$data = json_decode(file_get_contents("php://input"));

// Validar dados de entrada
if (
    !empty($data->id) &&
    !empty($data->descricao) &&
    isset($data->valor_por_grama) &&
    !empty($data->confeitaria_id)
) {
    // Setar valores do objeto
    $cobertura->id = $data->id;
    $cobertura->descricao = $data->descricao;
    $cobertura->valor_por_grama = $data->valor_por_grama;
    $cobertura->confeitaria_id = $data->confeitaria_id;

    // Tentar atualizar
    if ($cobertura->atualizar()) {
        http_response_code(200);
        echo json_encode(array(
            "status" => "success",
            "message" => "Cobertura atualizada com sucesso."
        ));
    } else {
        http_response_code(503);
        echo json_encode(array(
            "status" => "error",
            "message" => "Não foi possível atualizar a cobertura."
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