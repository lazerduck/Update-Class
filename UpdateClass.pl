use 5.010;
use strict;
use warnings;

sub ReadFile {
    my $filename = $_[0];
    my $file = "";
    open(my $fh, '<:encoding(UTF-8)', $filename)
    or die "Could not open $filename";

    while(my $row = <$fh>) {
        chomp $row;
        $file = "$file $row\n";
    }

    return $file;
}

sub CutContent {
    my $class = $_[1];
    my $classNam = $_[0];
    my $start = -1;
    my $end = -1;
    my $matchPos = 0;
    my $currPos = 0;
    my $output = "";
    my $level = 0;
    my $began = 0;
    my $startChar = "{";
    my $endChar = "}";

    foreach my $char (split //, $class) {
        $currPos ++;
        if($start == -1)
        {
            if($char eq substr($classNam, $matchPos, 1))
            {
                $matchPos ++;
                if($matchPos >= length($classNam)){
                    $start = $currPos;
                }
            }
        }
        else
        {
            $output = "$output$char";

            if($char eq $startChar)
            {
                $began = 1;
                $level ++;
            }
            if($char eq $endChar)
            {
                $level --;
                if($level == 0 and $began){
                    return $output;
                }
            }

        }
    }
}

sub writeFile {
    open(my $fh, '>', $_[0]);
    print $fh $_[1];
    close $fh;
}

sub Sanatise{
    my $string = $_[0];
    $string =~ s/\{/\\\{/g;

    return $string;
}

my $main = 'test.cs';
my $toUpdate = 'fileToUpdate.cs';
my $file = ReadFile($main);
my $fileUpdate = ReadFile($toUpdate);
my $mainClassContent = CutContent("test", $file);
my $toReplace = CutContent("viewModel", $fileUpdate);

$toReplace = Sanatise($toReplace);

$fileUpdate =~ s/$toReplace/$mainClassContent/g;

writeFile($toUpdate, $fileUpdate);