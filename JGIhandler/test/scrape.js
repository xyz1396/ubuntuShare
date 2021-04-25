var page = require('webpage').create();
      page.settings.userAgent = 'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/37.0.2062.120 Safari/537.36';
      phantom.addCookie({
        'name'     : 'jgi_session',
        'value'    : '%2Fapi%2Fsessions%2Fa02a4fa6cf81b14cb577b93971f64b03',
        'domain'   : '.jgi.doe.gov',
        'path'     : '/',
        });
      page.open('https://genome.jgi.doe.gov/portal/?core=genome&query=3300020517', function (){
          console.log(page.content);
          phantom.exit();
        });
