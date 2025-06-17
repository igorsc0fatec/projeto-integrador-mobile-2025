<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");

include '../config.php';

$method = $_SERVER['REQUEST_METHOD'];

switch ($method) {
    case 'GET':
        handleGetRequest();
        break;
    case 'POST':
        handlePostRequest();
        break;
    default:
        echo json_encode([
            'status' => 'error',
            'message' => 'Método não permitido'
        ]);
        exit;
}

function handleGetRequest() {
    global $conn;
    
    $idConfeitaria = isset($_GET['id_confeitaria']) ? intval($_GET['id_confeitaria']) : null;
    
    if (!$idConfeitaria) {
        echo json_encode([
            'status' => 'error',
            'message' => 'ID da confeitaria é obrigatório'
        ]);
        exit;
    }

    try {
        $stmt = $conn->prepare("SELECT * FROM tb_formato WHERE id_confeitaria = ?");
        $stmt->bind_param("i", $idConfeitaria);
        $stmt->execute();
        $result = $stmt->get_result();
        
        $formatos = [];
        while ($row = $result->fetch_assoc()) {
            $formatos[] = [
                'id_formato' => $row['id_formato'],
                'desc_formato' => $row['desc_formato'],
                'valor_por_peso' => (float)$row['valor_por_peso'],
                'id_confeitaria' => $row['id_confeitaria']
            ];
        }
        
        echo json_encode([
            'status' => 'success',
            'data' => $formatos
        ]);
        
    } catch (Exception $e) {
        echo json_encode([
            'status' => 'error',
            'message' => 'Erro ao listar formatos: ' . $e->getMessage()
        ]);
    }
}

function handlePostRequest() {
    global $conn;
    
    $data = json_decode(file_get_contents("php://input"));

    if (!$data || !isset($data->descricao) || !isset($data->valorPorGrama) || !isset($data->idConfeitaria)) {
        echo json_encode([
            'status' => 'error',
            'message' => 'Dados inválidos ou ausentes'
        ]);
        exit;
    }

    try {
        $valor = (float)$data->valorPorGrama;
        
        $stmt = $conn->prepare("INSERT INTO tb_formato (desc_formato, valor_por_peso, id_confeitaria) VALUES (?, ?, ?)");
        $stmt->bind_param("sdi", $data->descricao, $valor, $data->idConfeitaria);
        
        if ($stmt->execute()) {
            $id = $conn->insert_id;
            
            echo json_encode([
                'status' => 'success',
                'message' => 'Formato cadastrado com sucesso',
                'data' => [
                    'id_formato' => $id,
                    'desc_formato' => $data->descricao,
                    'valor_por_peso' => $valor,
                    'id_confeitaria' => $data->idConfeitaria
                ]
            ]);
        } else {
            echo json_encode([
                'status' => 'error',
                'message' => 'Erro ao cadastrar formato'
            ]);
        }
    } catch (Exception $e) {
        echo json_encode([
            'status' => 'error',
            'message' => 'Erro no servidor: ' . $e->getMessage()
        ]);
    }
}
?>
