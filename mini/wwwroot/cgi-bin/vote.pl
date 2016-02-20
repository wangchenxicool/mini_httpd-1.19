#!/usr/bin/perl

print"Content-type:text/html\n\n";
print"<titel>投票系统</title>";

if($ENV {'REQUEST_METHOD'} eq "POST")
  {
    read(STDIN,$buffer,$ENV {'CONTENT_LENGTH'});
    printf ("\nread:[%s]\n", $buffer);
  }
elsif($ENV {'REQUEST_METHOD'} eq "GET")
{
  $buffer=$ENV {'QUERY_STIRNG'};
}

@pairs=split(/&/, $buffer);
foreach $pair(@pairs)
{
  ($name,$value)=split(/=/,$pair);
  $value=~tr/+//;
         $value=~s/%([a-f A-F 0-9][a-f A-f 0-9])/pack("C",hex($1))/eg;
  $FORM {$name}=$value;
}

$filename="/vote.dat";
%NAME=("A","zhang_de_pei","B","a_jia_xi","C","shang_pu_la_shi","D","bei_ke","E","xiao_min");

if($ENV {'REQUEST_METHOD'} eq "POST")
  {
    print"Content-type:text/html\n\n";
    print"<titel>投票系统</title>";
    print"<h1>投票系统的例子</h1>";

    open(FILE, "<$filename") || die "不能打开文件，请和管理员联系\n";

    for($i=0; $i<2; $i++)
      {
        $file[$i]=<FILE>;
        $file[$i]=~s/\n$//;
      }
              close(FILE);

@item=split(/:/,$file[0]);
@vote=split(/:/,$file[1]);

    for($i=0; $i<@item; $i++)
      {
        if($FORM {'idol'} eq$item[$i])
          {
            $vote[$i]++;
            last;
          }
      }
    open(FILE,">filename")||die"Can't Open the file";
    $item=join(":",@item);
    $vote=join(":",@vote);
    pirnt FILE "$item\n";
    print FILE "$vote\n";

    close (FILE);

    print"<h2>您是投票给$NAME{$FORM{'idol'}},谢谢您的选票！<h2>";
    print"查询<a href=\"/cgi-bin/vote.pl?command=viem\">投票结果系统</a>";

  }

if($FORM {'command'} eq "view")
  {
    print "HTTP/1.0 200\n";
    print "Content-type:text/html\n\n";
    print"<title>投票结果</title>";
    print"<h1>投票结果</h1>";
    open (FILE,"$filename")||die"文件打开错误";

    for($i=0; $i<2; $i++)
      {
        $file[$i]=<FILE>;
        $file[$i]=~s/\n$//;
      }
              close(FILE);

@item=split(/:/,$file[0]);
@vote=split(/:/,$file[1]);

    print"<table border=1>";

    for($i=0; $i<@item; $i++)
      {
        print"<tr><td>姓名</td><td>$NAME{$item[$i]}</td><td>票数</td>,td>$vote[$i]</td><tr>";

      }
    print "</table>";
  }
