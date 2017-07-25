function ensure($dir) { if(!(test-path $dir)) { mkdir $dir > $null }; resolve-path $dir }
