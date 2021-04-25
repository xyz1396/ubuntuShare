var page = require('webpage').create();
      page.settings.userAgent = 'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/37.0.2062.120 Safari/537.36';
      phantom.addCookie({
        'name'     : 'jgi_session',
        'value'    : '%2Fapi%2Fsessions%2F4fa4a35030f61b06e9e9c311d004073c',
        'domain'   : '.jgi.doe.gov',
        'path'     : '/',
        });
      page.open('https://genome.jgi.doe.gov/portal/', function (){
          console.log(page.content);
          phantom.exit();
        });
