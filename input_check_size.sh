## first mount the powerscale drive and navigate to the directory containing the fastq.gz files
mount_smbfs //pmonsieurs@itgps-srv.itg.be/DBW/tryp/Novogene ~/mnt/novogene
cd /Users/pmonsieurs/mnt/novogene/01.RawData


echo -e "Library\tReads(M)\tData(Gb)"
for dir in PTA*/ Undetermined/; do
    # Tel het aantal regels in alle fastq.gz bestanden en deel door 4
    reads=$(zcat -f ${dir}*.fq.gz | wc -l | awk '{print $1/4}')
    
    # Bereken miljoenen reads en Gigabases (reads * 2 * 150bp / 10^9)
    reads_m=$(echo "scale=2; $reads/1000000" | bc)
    gb=$(echo "scale=2; $reads*300/1000000000" | bc)
    
    echo -e "${dir%/}\t${reads_m}M\t${gb}Gb"
done