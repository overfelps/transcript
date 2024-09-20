
# Aviso: Execute este script como administrador
# Descrição: Automatiza a configuração do ambiente para o projeto de OCR

# --------------------------------------------
# Step 1: Definir o caminho do projeto
# --------------------------------------------
$projectPath = "C:\transcript"
if (!(Test-Path $projectPath)) {
    Write-Host "Criando o diretório do projeto em $projectPath..."
    New-Item -ItemType Directory -Path $projectPath
}
Set-Location $projectPath

# --------------------------------------------
# Step 2: Desinstalar Python 3.12 (se necessário)
# --------------------------------------------
Write-Host "Verificando se o Python 3.12 está instalado..."
$python12 = Get-ChildItem "HKLM:\Software\Python\PythonCore\3.12" -ErrorAction SilentlyContinue
if ($python12) {
    Write-Host "Desinstalando o Python 3.12..."
    $uninstallKey = "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\Python 3.12*"
    $uninstallString = (Get-ItemProperty $uninstallKey).UninstallString
    & $uninstallString /quiet
} else {
    Write-Host "Python 3.12 não encontrado. Prosseguindo..."
}

# --------------------------------------------
# Step 3: Instalar Python 3.10
# --------------------------------------------
Write-Host "Baixando e instalando o Python 3.10..."
$pythonInstaller = "python-3.10.11-amd64.exe"
if (!(Test-Path $pythonInstaller)) {
    Invoke-WebRequest -Uri "https://www.python.org/ftp/python/3.10.11/$pythonInstaller" -OutFile $pythonInstaller
}
Start-Process -FilePath ".\$pythonInstaller" -ArgumentList "/quiet InstallAllUsers=1 PrependPath=1 Include_test=0 Include_launcher=0" -Wait

# --------------------------------------------
# Step 4: Criar e ativar o ambiente virtual
# --------------------------------------------
Write-Host "Criando o ambiente virtual..."
python -m venv venv

Write-Host "Ativando o ambiente virtual..."
$env:Path = "$projectPath\venv\Scripts;$env:Path"

# --------------------------------------------
# Step 5: Atualizar o pip
# --------------------------------------------
Write-Host "Atualizando o pip..."
python -m pip install --upgrade pip

# --------------------------------------------
# Step 6: Instalar as dependências
# --------------------------------------------
Write-Host "Instalando as dependências..."
$packages = @(
    "numpy==1.24.3",
    "torch==2.0.1",
    "easyocr==1.7.1",
    "pytesseract",
    "scikit-image",
    "opencv-python-headless"
)
foreach ($package in $packages) {
    pip install $package
}

# --------------------------------------------
# Step 7: Configurar a variável de ambiente TESSDATA_PREFIX
# --------------------------------------------
Write-Host "Configurando a variável de ambiente TESSDATA_PREFIX..."
[System.Environment]::SetEnvironmentVariable("TESSDATA_PREFIX", "$projectPath\tessdata", "Machine")

# --------------------------------------------
# Step 8: Instalar o Tesseract OCR
# --------------------------------------------
Write-Host "Baixando e instalando o Tesseract OCR..."
$tesseractInstaller = "tesseract-ocr-w64-setup.exe"
if (!(Test-Path $tesseractInstaller)) {
    Invoke-WebRequest -Uri "https://digi.bib.uni-mannheim.de/tesseract/tesseract-ocr-w64-setup-v5.3.1.20230401.exe" -OutFile $tesseractInstaller
}
Start-Process -FilePath ".\$tesseractInstaller" -ArgumentList "/SILENT" -Wait

# --------------------------------------------
# Step 9: Adicionar o Tesseract ao PATH
# --------------------------------------------
Write-Host "Adicionando o Tesseract ao PATH..."
$tesseractPath = "C:\Program Files\Tesseract-OCR"
$machinePath = [Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::Machine)
if ($machinePath -notlike "*$tesseractPath*") {
    $newPath = "$machinePath;$tesseractPath"
    [Environment]::SetEnvironmentVariable("Path", $newPath, [System.EnvironmentVariableTarget]::Machine)
}

# --------------------------------------------
# Step 10: Confirmar as instalações
# --------------------------------------------
Write-Host "Confirmando as instalações..."
$tesseractVersion = tesseract --version
Write-Host $tesseractVersion

$numpyVersion = python -c "import numpy; print('Versão do numpy:', __import__('numpy').__version__)"
Write-Host $numpyVersion

Write-Host "Ambiente configurado com sucesso!"
