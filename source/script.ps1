# Укажите пути к вашим папкам
$folder1 = "C:\Users\dimad\GitHub\PackFramework\source\neoforge\all"
$folder2 = "C:\Users\dimad\GitHub\PackFramework\source\fabric\all"
$destination = "C:\Users\dimad\GitHub\PackFramework\source\shared\all"

# Получаем список всех файлов из обеих папок рекурсивно
$files1 = Get-ChildItem -Path $folder1 -Recurse -File
$files2 = Get-ChildItem -Path $folder2 -Recurse -File

# Извлекаем только имена файлов
$names1 = $files1.Name
$names2 = $files2.Name

# Находим общие имена файлов
$commonNames = $names1 | Select-Object -Unique | Where-Object { $names2 -contains $_ }

# Копируем совпадающие файлы из первой папки в третью папку, сохраняя структуру папок
foreach ($name in $commonNames) {
    # Находим все файлы с этим именем в первой папке
    $matchingFiles1 = $files1 | Where-Object { $_.Name -eq $name }
    foreach ($file in $matchingFiles1) {
        # Определяем относительный путь файла относительно первой папки
        $relativePath = $file.FullName.Substring($folder1.Length)
        # Создаем полный путь в папке назначения
        $destinationPath = Join-Path $destination $relativePath
        # Создаем директорию назначения, если она не существует
        $destinationDir = Split-Path $destinationPath
        if (!(Test-Path $destinationDir)) {
            New-Item -ItemType Directory -Path $destinationDir -Force | Out-Null
        }
        # Копируем файл в соответствующее место назначения
        Copy-Item -Path $file.FullName -Destination $destinationPath -Force
        # Удаляем файл из первой папки
        Remove-Item -Path $file.FullName -Force
    }

    # Находим все файлы с этим именем во второй папке
    $matchingFiles2 = $files2 | Where-Object { $_.Name -eq $name }
    foreach ($file in $matchingFiles2) {
        # Определяем относительный путь файла относительно второй папки
        $relativePath = $file.FullName.Substring($folder2.Length)
        # Создаем полный путь в папке назначения
        $destinationPath = Join-Path $destination $relativePath
        # Создаем директорию назначения, если она не существует
        $destinationDir = Split-Path $destinationPath
        if (!(Test-Path $destinationDir)) {
            New-Item -ItemType Directory -Path $destinationDir -Force | Out-Null
        }
        # Копируем файл в соответствующее место назначения
        Copy-Item -Path $file.FullName -Destination $destinationPath -Force
        # Удаляем файл из второй папки
        Remove-Item -Path $file.FullName -Force
    }
}
