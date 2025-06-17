<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Max-Age: 3600");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

include_once '../config.php';
include_once '../objects/recheio.php';

$database = new Database();
$db = $database->getConnection();

$recheio = new Recheio($db);

$data = json_decode(file_get_contents("php://input"));

// Validar dados de entrada
if (
    !empty($data->id) &&
    !empty($data->descricao) &&
    isset($data->valor_por_peso) &&
    !empty($data->confeitaria_id)
) {
    $recheio->id = $data->id;
    $recheio->descricao = $data->descricao;
    $recheio->valor_por_peso = $data->valor_por_peso;
    $recheio->confeitaria_id = $data->confeitaria_id;

    if ($recheio->atualizar()) {
        http_response_code(200);
        echo json_encode([
            "status" => "success",
            "message" => "Recheio atualizado com sucesso."
        ]);
    } else {
        http_response_code(503);
        echo json_encode([
            "status" => "error",
            "message" => "Não foi possível atualizar o recheio."
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