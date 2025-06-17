<?php
include 'db.php';

$data = json_decode(file_get_contents("php://input"), true);

$nome = $data['nome_produto'];
$desc = $data['desc_produto'];
$valor = $data['valor_produto'];
$frete = $data['frete'];
$ativo = $data['produto_ativo'] ? 1 : 0;
$limite = $data['limite_entrega'];
$img = $data['img_produto'];
$tipo = $data['id_tipo_produto'];

// Aqui, suponha que o id_confeitaria seja fixo ou venha via autenticação
$idConfeitaria = 1;

$query = "INSERT INTO produto (nome_produto, desc_produto, valor_produto, frete, produto_ativo, limite_entrega, img_produto, id_tipo_produto, id_confeitaria)
          VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";

$stmt = $conn->prepare($query);
$stmt->bind_param("ssddiisii", $nome, $desc, $valor, $frete, $ativo, $limite, $img, $tipo, $idConfeitaria);

if ($stmt->execute()) {
    echo "success";
} else {
    http_response_code(500);
    echo "Erro: " . $stmt->error;
}
