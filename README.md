# R venv
Virtual environment (personal library) management scripts of R language



## Usage

>   [!NOTE]
>
>   The usage documentation takes PowerShell 7 as an example.
>
>   If using other command line tools (CMD prompt, bash, ...), choose scripts which have the same base name but different extension name corresponding to the command line tool. The way of calling programs and passing arguments are different, but arguments name and usage are the same.

>   [!NOTE]
>
>   The documentation calls `Rscript` directly, because it assumes R language is in environment variable PATH. Otherwise, let the installation path of R be `$base_dir`, call `& "$base_dir\Rscript.exe"`.

### Freeze (snapshot) environment

Run the following command.

```
Rscript venv.R dump
```

Arguments:

| Name     | Required? | Default                       | Description                                                |
| -------- | --------- | ----------------------------- | ---------------------------------------------------------- |
| `--path` | No        | `.venv`                       | Path to virtual environment folder.                        |
| `--req`  | No        | `requirements.csv`            | Path to (input or output) R packages dependencies records. |
| `--cran` | No        | `https://cloud.r-project.org` | R project CRAN site URL.[^1]                               |

[^1]:  Please use either the default global site or that closest to your country.



### Restore environment

Run the following command.

```
Rscript venv.R load
```

Arguments same as `dump` mode.



### Activate

Let `$path` be the file path of virtual environment folder.

Run the following command.

```
activate.ps1 $path
```



### Deactivate

Run the following command.

```
deactivate.ps1
```

