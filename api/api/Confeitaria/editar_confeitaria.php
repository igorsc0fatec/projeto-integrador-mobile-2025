<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: PUT, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

// Inclui o arquivo de configuração PDO corretamente
require __DIR__ . '../../config02.php';

// Se for uma requisição OPTIONS (pré-voo CORS), retorne OK
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

// Obter os dados do corpo da requisição
$input = file_get_contents("php://input");
$data = json_decode($input);

// Verificar se os dados foram recebidos corretamente
if (!$data || !isset($data->id_confeitaria)) {
    http_response_code(400);
    echo json_encode([
        'status' => 'error',
        'message' => 'Dados inválidos ou ID não fornecido',
        'received_data' => $input
    ]);
    exit;
}

try {
    // Preparar a query SQL usando PDO
    $stmt = $pdo->prepare("UPDATE tb_confeitaria SET 
            nome_confeitaria = :nome,
            cnpj_confeitaria = :cnpj,
            cep_confeitaria = :cep,
            log_confeitaria = :logradouro,
            num_local = :numero,
            complemento = :complemento,
            bairro_confeitaria = :bairro,
            cidade_confeitaria = :cidade,
            uf_confeitaria = :uf,
            hora_entrada = :hora_abertura,
            hora_saida = :hora_fechamento,
            latitude = :latitude,
            longitude = :longitude
            WHERE id_confeitaria = :id");

    // Bind dos parâmetros
    $stmt->execute([
        ':nome' => $data->nome_confeitaria,
        ':cnpj' => $data->cnpj_confeitaria,
        ':cep' => $data->cep_confeitaria,
        ':logradouro' => $data->log_confeitaria,
        ':numero' => $data->num_local,
        ':complemento' => $data->complemento ?? '',
        ':bairro' => $data->bairro_confeitaria,
        ':cidade' => $data->cidade_confeitaria,
        ':uf' => $data->uf_confeitaria,
        ':hora_abertura' => $data->hora_entrada,
        ':hora_fechamento' => $data->hora_saida,
        ':latitude' => $data->latitude ?? null,
        ':longitude' => $data->longitude ?? null,
        ':id' => $data->id_confeitaria
    ]);

    // Buscar dados atualizados para retornar
    $stmt = $pdo->prepare("SELECT * FROM tb_confeitaria WHERE id_confeitaria = :id");
    $stmt->execute([':id' => $data->id_confeitaria]);
    $confeitaria = $stmt->fetch();

    echo json_encode([
        'status' => 'success',
        'message' => 'Dados atualizados com sucesso',
        'data' => $confeitaria
    ]);

} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode([
        'status' => 'error',
        'message' => 'Erro no banco de dados: ' . $e->getMessage()
    ]);
}
?>