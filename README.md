docscripts
==========

Scripts for producing and managing documents

* addfm.sh -- Add YAML front matter to files
* catalog-files.sh -- Catalog files
* changelog.sh -- Write changelog
* gh-pages.sh -- Update GitHub Pages site files in branch 'gh-pages'
* md-index.sh -- Create Markdown-formatted linked list of files in working directory
* pandoc-doc.sh -- Process Pandoc Markdown into document formats
* spawn-project.sh -- Spawn a new project directory and files
* tag-release.sh -- For tagging releases
* update-readme.sh -- Update README with file list and changelog


Changelog
---------

### v0.7.0 2016-05-07

New script
    
* addfm.sh -- Add YAML front matter to files


### v0.6.0 2014-07-12

Enhancements and refactoring
    
* Add Pandoc submodule `pandoc-templates`
    
* Enhance and refactor `pandoc-doc.sh`:
    - Use submodule `pandoc-templates` for HTML generation
    - Reconfigure output options: re-designate or add options `html-bare`,
         `html-plain`, `html-fancy`, `pdf-article-plainer`, `pdf-article-plain`,
         `pdf-article-fancy`
    - Additions and adjustments of Pandoc file variables
    - Other minor changes and fixes
    
* Partially refactor `catalog-files.sh`, `changelog.sh`
    - Rewrite `display_usage` using here document
    - Remove functions that were using global variables
    - Rewrite conditional expressions using `test`
    - Correct exit codes
    - changelog.sh: Add `tag_date` for including `YYYY-MM-DD` tag dates
    - Other minor changes and fixes
    
* Update spawn-project.sh
    - Add `.gitattributes` file generator


### v0.5.1 2014-06-06

Bugfixes for catalog-files.sh


### v0.5.0 2014-06-06

Minor enhancements
    
* catalog-files.sh: Adjust regexps to be more flexible
* changelog.sh: Change git tag -list output format
* tag-release.sh: Add user message
* update-readme.sh: Extend functionality


### v0.4.0 2014-06-06

New scripts
    
* catalog-files.sh -- Catalog files
* changelog.sh -- Write changelog
* update-readme.sh -- Update README with file list and changelog


### v0.3.0 2014-06-06

New scripts
    
* spawn-project.sh -- spawn and set up a project
* tag-release.sh -- tag a release


### v0.2.1 2014-06-06

Bugfixes for gh-pages.sh


### v0.2.0 2014-06-04

pandoc-doc.sh: Change the way Git commit data is incorporated


### v0.1.0 2014-06-04

Version 0.1.0
