$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$root = Split-Path -Parent $root

# 从 .env 加载环境变量（仅加载 KEY=VALUE 行）
# 注意：必须用 UTF-8 显式读取，避免中文注释导致 GBK 误读吞掉换行符
[System.IO.File]::ReadAllLines((Join-Path $root ".env"), [System.Text.Encoding]::UTF8) | Where-Object {
    $_ -match "^[A-Za-z_][A-Za-z0-9_]*="
} | ForEach-Object {
    $kv = $_ -split "=", 2
    [System.Environment]::SetEnvironmentVariable($kv[0].Trim(), $kv[1].Trim())
}

$jar = Join-Path $root "target\rag-backend-1.0.0.jar"
if (-not (Test-Path $jar)) {
    Write-Host "未找到 $jar，请先在 IDEA 中执行 mvn package"
    exit 1
}

Write-Host "启动 RAG 后端（端口 9091）..."
& "E:\idea2025.1\jbr\bin\java.exe" -jar $jar
