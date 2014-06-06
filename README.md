docscripts
==========

Scripts for producing and managing documents

* catalog-files.sh -- Catalog files
* changelog.sh -- Write changelog
* gh-pages.sh -- Update GitHub Pages site files in branch 'gh-pages'
* issues-parser.py -- Parse JSON-format issue tracker data
* md-index.sh -- Create Markdown-formatted linked list of files in working directory
* pandoc-doc.sh -- Process Pandoc Markdown into document formats
* cite2cite.sed -- Rewrite citation formats
* spawn-project.sh -- Spawn a new project directory and files
* tag-release.sh -- For tagging releases
* update-readme.sh -- Update README with file list and changelog


Changelog
---------

### v0.5.0

Minor enhancements

* update-readme.sh: Extend functionality
* tag-release.sh: Add user message to temporary tag annotation file
* changelog.sh: Change git tag -list output format
* catalog-files.sh: Adjust regexp to be more flexible


### v0.4.0

* New scripts: catalog-files.sh, changelog.sh, update-readme.sh
* Update file headers for use with catalog-files.sh


### v0.3.0

New scripts

* spawn-project.sh -- spawn and set up a project
* tag-release.sh -- tag a release


### v0.2.1

Bugfixes for gh-pages.sh

* Manually copy .gitignore back and forth, to keep it updated
* Use .gitignore as a rsync exclude file
* jekyll_site_directory: Correct path in value


### v0.2.0

pandoc-doc.sh: Change the way Git commit data is incorporated


### v0.1.0

Version 0.1.0
