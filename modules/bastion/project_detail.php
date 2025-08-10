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

// 로그인 여부 확인
if (!isset($_SESSION['user_id'])) {
    header("Location: login.php");
    exit();
}

// 프로젝트 ID 가져오기
$project_id = isset($_GET['id']) ? intval($_GET['id']) : 0;
if ($project_id <= 0) {
    die("Invalid project ID.");
}

// 프로젝트 정보 가져오기
$stmt = $conn->prepare("SELECT name, description, created_at FROM projects WHERE id = ?");
$stmt->bind_param("i", $project_id);
$stmt->execute();
$stmt->bind_result($name, $description, $created_at);
$stmt->fetch();
$stmt->close();

// 작업 목록 가져오기 (옵션)
$task_stmt = $conn->prepare("SELECT id, name, status, created_at FROM tasks WHERE project_id = ?");
$task_stmt->bind_param("i", $project_id);
$task_stmt->execute();
$tasks = $task_stmt->get_result()->fetch_all(MYSQLI_ASSOC);
$task_stmt->close();
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Project Details</title>
    <style>
        body {
            font-family: Arial, sans-serif;
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
            border-radius: 8px;
            box-shadow: 0 4px 10px rgba(0, 0, 0, 0.1);
            margin-top: 20px;
        }

        h1, h2 {
            margin: 0;
            margin-bottom: 20px;
            color: #333;
        }

        p {
            margin: 5px 0 20px;
            color: #555;
        }

        a {
            text-decoration: none;
            color: #007bff;
        }

        a:hover {
            text-decoration: underline;
        }

        .task-table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
        }

        .task-table th, .task-table td {
            padding: 10px;
            text-align: left;
            border-bottom: 1px solid #ddd;
        }

        .task-table th {
            background-color: #f4f4f4;
            color: #333;
        }

        .task-table tr:hover {
            background-color: #f9f9f9;
        }

        .add-task-btn {
            display: inline-block;
            margin-top: 20px;
            padding: 10px 15px;
            background-color: #007bff;
            color: white;
            text-decoration: none;
            border-radius: 4px;
        }

        .add-task-btn:hover {
            background-color: #0056b3;
        }
    </style>
</head>
<body>
<div class="container">
    <?php if (!empty($name)): ?>
        <h1>Project: <?= htmlspecialchars($name) ?></h1>
        <p><strong>Description:</strong> <?= htmlspecialchars($description) ?></p>
        <p><strong>Created At:</strong> <?= htmlspecialchars($created_at) ?></p>

        <h2>Tasks</h2>
        <?php if (count($tasks) > 0): ?>
            <table class="task-table">
                <thead>
                <tr>
                    <th>Task Name</th>
                    <th>Status</th>
                    <th>Created At</th>
                </tr>
                </thead>
                <tbody>
                <?php foreach ($tasks as $task): ?>
                    <tr>
                        <td><?= htmlspecialchars($task['name']) ?></td>
                        <td><?= htmlspecialchars($task['status']) ?></td>
                        <td><?= htmlspecialchars($task['created_at']) ?></td>
                    </tr>
                <?php endforeach; ?>
                </tbody>
            </table>
        <?php else: ?>
            <p>No tasks found for this project. Click below to add a new task!</p>
        <?php endif; ?>
        <a href="create_task.php?project_id=<?= $project_id ?>" class="add-task-btn">Add New Task</a>
    <?php else: ?>
        <p>Project not found. <a href="project.php">Go back to projects</a></p>
    <?php endif; ?>
</div>
</body>
</html>

