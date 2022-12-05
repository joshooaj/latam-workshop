function New-MarkdownTable {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline, Position = 0)]
        [object[]]
        $InputObject,

        # Specifies an explicit list of columns. Only the specified columns will
        # be included in the table, and if the objects lack a matching property,
        # an error will be thrown.
        [Parameter()]
        [string[]]
        $Columns,

        # Specifies the maximum column width before truncating values with elipses.
        [Parameter()]
        [ValidateRange(4, [int]::MaxValue)]
        [int]
        $MaxColumnWidth = [int]::MaxValue
    )

    begin {
        $columnSize = @{}
        $rows = [system.collections.generic.list[object]]::new()
    }

    process {
        foreach ($obj in $InputObject) {
            if ($Columns.Count -eq 0) {
                $Columns = $obj.psobject.properties.Name
            }
            $row = $obj | Select-Object -Property $Columns
            foreach ($column in $Columns) {
                if (-not $columnSize.ContainsKey($column)) {
                    $columnSize[$column] = [math]::Min($column.Length, $MaxColumnWidth)
                }

                if ($null -eq $row.$column) {
                    $row.$column = [string]::Empty
                } else {
                    $row.$column = $row.$column.ToString()
                }

                if ($row.$column.Length -gt $MaxColumnWidth) {
                    $row.$column = $row.$column.Substring(0, $MaxColumnWidth - 3) + '...'
                }

                $columnSize[$column] = [math]::Max($columnSize[$column], $row.$column.Length)
            }
            $rows.Add($row)
        }
    }

    end {
        $sb = [text.stringbuilder]::new()

        $null = $sb.Append('| ')
        $values = $Columns | Foreach-Object {
            $width = $columnSize[$_]
            $value = $_
            if ($value.Length -gt $MaxColumnWidth) {
                $value = $value.Substring(0, $MaxColumnWidth - 3) + '...'
            }
            [string]::Format("{0, $($width * -1)}", $value)
        }
        $null = $sb.Append($values -join ' | ')
        $null = $sb.AppendLine(' |')
        $separator = '| ' + (($Columns | Foreach-Object { '-' * $columnSize[$_] }) -join ' | ') + ' |'
        $null = $sb.AppendLine($separator)

        foreach ($row in $rows) {
            $null = $sb.Append('| ')
            $values = $Columns | Foreach-Object {
                $width = $columnSize[$_]
                $value = $row.$_.ToString()
                if ($value.Length -gt $MaxColumnWidth) {
                    $value = $value.Substring(0, $MaxColumnWidth - 3) + '...'
                }
                [string]::Format("{0, $($width * -1)}", $value)
            }
            $null = $sb.Append($values -join ' | ')
            $null = $sb.AppendLine(' |')
        }
        $sb.ToString()
    }
}
