<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Max-Age: 3600");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

include_once '../config.php';
include_once '../objects/formato.php';

$database = new Database();
$db = $database->getConnection();

$formato = new Formato($db);

$data = json_decode(file_get_contents("php://input"));

// Validar dados de entrada
if (
    !empty($data->id) &&
    !empty($data->descricao) &&
    isset($data->valor_por_grama) &&
    !empty($data->confeitaria_id)
) {
    $formato->id = $data->id;
    $formato->descricao = $data->descricao;
    $formato->valor_por_grama = $data->valor_por_grama;
    $formato->confeitaria_id = $data->confeitaria_id;

    if ($formato->atualizar()) {
        http_response_code(200);
        echo json_encode([
            "status" => "success",
            "message" => "Formato atualizado com sucesso."
        ]);
    } else {
        http_response_code(503);
        echo json_encode([
            "status" => "error",
            "message" => "Não foi possível atualizar o formato."
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
