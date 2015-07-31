---
title: "Seo Considerations"
section: advanced
---

## Overview

Search Engine Optimization is an important area to address when
implementing and developing an ecommerce solution to ensure competitive
search engine performance. The following guide outlines current Gesmew
Search Engine Optimization features and future optimization development
possibilities.


## Existing Search Engine Optimization Features

Chapter 1 contains a description of the work that has been completed to
address common search engine optimization issues.

### Relevant, Meaningful URLs

The helper method `seo_url(taxon)` yields SEO friendly URLs such as [demo.gesmewcommerce.com/products/xm-direct2-interface-adapter](http://demo.gesmewcommerce.com/products/xm-direct2-interface-adapter) and [demo.gesmewcommerce.com/t/categories/headphones](http://demo.gesmewcommerce.com/t/categories/headphones).
Each controller is configured to serve the content using these keyword-relevant, meaningful URLs.

### On Page Keyword Targeting

Several enhancements have been made to improve on-page keyword targeting. The admin interface provides the ability to manage meta descriptions and meta keywords at the product level. Additionally, H1 tags are used throughout the site for product and taxonomy names. The ease of extension development and layout changes allows you to target keywords throughout the site.

Starting with Gesmew 2.0, Taxons also have `meta_keywords` and `meta_description` on them. (You can configure these in the Admin > Configuration > Taxonomies). If you want to add keywords and description to another kind of object in Gesmew, you can do so simply by adding those two fields (`meta_keywords` and `meta_description`) onto the object in question. The Gesmew controller must instantiate an instance variable of the same class name as the controller (so, for example, `@taxon` for the TaxonsController) for this to work. Check out the `meta_data` method on gesmew_core/app/helpers/gesmew/base_helper.rb for details on how that works. 


### Clean Content

Gesmew 2.4 and earlier uses Skeleton and Gesmew 3.0 uses Bootstrap. Both are a responsive CSS framework that allows clean HTML that also responds well to any screen size. Having clean HTML with minimal inline JavaScript and CSS is considered to be a factor in search engine optimization.

### On Site Performance Optimization

Gesmew has been configured to serve one CSS and one JavaScript file on
every page (excluding extension inclusions). Minimizing HTTP requests is
considered an important factor in search engine optimization as the
server performance is an important influence in the search engine crawl
behavior for a site.

### Google Analytics integration

Google Analytics has been integrated into the Gesmew core and can be
managed from the "Analytics Trackers" section of the admin. Google
Analytics is not included on your store if this preference is not set.
The Google Analytics setup includes e-commerce conversion tracking.

## Gotchas, Known Issues, and Further Considerations

### Known Duplicate Content Issues

In the Gesmew demo, it is a known issue that
[demo.gesmewcommerce.com](http://demo.gesmewcommerce.com/) contains
duplicate content to
[demo.gesmewcommerce.com/products](http://demo.gesmewcommerce.com/products).
Duplicate content can be a detriment to search engine performance as
external links are divided among duplicate content pages. As a result,
duplicate content pages may not only not be excluded from the main
search engine index, but pages may also rank poorly in comparison to
other sites where all external links go to one non-duplicated page.

If you change your home page this won't be an issue for you. Alternatively, you can have your [demo.gesmewcommerce.com/products](http://demo.gesmewcommerce.com/products) page redirect to your home page to eliminate this problem.

### Integration of Content Management System or Content

There has been quite a bit of interest in development of [CMS
integration into
Gesmew](https://groups.google.com/forum/#!searchin/gesmew-user/cms). Having
good content is an important part of search engine optimization, as it
not only can improve on page keyword targeting, but it also can improve
the popularity of a site which can in turn improve search engine
optimization.

### Tool Integration

In addition to integration of Google Analytics, several other tools can
be implemented for SEO purposes such as Bing Webmaster Tools, Google
Webmaster Tools and Quantcast. Social media optimization tools such as
Pinterest, Reddit, Digg, Delicious, Facebook, Google+ and Twitter may
also be integrated to improve social networking site performance.

Many of these can be implemented with minimal changes to your Gesmew store. 

### Gesmew SEO Extensions

The following list shows extensions that can improve search engine
performance. Refer to the GitHub README for developer notes.

-   [Gesmew Sitemap Generator](https://github.com/gesmew-contrib/gesmew_sitemap)
-   [Static Content Management](https://github.com/gesmew-contrib/gesmew_static_content)
-   [Product Reviews](https://github.com/gesmew-contrib/gesmew_reviews)

(for stores older than Gesmew 1.0, check out [Gesmew Sitemap Generation](https://github.com/romul/gesmew_dynamic_sitemaps))


## Planned Search Engine Optimization Features (TODO)

Although several common search engine optimization issues have been
addressed, we are always looking for the new best practices in SEO.
Contributions to address issues will be very welcome. Visit the
[contributing to gesmew section](contributing.html) to learn
more about contributing.

Here are some of the specific planned ideas we have for the future of Gesmew:

- Make the `alt` field from gesmew_assets output as the alt attribute in the image tag

## In Conclusion

Gesmew cannot control factors such as external links, quality of external
links, server performance and capabilities. These areas should not be
ignored in implementation of search engine optimization efforts.
