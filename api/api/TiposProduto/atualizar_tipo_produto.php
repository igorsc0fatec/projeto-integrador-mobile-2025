<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Max-Age: 3600");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

include_once '../config.php';
include_once '../objects/tipo_produto.php';

$database = new Database();
$db = $database->getConnection();

$tipoProduto = new TipoProduto($db);

$data = json_decode(file_get_contents("php://input"));

// Validar dados de entrada
if (
    !empty($data->id) &&
    !empty($data->descricao) &&
    !empty($data->confeitaria_id)
) {
    // Setar valores do objeto
    $tipoProduto->id = $data->id;
    $tipoProduto->descricao = $data->descricao;
    $tipoProduto->confeitaria_id = $data->confeitaria_id;

    // Tentar atualizar
    if ($tipoProduto->atualizar()) {
        http_response_code(200);
        echo json_encode(array(
            "status" => "success",
            "message" => "Tipo de produto atualizado com sucesso."
        ));
    } else {
        http_response_code(503);
        echo json_encode(array(
            "status" => "error",
            "message" => "Não foi possível atualizar o tipo de produto."
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