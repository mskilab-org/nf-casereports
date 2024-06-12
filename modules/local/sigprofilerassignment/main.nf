process SIGPROFILERASSIGNMENT {

    tag "$meta.id"
    label 'process_medium'

    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        '/gpfs/data/imielinskilab/singularity_files/nextflow_singularity_cache/mskilab-sigprofilerassignment-0.0.3.img':
        'mskilab/sigprofilerassignment:0.0.3' }"

    input:
    tuple val(meta), path(vcf), path(tbi)
    val(genome)
    val(cosmic_version)

    output:
    tuple val(meta), path("Assignment_Solution/**/*.txt")    , emit: sigs, optional: true
    path "versions.yml"                                     , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args        = task.ext.args ?: ''
    def prefix      = task.ext.prefix ?: "${meta.id}"
    def VERSION    = '0.1' // WARN: Version information not provided by tool on CLI. Please update this string when bumping container versions.

    """
    export SIGPROFILER_PATH=\$(echo "${baseDir}/bin/sigprofilerassignment.py")

    python \$SIGPROFILER_PATH \\
    --input-vcf ${vcf} \\
    --genome ${genome} \\
    --cosmic-version ${cosmic_version} \\
    --output-directory ./ \\

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        sigprofilerassignment: ${VERSION}
    END_VERSIONS

    """

    stub:
    prefix = task.ext.prefix ?: "${meta.id}"
    def VERSION = '0.1' // WARN: Version information not provided by tool on CLI. Please update this string when bumping container versions.
    """
    touch signatures.txt

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        sigprofiler: ${VERSION}
    END_VERSIONS
    """

}
