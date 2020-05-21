#!/usr/bin/env bash

# Copyright (C) 2018 Jasper Boom

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License version 3 as
# published by the Free Software Foundation.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU Affero General Public License for more details.

# You should have received a copy of the GNU Affero General Public License
# along with this program. If not, see <https://www.gnu.org/licenses/>.

# Prequisites:
# - sudo apt-get install python
# - sudo apt-get install python-pip
# - sudo pip install cutadapt

# The runCutAdapt function.
# This function calls the CutAdapt tool and processes the fastQ file(s).
runCutAdapt() {
    cutadapt --quiet --format=fastq ${strProcess} ${flInput} > ${flOutput}
}

# The prepareCutAdapt function.
# This function creates a command string based on user input. The command string
# is formatted for CutAdapt. When a trimming option has been set to a number
# higher than 0, the option is included in the command string. Every option
# has a check build in for when the command string has not been initialised yet.
prepareCutAdapt() {
    strProcess=""
    if [ "${disAmbiguous}" -gt 1 ]
    then
        strProcess="--max-n=${disAmbiguous}"
    fi
    if [ "${disBelow}" -gt 0 ]
    then
        if [ -z "${strProcess}" ]
        then
            strProcess="--minimum-length=${disBelow}"
        else
            strProcess=${strProcess}" --minimum-length=${disBelow}"
        fi
    fi
    if [ "${disAbove}" -gt 0 ]
    then
        if [ -z "${strProcess}" ]
        then
            strProcess="--maximum-length=${disAbove}"
        else
            strProcess=${strProcess}" --maximum-length=${disAbove}"
        fi
    fi
    if [ "${disForward}" -gt 0 ]
    then
        if [ -z "${strProcess}" ]
        then
            strProcess="--cut=${disForward}"
        else
            strProcess=${strProcess}" --cut=${disForward}"
        fi
    fi
    if [ "${disReverse}" -gt 0 ]
    then
        if [ -z "${strProcess}" ]
        then
            strProcess="--cut=-${disReverse}"
        else
            strProcess=${strProcess}" --cut=-${disReverse}"
        fi
    fi
    if [ "${disLength}" -gt 0 ]
    then
        if [ -z "${strProcess}" ]
        then
            strProcess="--length=${disLength}"
        else
            strProcess=${strProcess}" --length=${disLength}"
        fi
    fi
}

# The getZipOutput function.
# This function loops through the files extracted from the input zip file.
# The unique name of every file is isolated and the input and output files for
# CutAdapt are defined. When CutAdapt is done processing, the processed file
# is added to a zip file.
getZipOutput() {
    for strFile in ${strDirectory}_temp/fileStorage/*.fastq;
    do
        strUniqueFileName=$(printf "%s\n" "${strFile##*/}")
        flInput=${strFile}
        flOutput=${strDirectory}_temp/${strUniqueFileName}
        runCutAdapt
        if [ -e flZip.zip ]
        then
            zip -jqru flZip.zip ${strDirectory}_temp/${strUniqueFileName}
        else
            zip -jqr ${strDirectory}_temp/flZip.zip \
                     ${strDirectory}_temp/${strUniqueFileName}
        fi
    done
}

# The getZipFile function.
# This function copies the input file to the temporary storage directory. The
# input file is searched for, based on its .dat extension. This search will
# output the name of the input file which is used to unzip it into the
# temporary storage directory. After unzipping, the getZipOutput function is
# called.
getZipFile() {
    mkdir -p "${strDirectory}_temp/fileStorage"
    cp ${fisInput} ${strDirectory}_temp
    strZipName=$(find ${strDirectory}_temp -name "*.dat" -printf "%f\n")
    unzip -q ${strDirectory}_temp/${strZipName} -d ${strDirectory}_temp/fileStorage
    getZipOutput
}

