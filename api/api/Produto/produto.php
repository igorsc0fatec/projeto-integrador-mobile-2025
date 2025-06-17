<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");
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
    case 'PUT':
        handlePutRequest();
        break;
    case 'DELETE':
        handleDeleteRequest();
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
    $idProduto = isset($_GET['id_produto']) ? intval($_GET['id_produto']) : null;
    
    try {
        if ($idProduto) {
            // Buscar um produto específico
            $stmt = $conn->prepare("
                SELECT p.*, tp.desc_tipo_produto 
                FROM tb_produto p
                JOIN tb_tipo_produto tp ON p.id_tipo_produto = tp.id_tipo_produto
                WHERE p.id_produto = ?
            ");
            $stmt->bind_param("i", $idProduto);
        } elseif ($idConfeitaria) {
            // Buscar todos os produtos de uma confeitaria
            $stmt = $conn->prepare("
                SELECT p.*, tp.desc_tipo_produto 
                FROM tb_produto p
                JOIN tb_tipo_produto tp ON p.id_tipo_produto = tp.id_tipo_produto
                WHERE p.id_confeitaria = ? AND p.produto_ativo = 1
            ");
            $stmt->bind_param("i", $idConfeitaria);
        } else {
            echo json_encode([
                'status' => 'error',
                'message' => 'ID da confeitaria ou ID do produto é obrigatório'
            ]);
            exit;
        }
        
        $stmt->execute();
        $result = $stmt->get_result();
        
        if ($idProduto) {
            $produto = $result->fetch_assoc();
            if ($produto) {
                echo json_encode([
                    'status' => 'success',
                    'data' => [
                        'id_produto' => $produto['id_produto'],
                        'nome_produto' => $produto['nome_produto'],
                        'desc_produto' => $produto['desc_produto'],
                        'valor_produto' => (float)$produto['valor_produto'],
                        'frete' => (float)$produto['frete'],
                        'produto_ativo' => (bool)$produto['produto_ativo'],
                        'limite_entrega' => $produto['limite_entrega'],
                        'img_produto' => $produto['img_produto'],
                        'tipo_produto' => $produto['desc_tipo_produto'],
                        'id_tipo_produto' => $produto['id_tipo_produto'],
                        'id_confeitaria' => $produto['id_confeitaria']
                    ]
                ]);
            } else {
                echo json_encode([
                    'status' => 'error',
                    'message' => 'Produto não encontrado'
                ]);
            }
        } else {
            $produtos = [];
            while ($row = $result->fetch_assoc()) {
                $produtos[] = [
                    'id_produto' => $row['id_produto'],
                    'nome_produto' => $row['nome_produto'],
                    'desc_produto' => $row['desc_produto'],
                    'valor_produto' => (float)$row['valor_produto'],
                    'frete' => (float)$row['frete'],
                    'produto_ativo' => (bool)$row['produto_ativo'],
                    'limite_entrega' => $row['limite_entrega'],
                    'img_produto' => $row['img_produto'],
                    'tipo_produto' => $row['desc_tipo_produto'],
                    'id_tipo_produto' => $row['id_tipo_produto'],
                    'id_confeitaria' => $row['id_confeitaria']
                ];
            }
            
            echo json_encode([
                'status' => 'success',
                'data' => $produtos
            ]);
        }
        
    } catch (Exception $e) {
        echo json_encode([
            'status' => 'error',
            'message' => 'Erro ao listar produtos: ' . $e->getMessage()
        ]);
    }
}

function handlePostRequest() {
    global $conn;
    
    $data = json_decode(file_get_contents("php://input"));

    if (!$data || !isset($data->nome_produto) || !isset($data->desc_produto) || 
        !isset($data->valor_produto) || !isset($data->id_tipo_produto) || 
        !isset($data->id_confeitaria)) {
        echo json_encode([
            'status' => 'error',
            'message' => 'Dados inválidos ou ausentes'
        ]);
        exit;
    }

    try {
        // Valores padrão para campos opcionais
        $frete = isset($data->frete) ? (float)$data->frete : 0.00;
        $limite_entrega = isset($data->limite_entrega) ? intval($data->limite_entrega) : 1;
        $img_produto = isset($data->img_produto) ? $data->img_produto : null;
        
        $stmt = $conn->prepare("
            INSERT INTO tb_produto (
                nome_produto, 
                desc_produto, 
                valor_produto, 
                frete, 
                produto_ativo, 
                limite_entrega, 
                img_produto, 
                id_tipo_produto, 
                id_confeitaria
            ) VALUES (?, ?, ?, ?, 1, ?, ?, ?, ?)
        ");
        
        $stmt->bind_param(
            "ssddissi", 
            $data->nome_produto, 
            $data->desc_produto, 
            $data->valor_produto, 
            $frete, 
            $limite_entrega, 
            $img_produto, 
            $data->id_tipo_produto, 
            $data->id_confeitaria
        );
        
        if ($stmt->execute()) {
            $id = $conn->insert_id;
            
            echo json_encode([
                'status' => 'success',
                'message' => 'Produto cadastrado com sucesso',
                'data' => [
                    'id_produto' => $id,
                    'nome_produto' => $data->nome_produto,
                    'desc_produto' => $data->desc_produto,
                    'valor_produto' => (float)$data->valor_produto,
                    'frete' => $frete,
                    'produto_ativo' => true,
                    'limite_entrega' => $limite_entrega,
                    'img_produto' => $img_produto,
                    'id_tipo_produto' => $data->id_tipo_produto,
                    'id_confeitaria' => $data->id_confeitaria
                ]
            ]);
        } else {
            echo json_encode([
                'status' => 'error',
                'message' => 'Erro ao cadastrar produto'
            ]);
        }
    } catch (Exception $e) {
        echo json_encode([
            'status' => 'error',
            'message' => 'Erro no servidor: ' . $e->getMessage()
        ]);
    }
}

function handlePutRequest() {
    global $conn;
    
    $data = json_decode(file_get_contents("php://input"));

    if (!$data || !isset($data->id_produto) || !isset($data->nome_produto) || 
        !isset($data->desc_produto) || !isset($data->valor_produto) || 
        !isset($data->id_tipo_produto)) {
        echo json_encode([
            'status' => 'error',
            'message' => 'Dados inválidos ou ausentes'
        ]);
        exit;
    }

    try {
        // Valores padrão para campos opcionais
        $frete = isset($data->frete) ? (float)$data->frete : 0.00;
        $limite_entrega = isset($data->limite_entrega) ? intval($data->limite_entrega) : 1;
        $img_produto = isset($data->img_produto) ? $data->img_produto : null;
        $produto_ativo = isset($data->produto_ativo) ? intval($data->produto_ativo) : 1;
        
        $stmt = $conn->prepare("
            UPDATE tb_produto SET
                nome_produto = ?, 
                desc_produto = ?, 
                valor_produto = ?, 
                frete = ?, 
                produto_ativo = ?, 
                limite_entrega = ?, 
                img_produto = ?, 
                id_tipo_produto = ?
            WHERE id_produto = ?
        ");
        
        $stmt->bind_param(
            "ssddiissi", 
            $data->nome_produto, 
            $data->desc_produto, 
            $data->valor_produto, 
            $frete, 
            $produto_ativo, 
            $limite_entrega, 
            $img_produto, 
            $data->id_tipo_produto, 
            $data->id_produto
        );
        
        if ($stmt->execute()) {
            echo json_encode([
                'status' => 'success',
                'message' => 'Produto atualizado com sucesso',
                'data' => [
                    'id_produto' => $data->id_produto,
                    'nome_produto' => $data->nome_produto,
                    'desc_produto' => $data->desc_produto,
                    'valor_produto' => (float)$data->valor_produto,
                    'frete' => $frete,
                    'produto_ativo' => (bool)$produto_ativo,
                    'limite_entrega' => $limite_entrega,
                    'img_produto' => $img_produto,
                    'id_tipo_produto' => $data->id_tipo_produto,
                    'id_confeitaria' => $data->id_confeitaria
                ]
            ]);
        } else {
            echo json_encode([
                'status' => 'error',
                'message' => 'Erro ao atualizar produto'
            ]);
        }
    } catch (Exception $e) {
        echo json_encode([
            'status' => 'error',
            'message' => 'Erro no servidor: ' . $e->getMessage()
        ]);
    }
}

function handleDeleteRequest() {
    global $conn;
    
    $data = json_decode(file_get_contents("php://input"));

    if (!$data || !isset($data->id_produto)) {
        echo json_encode([
            'status' => 'error',
            'message' => 'ID do produto é obrigatório'
        ]);
        exit;
    }

    try {
        // Em vez de deletar, vamos desativar o produto
        $stmt = $conn->prepare("UPDATE tb_produto SET produto_ativo = 0 WHERE id_produto = ?");
        $stmt->bind_param("i", $data->id_produto);
        
        if ($stmt->execute()) {
            echo json_encode([
                'status' => 'success',
                'message' => 'Produto desativado com sucesso'
            ]);
        } else {
            echo json_encode([
                'status' => 'error',
                'message' => 'Erro ao desativar produto'
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