params {
    step: Integer = 0
    zip: String = 'zip'
}


process SAYHELLO {
    debug true

    script:
    """
    echo "Hello World!"
    """
}

process SAYHELLO_PYTHON {
    debug true

    script:
    """
    python -c 'print("Hello World!")'
    """
}


process SAYHELLO_PARAM {
    debug true

    input:
    val greeting

    script:
    """
    echo "$greeting"
    """
}


process SAYHELLO_FILE {

    input:
    val greeting

    output:
    path "greeting.txt"

    script:
    """
    echo "$greeting" > greeting.txt
    """
}


process UPPERCASE {

    input:
    val greeting

    output:
    path "uppercase.txt"

    script:
    """
    echo "$greeting" | tr '[:lower:]' '[:upper:]' > uppercase.txt
    """
}

process PRINTUPPER {
    debug true

    input:
    path input_file

    script:
    """
    cat $input_file
    """
}

process ZIPFILE {

    input:
    path input_file

    output:
    path "${input_file}.*"

    script:
    def command

    if (params.zip == 'zip') {
        command = "zip ${input_file}.zip $input_file"
    }
    else if (params.zip == 'gzip') {
        command = "gzip -c $input_file > ${input_file}.gz"
    }
    else if (params.zip == 'bzip2') {
        command = "bzip2 -c $input_file > ${input_file}.bz2"
    }

    """
    $command
    """
}

process ZIPFILE_ALL {

    input:
    path input_file

    output:
    path "${input_file}.*"

    script:
    """
    zip ${input_file}.zip $input_file
    gzip -c $input_file > ${input_file}.gz
    bzip2 -c $input_file > ${input_file}.bz2
    """
}

process WRITETOFILE {

    publishDir "results", mode: "copy"

    input:
    val people

    output:
    path "names.tsv"

    script:
    def lines = people.collect { person -> "${person.name}\t${person.title}"}.join("\n")

    """
    printf '%s\n' '${lines}' > names.tsv
    """
}

workflow {

    // Task 1 - create a process that says Hello World! (add debug true to the process right after initializing to be sable to print the output to the console)
    if (params.step == 1) {
        SAYHELLO()
    }

    // Task 2 - create a process that says Hello World! using Python
    if (params.step == 2) {
        SAYHELLO_PYTHON()
    }

    // Task 3 - create a process that reads in the string "Hello world!" from a channel and write it to command line
    if (params.step == 3) {
        greeting_ch = Channel.of("Hello world!")
        SAYHELLO_PARAM(greeting_ch)
    }

    // Task 4 - create a process that reads in the string "Hello world!" from a channel and write it to a file. WHERE CAN YOU FIND THE FILE?
    if (params.step == 4) {
        greeting_ch = Channel.of("Hello world!")
        SAYHELLO_FILE(greeting_ch)
    }

    // Task 5 - create a process that reads in a string and converts it to uppercase and saves it to a file as output. View the path to the file in the console
    if (params.step == 5) {
        greeting_ch = Channel.of("Hello world!")
        out_ch = UPPERCASE(greeting_ch)
        out_ch.view()
    }

    // Task 6 - add another process that reads in the resulting file from UPPERCASE and print the content to the console (debug true). WHAT CHANGED IN THE OUTPUT?
    if (params.step == 6) {
        greeting_ch = Channel.of("Hello world!")
        out_ch = UPPERCASE(greeting_ch)
        PRINTUPPER(out_ch)
    }

    
    // Task 7 - based on the paramater "zip" (see at the head of the file), create a process that zips the file created in the UPPERCASE process either in "zip", "gzip" OR "bzip2" format.
    //          Print out the path to the zipped file in the console

    if (params.step == 7) {
        greeting_ch = Channel.of("Hello world!")
    
        uppercase_ch = UPPERCASE(greeting_ch)
        zipped_ch = ZIPFILE(uppercase_ch)

        zipped_ch.view()
    }

    // Task 8 - Create a process that zips the file created in the UPPERCASE process in "zip", "gzip" AND "bzip2" format. Print out the paths to the zipped files in the console

    if (params.step == 8) {
    greeting_ch = Channel.of("Hello world!")

    uppercase_ch = UPPERCASE(greeting_ch)
    zipped_ch = ZIPFILE_ALL(uppercase_ch)

    zipped_ch.view()
}

    // Task 9 - Create a process that reads in a list of names and titles from a channel and writes them to a file.
    //          Store the file in the "results" directory under the name "names.tsv"

    if (params.step == 9) {
        in_ch = channel.of(
            ['name': 'Harry', 'title': 'student'],
            ['name': 'Ron', 'title': 'student'],
            ['name': 'Hermione', 'title': 'student'],
            ['name': 'Albus', 'title': 'headmaster'],
            ['name': 'Snape', 'title': 'teacher'],
            ['name': 'Hagrid', 'title': 'groundkeeper'],
            ['name': 'Dobby', 'title': 'hero'],
        )

        in_ch
            .collect()
            | WRITETOFILE
    }

}