# The getFormatFlow function.
# This function creates a temporary storage directory in the output directory.
# It then initiates the correct function chain depending on the file format.
# When processing a single file, the input file is directed to the runCutAdapt
# function. When processing a zip file, the file is first unpacked in the
# getZipFile function. When all processes have been completed, the temporary
# working directory is deleted.
getFormatFlow() {
    strDirectory=${fosOutput::-4}
    mkdir -p "${strDirectory}_temp"
    if [ "${disFormat}" = "single" ]
    then
        flInput=${fisInput}
        flOutput=${fosOutput}
        prepareCutAdapt
        runCutAdapt
        rm -rf ${strDirectory}_temp
    elif [ "${disFormat}" = "zip" ]
    then
        prepareCutAdapt
        getZipFile
        cat ${strDirectory}_temp/flZip.zip > ${fosOutput}
        rm -rf ${strDirectory}_temp
    fi
}

# The main function.
main() {
    getFormatFlow
}

# The getopts function.
while getopts ":i:o:f:w:r:l:b:a:n:vh" opt; do
    case ${opt} in
        i)
            fisInput=${OPTARG}
            ;;
        o)
            fosOutput=${OPTARG}
            ;;
        f)
            disFormat=${OPTARG}
            ;;
        w)
            disForward=${OPTARG}
            ;;
        r)  
            disReverse=${OPTARG}
            ;;
        l)
            disLength=${OPTARG}
            ;;
        b)
            disBelow=${OPTARG}
            ;;
        a)  
            disAbove=${OPTARG}
            ;;
        n)
            disAmbiguous=${OPTARG}
            ;;
        v)
            echo ""
            echo "runCutAdapt.sh [0.1.0]"
            echo ""

            exit
            ;;
        h)
            echo ""
            echo "Usage: runCutAdapt.sh [-h] [-v] [-i INPUT] [-o OUTPUT]"
            echo "                      [-f FORMAT] [-w FORWARD] [-r REVERSE]"
            echo "                      [-l LENGTH] [-b BELOW] [-a ABOVE]"
            echo "                      [-n INTEGER N]"
            echo ""
            echo "Optional arguments:"
            echo " -h                    Show this help page and exit"
            echo " -v                    Show the software's version number"
            echo "                       and exit"
            echo " -i                    The location of the input file(s)"
            echo " -o                    The location of the output file(s)"
            echo " -f                    The format of the input" 
            echo "                       file(s) [single/zip]"
            echo " -w                    Trim reads at the 5'-end"
            echo " -r                    Trim reads at the 3'-end"
            echo " -l                    Trim reads from 3'-end to certain"
            echo "                       length"
            echo " -b                    Discard reads below certain length"
            echo " -a                    Discard reads above certain length"
            echo " -n                    Discard reads above certain number"
            echo "                       of N's [Minimum is 2]"
            echo ""
            echo "The CutAdapt tool will trim and discard reads and read"
            echo "sections based on user input and quality thresholds."
            echo ""
            echo "Files in fastQ format should always have a .fastq extension."
            echo ""
            echo "Current CutAdapt version:"
            cutadapt --version
            echo ""
            echo "Source(s):"
            echo " - Martin M, Cutadapt Removes Adapter Sequences From"
            echo "   High-throughput Sequencing Reads."
            echo "   EMBnet.journal. 2011. doi: 10.14806/ej.17.1.200"
            echo "   http://cutadapt.readthedocs.io/en/stable/guide.html"
            echo ""

            exit
            ;;
        \?)
            echo ""
            echo "You've entered an invalid option: -${OPTARG}."
            echo "Please use the -h option for correct formatting information."
            echo ""

            exit
            ;;
        :)
            echo ""
            echo "You've entered an invalid option: -${OPTARG}."
            echo "Please use the -h option for correct formatting information."
            echo ""

            exit
            ;;
    esac
done

main

# Additional information:
# =======================
#
# Files in fastQ format should always have a .fastq extension.
