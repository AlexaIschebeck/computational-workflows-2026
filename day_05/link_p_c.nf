#!/usr/bin/env nextflow

process SPLITLETTERS {

    input:
    tuple val(meta), val(in_str), val(out_name)

    output:
    tuple val(meta), path("${out_name}_*.txt")

    script:
    """
    echo -n "${in_str}" | fold -w ${meta.block_size} | \
    awk '{print > "${out_name}_" NR ".txt"}'
    """
}

process CONVERTTOUPPER {

    debug true

    input:
    path input_file

    script:
    """
    tr '[:lower:]' '[:upper:]' < $input_file
    """
}

workflow { 
    // 1. Read in the samplesheet (samplesheet_2.csv) into a channel. The block_size will be the meta-map
    // 2. Create a process that splits the "in_str" into sizes with size block_size. The output will be a file for each block, named with the prefix as seen in the samplesheet_2
    // 4. Feed these files into a process that converts the strings to uppercase. The resulting strings should be written to stdout


    // read in samplesheet

    in_ch = channel
        .fromPath('samplesheet_2.csv')
        .splitCsv(header: true)
        .map { row ->
            def meta = [
                block_size: row.block_size as Integer
            ]

            [meta, row.input_str, row.out_name]
        }


    // split the input string into chunks

    split_ch = SPLITLETTERS(in_ch)


    // lets remove the metamap to make it easier for us, as we won't need it anymore

    files_ch = split_ch
        .map { meta, files -> files }
        .flatten()


    // convert the chunks to uppercase and save the files to the results directory

    upper_ch = CONVERTTOUPPER(files_ch)

}