#!/bin/sh

#set -x
base_url='http://sourceforge.net/export/'
group_id='group_id=129764'
news_rss_url="$base_url/rss2_projnews.php?$group_id&rss_fulltext=1&rss_limit=5"
files_rss="$base_url/rss2_projfiles.php?$group_id"
files_rss_url="$files_rss&rss_limit=5"
group_dir='/home/groups/p/pu/pulse-sequencer/htdocs'

#news_url_string="http://sourceforge.net/export/projnews.php?group_id=129764&limit= 5&flat=0&show_summaries=1"

if [ $# -lt 1 ]
then
  dest_dir=$group_dir
else
  dest_dir=$1
fi

WGET="$(/usr/bin/which curl)"
WGET="$WGET"' -s -S'

$WGET -o $dest_dir/project_news.xml $news_rss_url > /dev/null
$WGET -o $dest_dir/project_files.xml $files_rss_url > /dev/null
$WGET -o $dest_dir/all_files.xml $files_rss > /dev/null
#set -x
