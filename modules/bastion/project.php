<?php
session_start();
error_reporting(E_ALL);
ini_set('display_errors', 1);

// 데이터베이스 연결 설정
$host = 'localhost';
$db_user = 'test_user';
$db_password = 'test_password';
$db_name = 'collabtool';

// MySQL 연결
$conn = new mysqli($host, $db_user, $db_password, $db_name);
if ($conn->connect_error) {
    die("Database connection failed: " . $conn->connect_error);
}

// 로그인 여부 확인
if (!isset($_SESSION['user_id'])) {
    header("Location: login.php");
    exit();
}

$user_id = $_SESSION['user_id'];

// 프로젝트 목록 가져오기
$stmt = $conn->prepare("SELECT id, name, description, created_at FROM projects WHERE created_by = ?");
if (!$stmt) {
    die("Statement preparation failed: " . $conn->error);
}
$stmt->bind_param("i", $user_id);
$stmt->execute();
$result = $stmt->get_result();
$projects = $result->fetch_all(MYSQLI_ASSOC);
$stmt->close();
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Your Projects</title>
    <style>
        body {
            font-family: 'Arial', sans-serif;
            margin: 0;
            padding: 0;
            background-color: #f4f4f9;
            display: flex;
            justify-content: center;
            align-items: flex-start;
            min-height: 100vh;
        }

        .container {
            width: 90%;
            max-width: 800px;
            background: white;
            padding: 20px;
            border-radius: 10px;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
            margin-top: 30px;
        }

        h1 {
            margin-bottom: 20px;
            font-size: 28px;
            color: #333;
            text-align: center;
        }

        a {
            display: inline-block;
            margin-bottom: 20px;
            padding: 10px 20px;
            background-color: #007bff;
            color: white;
            text-decoration: none;
            border-radius: 5px;
            font-size: 16px;
            text-align: center;
        }

        a:hover {
            background-color: #0056b3;
        }

        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 10px;
        }

        table th, table td {
            padding: 14px;
            text-align: left;
            border-bottom: 1px solid #ddd;
        }

        table th {
            background-color: #f4f4f4;
            color: #333;
            font-weight: bold;
        }

        table tr:hover {
            background-color: #f9f9f9;
        }

        table td {
            color: #555;
        }

        .empty-message {
            text-align: center;
            font-size: 16px;
            color: #777;
            margin-top: 20px;
        }

        /* 반응형 처리 */
        @media (max-width: 600px) {
            h1 {
                font-size: 22px;
            }

            a {
                font-size: 14px;
                padding: 8px 16px;
            }

            table th, table td {
                padding: 10px;
                font-size: 14px;
            }
        }
    </style>
</head>
<body>
<div class="container">
    <h1>Your Projects</h1>
    <a href="create_project.php">Create New Project</a>
    <?php if (count($projects) > 0): ?>
        <table>
            <thead>
            <tr>
                <th>Project Name</th>
                <th>Description</th>
                <th>Created At</th>
            </tr>
            </thead>
            <tbody>
            <?php foreach ($projects as $project): ?>
                <tr>
                    <td>
                        <a href="project_detail.php?id=<?= htmlspecialchars($project['id']) ?>">
                            <?= htmlspecialchars($project['name']) ?>
                        </a>
                    </td>
                    <td><?= htmlspecialchars($project['description']) ?></td>
                    <td><?= htmlspecialchars($project['created_at']) ?></td>
                </tr>
            <?php endforeach; ?>
            </tbody>
        </table>
    <?php else: ?>
        <p class="empty-message">No projects found. Click "Create New Project" to add your first project!</p>
    <?php endif; ?>
</div>
</body>
</html>

