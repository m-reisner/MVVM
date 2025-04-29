Clear-Host

$VerbosePreference = "continue"

Add-Type –assemblyName "PresentationFramework"
Add-Type –assemblyName "PresentationCore"
Add-Type –assemblyName "WindowsBase"

[xml]$xaml = Get-Content -Path $(Join-Path -Path $PSScriptRoot -ChildPath "MainWindow.xaml") -Raw
$reader=(New-Object System.Xml.XmlNodeReader $xaml)
$Window=[Windows.Markup.XamlReader]::Load( $reader )

$window.ToolTip = "Leftclick to move! Rightclick to close!"
$Window.Add_MouseRightButtonDown({
    $Window.close()
})
$Window.Add_MouseLeftButtonDown({
    $Window.DragMove()
})


$timer = $null
$timerEvent = $null

$Window.Add_Loaded({

    Write-Verbose "Starting up application"

    $timer = New-Object System.Windows.Threading.DispatcherTimer
    $timer.Interval = [TimeSpan]"0:0:1.00"

    $timerEvent = Register-ObjectEvent -InputObject $timer -EventName Tick -Action {
        $Window.Dispatcher.Invoke({
            $Window.UpdateLayout()
            Write-Verbose "Updating Window"
        })
    }

    Write-Verbose "Starting Timer"
    $timer.Start()
})

$Window.Add_Closed({
    if ($timer) {
        $timer.Stop()
        Write-Verbose "Timer stopped."
    }
    if ($timerEvent) {
        Unregister-Event -SourceIdentifier $timerEvent.Name
        $timerEvent | Remove-Job
        Write-Verbose "Timer event unregistered."
    }
    Write-Verbose "Performing cleanup"
})

$Window.ShowDialog()