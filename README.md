# NGS_Nextflow_Exam_07.10.25
## NOTE:
Because I am using macOS, the mafft package did not work properly when installed through Bioconda (conda environment).
To resolve this, I installed mafft using Homebrew instead:

    brew install mafft

As a result, the MAFFT process in this workflow runs directly on the system (without using a conda environment).

However, the TRIMAL process works correctly with Bioconda, so it continues to use the conda environment.
To execute the workflow, use the following command:

    nextflow run NGS_Exam.nf -profile conda
