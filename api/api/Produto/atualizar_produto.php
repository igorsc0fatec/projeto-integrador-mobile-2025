<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Max-Age: 3600");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

include_once '../config.php';
include_once '../objects/produto.php';

$database = new Database();
$db = $database->getConnection();

$produto = new Produto($db);

$data = json_decode(file_get_contents("php://input"));

// Validar dados de entrada
if (
    !empty($data->id) &&
    !empty($data->nome_produto) &&
    !empty($data->desc_produto) &&
    isset($data->valor_produto) &&
    isset($data->frete) &&
    isset($data->produto_ativo) &&
    !empty($data->limite_entrega) &&
    !empty($data->img_produto) &&
    !empty($data->tipo_produto_id) &&
    !empty($data->confeitaria_id)
) {
    $produto->id = $data->id;
    $produto->nome_produto = $data->nome_produto;
    $produto->desc_produto = $data->desc_produto;
    $produto->valor_produto = $data->valor_produto;
    $produto->frete = $data->frete;
    $produto->produto_ativo = $data->produto_ativo;
    $produto->limite_entrega = $data->limite_entrega;
    $produto->img_produto = $data->img_produto;
    $produto->tipo_produto_id = $data->tipo_produto_id;
    $produto->confeitaria_id = $data->confeitaria_id;

    if ($produto->atualizar()) {
        http_response_code(200);
        echo json_encode([
            "status" => "success",
            "message" => "Produto atualizado com sucesso."
        ]);
    } else {
        http_response_code(503);
        echo json_encode([
            "status" => "error",
            "message" => "Não foi possível atualizar o produto."
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