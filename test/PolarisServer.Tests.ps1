$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
. "$here\$sut"

Describe "Test webserver use" {
    Context "Test different route responses" {
        It "test /helloworld route" {
            $result = Invoke-WebRequest -Uri "http://localhost:$Port/helloworld"
            $result.Content | Should Be 'Hello World'
            $result.StatusCode | Should Be 200
        }

        It "test /helloworld route with query params that do nothing" {
            $result = Invoke-WebRequest -Uri "http://localhost:$Port/helloworld?test=true&another=one"
            $result.Content | Should Be 'Hello World'
            $result.StatusCode | Should Be 200
        }

        It "test /hellome route with query param" {
            $result = Invoke-WebRequest -Uri "http://localhost:$Port/hellome?name=PowerShell"
            $result.Content | Should Be 'Hello PowerShell'
            $result.StatusCode | Should Be 200
        }

        It "test /hellome route without query param" {
            $result = Invoke-WebRequest -Uri "http://localhost:$Port/hellome"
            $result.Content | Should Be 'Hello World'
            $result.StatusCode | Should Be 200
        }

        It "test /wow route" {
            $result = Invoke-RestMethod -Uri "http://localhost:$Port/wow" -Method POST
            $result.wow | Should Be $true
        }

        It "test /example route" {
            $result = Invoke-WebRequest -Uri "http://localhost:$Port/example"
            $result.Content | Should Be 'test file'
            $result.StatusCode | Should Be 200
        }

        It "test /public/index.html static route" {
            $expectedHtml = `
'<div>hello world</div>

<img src="test.png" alt="yay" />
<img src="test.png" alt="yay" />
<img src="test1.png" alt="yay" />'

            $result = Invoke-WebRequest -Uri "http://localhost:$Port/public/index.html"
            $result.Content | Should Be $expectedHtml
            $result.StatusCode | Should Be 200
        }

        AfterAll {
            Stop-Polaris
        }
    }

    Context "Test starting and stopping of the server" {
        BeforeAll {
            Stop-Polaris
            Start-Polaris -Port $Port

            $result = Invoke-WebRequest -Uri "http://localhost:$Port/helloworld"
            $result.StatusCode | Should Be 200
        }

        It "Can properly shut down the server" {
            Stop-Polaris

            { Invoke-WebRequest -Uri "http://localhost:$Port/helloworld" } | Should Throw
        }
    }
}