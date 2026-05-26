$ErrorActionPreference = 'Stop'
$port = 8765
$filePath = 'D:\Downloads\AcademicDash_Final (1).html'
$listener = [System.Net.Sockets.TcpListener]::new([System.Net.IPAddress]::Parse('127.0.0.1'), $port)
$listener.Start()
while ($true) {
  $client = $listener.AcceptTcpClient()
  try {
    $stream = $client.GetStream()
    $reader = [System.IO.StreamReader]::new($stream)
    [void]$reader.ReadLine()
    while (($headerLine = $reader.ReadLine()) -ne $null -and $headerLine -ne '') {}
    $bytes = [System.IO.File]::ReadAllBytes($filePath)
    $header = "HTTP/1.1 200 OK`r`nContent-Type: text/html; charset=utf-8`r`nContent-Length: $($bytes.Length)`r`nCache-Control: no-store`r`nConnection: close`r`n`r`n"
    $headerBytes = [System.Text.Encoding]::ASCII.GetBytes($header)
    $stream.Write($headerBytes, 0, $headerBytes.Length)
    $stream.Write($bytes, 0, $bytes.Length)
  } catch {
  } finally {
    try { $client.Close() } catch {}
  }
}
