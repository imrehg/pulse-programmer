all: windows-installer rpm-installer

windows-installer:
	python setup.py bdist_wininst

rpm_installer:
	python setup.py bdist_rpm

source-installer:
	python setup.py sdist --format=bztar