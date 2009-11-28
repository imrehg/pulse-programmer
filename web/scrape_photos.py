import urllib2

from BeautifulSoup import BeautifulSoup

page = urllib2.urlopen("http://www.flickr.com/photos/paulpham/sets/72157611700802541/")
soup = BeautifulSoup(page)
imageLinks = soup.findAll('span', attrs={"class":"photo_container pc_s"});
file = open('/users/home/local-box/pp/photos.txt', 'w')

for image in imageLinks:
	anchor = image.find('a')
	href = anchor['href']
	img = anchor.find('img')
	src = img['src']
  	file.write(src+'\n')
