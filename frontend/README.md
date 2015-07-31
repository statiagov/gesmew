# Gesmew Bootstrap Frontend

### Bootstrap 3 powered frontend.

This has several large advantages:

- Fully responsive - Mobile, tablet and desktop. With custom grids for each, collapsing elements, and full HDPI support. Current gesmew only goes half way.
- Just 44 lines of custom SCSS, replacing 1328 lines of undocumented gesmew CSS. Plus most of these lines only add some visual style to the header and footer and can be removed.
- The entire frontend can be easily customized: colours, grid, spacing, etc, by just overriding [variables from bootstrap](https://github.com/twbs/bootstrap-sass/blob/master/assets/stylesheets/bootstrap/_variables.scss) - giving a custom store design in minutes.
- Bootstrap has some of the most [robust documentation](http://getbootstrap.com/css) of any framework, and a hugely active community. As this port uses only default bootstrap it means that entire gesmew frontend layout is documented by default.
- Sites like [bootswatch](http://bootswatch.com) allow for one-file bootstrap drop-in gesmew themes.
- Lots of [gesmew community will for bootstrap](https://groups.google.com/forum/#!searchin/gesmew-user/bootstrap/gesmew-user/B17492QdnGA/AF9vEzRzf4cJ).
- Though this uses ‘full bootstrap’ for simplicity, you can remove the unused Bootstrap components you don’t require for minimal file sizes / weight.
- Bootstrap is one of the largest most active open source projects out there - maintaining an entire framework just for gesmew makes little sense. Forget about cross browser bugs. Woo!

Overview
-------

This stays as closely to the original gesmew frontend markup as possible. Helper decorators have been kept to a bare minimum. It utilises the [SCSS port](https://github.com/twbs/bootstrap-sass) of bootstrap 3 to keep inline with existing gesmew practices. It also includes support for `gesmew_auth_devise`.

[![home page](http://i.imgur.com/QlwZwS8.png)](http://i.imgur.com/2Ycr8w8.png)
[![home page](http://i.imgur.com/6eoQmfi.png)](http://i.imgur.com/XLi5DAs.png)
[![home page](http://i.imgur.com/D154fb4.png)](http://i.imgur.com/UdKueAQ.png)
[![home page](http://i.imgur.com/HutvtWF.png)](http://i.imgur.com/mis2XHY.png)
[![home page](http://i.imgur.com/pKUbyMu.png)](http://i.imgur.com/hF0IjWI.png)
[![home page](http://i.imgur.com/bkYVBfh.png)](http://i.imgur.com/U06g9Jn.png)
[![home page](http://i.imgur.com/uHwYVPA.png)](http://i.imgur.com/Ozh5vQr.png)

Customizing
-------

Override the stylesheet to `vendor/assets/stylesheets/gesmew/frontend/frontend_bootstrap.css.scss`. Use this as your base stylesheet and edit as required.

To style your gesmew store just override the bootstrap 3 variables. The full list of bootstrap variables can be found [here](https://github.com/twbs/bootstrap-sass/blob/master/assets/stylesheets/bootstrap/_variables.scss). You can override these by simply redefining the variable before the `@import` directive.
For example:

```scss
$navbar-default-bg: #312312;
$light-orange: #ff8c00;
$navbar-default-color: $light-orange;

@import "bootstrap";
```

This uses the [bootstrap-sass](https://github.com/twbs/bootstrap-sass) gem. So check there for full cutomization instructions.

It’s quite powerful, here are some examples created in ~10 minutes with a few extra SCSS variables, no actual css edits required:

[![layout](http://i.imgur.com/kppJiFS.png)](http://i.imgur.com/m3zKV0s.png)
[![layout](http://i.imgur.com/x92TXYh.png)](http://i.imgur.com/eNyNFSg.png)
