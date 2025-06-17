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
        // Consulta para obter pedidos normais
        $query = "
            SELECT 
                p.id_pedido,
                p.valor_total,
                p.desconto,
                p.data_pedido,
                s.tipo_status AS status,
                p.frete,
                c.nome_cliente,
                c.cpf_cliente,
                ec.log_cliente,
                ec.num_local,
                ec.bairro_cliente,
                ec.cidade_cliente,
                ec.uf_cliente,
                fp.forma_pagamento,
                GROUP_CONCAT(CONCAT(pr.nome_produto, ' (', ip.quantidade, ' un)') SEPARATOR ', ') AS itens,
                GROUP_CONCAT(pr.valor_produto SEPARATOR ', ') AS precos,
                GROUP_CONCAT(ip.quantidade SEPARATOR ', ') AS quantidades
            FROM 
                tb_pedido p
            JOIN 
                tb_itens_pedido ip ON p.id_pedido = ip.id_pedido
            JOIN 
                tb_produto pr ON ip.id_produto = pr.id_produto
            JOIN 
                tb_cliente c ON p.id_cliente = c.id_cliente
            JOIN 
                tb_endereco_cliente ec ON p.id_endereco_cliente = ec.id_endereco_cliente
            JOIN 
                tb_forma_pagamento fp ON p.id_forma_pagamento = fp.id_forma_pagamento
            JOIN
                tb_status s ON p.id_status = s.id_status
            WHERE 
                pr.id_confeitaria = ?
            GROUP BY 
                p.id_pedido
            ORDER BY 
                p.data_pedido DESC
        ";

        
        $stmt = $conn->prepare($query);
        $stmt->bind_param("i", $idConfeitaria);
        $stmt->execute();
        $result = $stmt->get_result();
        
        $pedidos = [];
        while ($row = $result->fetch_assoc()) {
            $pedidos[] = [
                'id_pedido' => $row['id_pedido'],
                'valor_total' => (float)$row['valor_total'],
                'desconto' => (float)$row['desconto'],
                'data_pedido' => $row['data_pedido'],
                'status' => $row['status'],
                'frete' => (float)$row['frete'],
                'cliente' => [
                    'nome' => $row['nome_cliente'],
                    'cpf' => $row['cpf_cliente'],
                    'endereco' => $row['log_cliente'] . ', ' . $row['num_local'] . ' - ' . 
                                  $row['bairro_cliente'] . ', ' . $row['cidade_cliente'] . '/' . $row['uf_cliente']
                ],
                'forma_pagamento' => $row['forma_pagamento'],
                'itens' => $row['itens'],
                'tipo' => 'normal'
            ];
        }
        
        // Consulta para obter pedidos personalizados
        $queryPersonalizado = "
            SELECT 
                pp.id_pedido_personalizado,
                pp.valor_total,
                pp.desconto,
                pp.data_pedido,
                s.tipo_status AS status,
                pp.frete,
                pp.peso,
                c.nome_cliente,
                c.cpf_cliente,
                ec.log_cliente,
                ec.num_local,
                ec.bairro_cliente,
                ec.cidade_cliente,
                ec.uf_cliente,
                fp.forma_pagamento,
                per.nome_personalizado,
                m.desc_massa AS massa,
                r.desc_recheio AS recheio,
                cb.desc_cobertura AS cobertura,
                f.desc_formato AS formato,
                d.desc_decoracao AS decoracao
            FROM 
                tb_pedido_personalizado pp
            JOIN 
                tb_personalizado per ON pp.id_personalizado = per.id_personalizado
            JOIN 
                tb_cliente c ON pp.id_cliente = c.id_cliente
            LEFT JOIN 
                tb_endereco_cliente ec ON pp.id_endereco_cliente = ec.id_endereco_cliente
            LEFT JOIN 
                tb_forma_pagamento fp ON pp.id_forma_pagamento = fp.id_forma_pagamento
            LEFT JOIN 
                tb_massa m ON pp.id_massa = m.id_massa
            LEFT JOIN 
                tb_recheio r ON pp.id_recheio = r.id_recheio
            LEFT JOIN 
                tb_cobertura cb ON pp.id_cobertura = cb.id_cobertura
            LEFT JOIN 
                tb_formato f ON pp.id_formato = f.id_formato
            LEFT JOIN 
                tb_decoracao d ON pp.id_decoracao = d.id_decoracao
            JOIN
                tb_status s ON pp.id_status = s.id_status
            WHERE 
                per.id_confeitaria = ?
            ORDER BY 
                pp.data_pedido DESC
        ";
        
        $stmtPersonalizado = $conn->prepare($queryPersonalizado);
        $stmtPersonalizado->bind_param("i", $idConfeitaria);
        $stmtPersonalizado->execute();
        $resultPersonalizado = $stmtPersonalizado->get_result();
        
        while ($row = $resultPersonalizado->fetch_assoc()) {
            $pedidos[] = [
                'id_pedido' => $row['id_pedido_personalizado'],
                'valor_total' => (float)$row['valor_total'],
                'desconto' => (float)$row['desconto'],
                'data_pedido' => $row['data_pedido'],
                'status' => $row['status'],
                'frete' => (float)$row['frete'],
                'peso' => (float)$row['peso'],
                'cliente' => [
                    'nome' => $row['nome_cliente'],
                    'cpf' => $row['cpf_cliente'],
                    'endereco' => $row['log_cliente'] . ', ' . $row['num_local'] . ' - ' . 
                                  $row['bairro_cliente'] . ', ' . $row['cidade_cliente'] . '/' . $row['uf_cliente']
                ],
                'forma_pagamento' => $row['forma_pagamento'],
                'item' => [
                    'nome' => $row['nome_personalizado'],
                    'massa' => $row['massa'],
                    'recheio' => $row['recheio'],
                    'cobertura' => $row['cobertura'],
                    'formato' => $row['formato'],
                    'decoracao' => $row['decoracao']
                ],
                'tipo' => 'personalizado'
            ];
        }
        
        // Ordenar todos os pedidos por data (mais recente primeiro)
        usort($pedidos, function($a, $b) {
            return strtotime($b['data_pedido']) - strtotime($a['data_pedido']);
        });
        
        echo json_encode([
            'status' => 'success',
            'data' => $pedidos
        ]);
        
    } catch (Exception $e) {
        echo json_encode([
            'status' => 'error',
            'message' => 'Erro ao listar pedidos: ' . $e->getMessage()
        ]);
    }
}
?>