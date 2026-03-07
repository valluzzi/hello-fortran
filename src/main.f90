PROGRAM HelloWorld
    use module_version
    implicit none
    character(len=:), allocatable :: vstr

    PRINT *, "Hello World!"
    vstr = get_version_string()
    PRINT *, 'Version:', trim(vstr)

END PROGRAM HelloWorld
