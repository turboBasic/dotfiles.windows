$KnownFolders = [enum]::GetNames([Environment+SpecialFolder]) |
    ForEach-Object {
      [psCustomObject]@{ 
          Name =  $_
          Value = [Environment]::GetFolderPath($_)
          Scope = $( if($_ -in @( 'CommonAdminTools',
                                  'CommonApplicationData',
                                  'CommonDesktopDirectory',
                                  'CommonDocuments',
                                  'CommonMusic',
                                  'CommonOemLinks',
                                  'CommonPictures',
                                  'CommonProgramFiles',
                                  'CommonProgramFilesX86',
                                  'CommonPrograms',
                                  'CommonStartMenu',
                                  'CommonStartup',
                                  'CommonTemplates',
                                  'CommonVideos',
                                  'Fonts',
                                  'LocalizedResources',
                                  'MyComputer',
                                  'ProgramFiles',
                                  'ProgramFilesX86',
                                  'Resources',
                                  'System',
                                  'SystemX86',
                                  'Windows'
                                ) 
                     )
                        { 'Machine' }
                     else
                        { 'User' }
          )
      }
    } |
    Sort-Object Scope, Name  