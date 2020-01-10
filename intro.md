# Intro to HTTP and URIs

## Learning Goals


* Use the command-line utilities `curl` and `nc` to experiment with
and learn about HTTP and cookies

* Understand the basics of how HTTP requests and responses are
constructed, and the interaction between a SaaS client and server
using HTTP

* Understand some of the most common HTTP error codes and what they mean

* Understand how cookies are managed between clients and servers

## Setup

In the beginning was the command line, and that's where we'll be for
this intro to HTTP.  We will use two command-line
tools. [cURL](https://en.wikipedia.org/wiki/CURL) (pronounced "curl")
to act as a SaaS client, and
[netcat](https://en.wikipedia.org/wiki/CURL) (pronounced "netcat") to
act as a SaaS server.

We will also be working with two real web sites:
[Watchout4snakes](http://watchout4snakes.com), a handy random-word
generator that will also be featured in a future assignment; and
a simple [cookie demo site](https://github.com/saasbook/simple-cookie-demo)
written just for this assignment and deployed on Heroku.

Start by visiting Watchout4snakes in your favorite browser 
to get a "user's view" of what's on the front page.

## Learning goal: understand basic parts of an HTTP request and response

The most basic use of `curl` is to issue an HTTP GET or POST to a
site, so try `curl 'http://watchout4snakes.com'` and verify that what
you see printed could plausibly correspond to the page content you
viewed in your browser previously.  (The single quotes are not
technically necessary in this case, but you should get used to using
them with `curl`, because URIs will often have special characters in
them, such as `?` or `#`, that would be interpreted in special ways by
the Unix shell if they're not protected by single quotes.)

1.  Save the contents of the above `curl` command to a file and view
the file as a browser would render it.  Hint 1: adding
`>filename` to a shell command redirects the command's output to be
stored in that file.  Hint 2-1: if you work locally, you can store the content
into a file with an extension .html and open the created file with your brower.
Hint 2-2: if you save files in your Cloud9
workspace, they'll appear in the "file explorer" down the left-hand
side; you can then open the file in the editor, and click "Preview" in
the top nav bar to open that specific file in a preview web browser
built into Cloud9.  When the preview browser appears, you can also
click its "pop out" tab to make the preview browser open in its own
window.


<details>
  <summary>
  What are two main differences between the preview you see and what you
 saw in a "normal" Web browser?  What explains these differences?
  </summary>
  <p><blockquote>
  There is no picture and no visual styling of the page elements,
  because both the picture and the stylesheet (.css file) have to be
  loaded separately.  The HTTP request you made only loaded the main
  HTML file.  In a regular browser, the browser would automatically
  follow the links to download and display the image, and to download
  the stylesheet file and apply the styling information.
  </blockquote></p>
</details>

Now let's see what the server thinks a request looks like.  To do
this, in another Terminal tab or window, we will pretend to be a Web
server listening on port 8081.  (Normally any port number 1024 or
greater would be legal, but if you're using Cloud9, the only
"externally accessible" port numbers are 8080-8082.)

Tell Netcat to listen on port 8081: `nc -l 8081`

<details>
  <summary>
  Assuming you're running curl from another shell
  on the same C9 workspace, what URL will you have to pass to Curl to try to access your fake
  server, and why?  
  </summary>
  <p><blockquote>
  http://localhost:8081 is the URL.  Localhost always means "this same
  machine" and 8081 is the port number.  Without the port number, the
  default would be 80, which is the IANA default port for Web servers
  (or 443 for HTTPS-secured servers).
  </blockquote></p>
</details>

Visit your "fake" server with curl and the correct URL.  Your "fake"
server will receive the HTTP client request.


<details>
  <summary>
  The first line of the request identifies which URL the client wants
  to retrieve.  Why don't you see `http://localhost:8081` anywhere on that line?
  </summary>
  <p><blockquote>
  That part of the URL tells the browser (or other client) which
  protocol to use (HTTP) and which server and port to contact
  (port 8081 on localhost).
  Once the server is contacted, the client just needs to tell it the
  remainder of the URL (the path portion) that it wants to retrieve.
  </blockquote></p>
</details>

Make a note
of which headers you see: this is how a real Web server perceives a
connection from curl.  

Now that you've seen what an HTTP request looks like from the server's
point of view, let's see what the response looks like from the
client's point of view.  In particular, `curl` just prints out the
content sent back from the server, but we'd like to see the server
headers.  Try `curl --help` to see the help and verify that the
command line `curl -i 'http://watchout4snakes.com'` will
display BOTH  the server's response headers AND then the response body.

<details>
  <summary>
  Based on the server headers, what is the server's HTTP response code
  giving the status of the client's request, and what version of the
  HTTP protocol did the server use to respond to the client?
  </summary>
  <p><blockquote>
  The first line tells us that HTTP 1.1 was used, and that the request
  succeeded with code 200.
  </blockquote></p>
</details>


<details>
  <summary>
  Any given Web request might return an HTML page, an image, or a
  number of other types of entities.  Is there anything in the headers
  that you think tells the client how to interpret the result?
  </summary>
  <p><blockquote>
  The `Content-Type:` header in this case tells the client that the
  content returned is an HTML page. 
  </blockquote></p>
</details>


## Learning goal: understand what happens when an HTTP request fails.

<details>
  <summary>
  What would the server response code be if you tried to fetch a
  nonexistent URL on Watchout4snakes?  Try it using the procedure above.
  </summary>
  <p><blockquote>
  The HTTP status code is 404.  The words "Not found" after the status
  code are there for human readability; only the 3-digit status code
  is officially required.
  </blockquote></p>
</details>

What other HTTP error codes exist?  Use Wikipedia or another resource
to learn the meanings of some of the most common:  200, 301, 302, 400,
404, 500.  Note that these are "families" of statuses: all 2xx
statuses mean "it worked", all 3xx are "redirect", and so on.  


<details>
  <summary>
  Both 4xx and 5xx headers indicate error conditions.  What is the
  main difference between 4xx and 5xx?
  </summary>
  <p><blockquote>
  4xx errors are the server actually responding "Sorry, no dice."  5xx
  errors occur when something went so severely sideways--for example,
  the app server crashed, or the SaaS app running on the server raised
  an unhandled exception--that the HTTP server layer, which just
  handles traffic to and from the app, had to take over and say
  "Sorry, the app is too hosed to inform you that it's hosed."
  </blockquote></p>
</details>


## Learning goal: understand concept of request body

Next we will create a simple HTML form that you can post from your
browser and intercept it with Netcat as above, so you can see what a
form posting looks like to a Web server.  This is relevant because in
your own SaaS apps you will have to work with submitted form data;
while most frameworks like Sinatra and Rails do a nice job for you of
parsing and pre-digesting such form data in order to make it
conveniently available to your app, it is worth understanding what
that data normally looks like before such processing.

Once again, start `nc -l 8081` to listen on port 8081 in Cloud9.

Create and save (ideally with extension `.html`) the following minimal
file on your own computer:

```html
<!DOCTYPE html>
<head>
</head>
<body>
  <form method="post" action="FAKE-SERVER-URL-HERE">
    <label>Email:</label>
    <input type="text" name="email">
    <label>Password:</label>
    <input type="password" name="password">
    <input type="hidden" name="secret_info" value="secret_value">
    <input type="submit" name="login" value="Log In!">
  </form>
</body>
```

<details>
  <summary>
An HTML form when submitted generates an HTTP `POST` request from the
browser.  In order to reach your fake server on Cloud9, with what URL
should you replace FAKE-SERVER-URL-HERE in the above file?
  </summary>
  <p><blockquote>
  As before, `http://your-workspace-name.c9users.io:8081` will do.
  </blockquote></p>
</details>

Modify the file, open it in your computer's Web browser, fill in some
values in the form, and submit it.  Now go to Cloud9 and look at the
window where `nc` is listening.  


<details>
  <summary>
How is the information you entered
into the form presented to the server?  What tasks would a SaaS
framework like Sinatra or Rails need to do to present this information
in a convenient format to a SaaS app written in, say, Ruby? 
  </summary>
  <p><blockquote>
  The form contents are presented as a long string of the form
  `key1=value1&key2=value2&...keyN=valueN` where each key is the name
  of a form field and the values are
  [URL-escaped](https://en.wikipedia.org/wiki/Percent-encoding).  The
  server framework must pick apart the keys and values, un-escape the
  values, and present the collection in some nice way, like a hash.
  </blockquote></p>
</details>

Repeat the experiment various times to answer the following questions
by observing the differences in the output printed by `nc`:

* What is the effect of adding additional URI parameters as part of
the `POST` route?

* What is the effect of changing the `name` properties of the form
fields?

* Can you have more than one Submit button?  If you do, how does the
server tell which one was clicked?  (Hint: experiment with the
attribtues of the `<submit>` tag.)

* Can the form be submitted using `GET` instead of `POST`?  If yes,
what is the difference in how the server sees those requests?

* What other HTTP verbs are possible in the form submit
route?  Can you get the web browser to generate a route that uses PUT, PATCH,
or DELETE?

## Learning goal: understand the effect of HTTP being stateless, and the role of cookies

In this section we will use a simple app developed for this course to
help you experiment with cookies.  The curious can see the 
[app's source code](https://github.com/saasbook/simple-cookie-demo)
(it uses the simple Sinatra framework).

This app only supports two routes: 

* `GET /login` returns a response that instructs the browser to set a
cookie.  The cookie contents are set by the app to  indicate the user
has logged in.  (In a real app, the server would run some code that
verifies a username/password pair or similar.)

* `GET /` returns a text string saying whether the user is logged in or
not.

This app lives at `http://esaas-cookie-demo.herokuapp.com` but it
only serves up text strings, not HTML pages.  Boring, but great for
use with `curl`.


<details>
  <summary>
  Try the first two <code>GET</code> operations above.  The body of the response
  for the first one should be "Logged in: false", and for the second
  one "Login cookie set."  What are the differences in the response
  _headers_ that indicate the second operation is setting a cookie?
  (Hint: use <code>curl -v</code>, which will display both the request headers
  and the response headers and body, along with other debugging information.)
  </summary>
  <p><blockquote>
  The second operation should include in the headers <code>Set-Cookie:</code>
  followed by a string that is the value of the cookie to be set.  A
  browser would automatically grab this value and store it as one of
  the cookies to be sent whenever this site is re-revisisted.  (But
  heads up/spoiler alert:
  we're not using  a browser but just a simple command-line utility
  that issues independent HTTP requests...)
  </blockquote></p>
</details>



<details>
  <summary>
OK, so now you are supposedly "logged in" because the server set a
cookie indicating this.  Yet if you now try <code>GET /</code> again, it will
still say "Logged in: false".  What's going on?  (Hint: use <code>curl -v</code>
and look at the client request headers.)
  </summary>
  <p><blockquote>
   The server tried to set a cookie, but it's the client's job to
   remember the cookie and pass it back to the server as part of the
   headers whenever that same site is visited.   Browsers do this
   automaticaly (unless you have disabled cookies in the preferences),
   but <code>curl</code> won't do this
   without explicit instructions.  The server isn't seeing the cookie
   as part of subsequent requests, so it can't identify you.
  </blockquote></p>
</details>



To fix this, we have to tell `curl` to store any relevant cookies the
server sends, so it knows to include them with future requests to that
server.

Try `curl -i --cookie-jar cookies.txt
http://esaas-cookie-demo.herokuapp.com/login` and verify that the
newly created file `cookies.txt` contains information about the cookie
that matches the `Set-Cookie` header from the server.  This file is
how `curl` stores cookie information; browsers may do it differently.

Now we must tell `curl` to include any appropriate cookies from this
file when visiting the site, which we do with the `-b` option: 

`curl -v -b cookies.txt http://esaas-cookie-demo.herokuapp.com/`

Verify that the cookie is now transmitted (hint: look at the client
request headers) and the server now thinks you are logged in.

<details>
  <summary>
  Looking at the <code>Set-Cookie</code> header or the contents of the
  <code>cookies.txt</code> file, it seems like you could have easily created this
  cookie and just forced the server to believe you are logged in.  In
  practice, how do servers avoid this insecurity?
  </summary>
  <p><blockquote>
  In practice cookies are usually both encrypted (so the user cannot
  read the cookie contents, as you could here) and tamper-evident
  (part of the cookie is a substring that acts as a "fingerprint" for
  the rest of the string, so that even if you try to modify the cookie
  contents, you'd have to know how to also modify the fingerprint,
  similar to the "CVV code" used by credit cards).  The keys required
  for both operations are known only to the server.
  </blockquote></p>
</details>



To summarize: the only way the server can "keep track" of the same
client is by setting a cookie when the client first visits, 
relying on the client to include that cookie in the headers on
subsequent visits, and if the server modifies the cookie during the
session (by including additional <code>Set-Cookie</code> headers), relying on the
client to remember those changes as well.  In this way, even though
HTTP itself is stateless (every request independent of every other),
the app can internally maintain the notion of "session state" for each
client, using the cookie as a "handle" to name that state internally.
(In practice, most SaaS apps use the cookie to hold on to a lookup key
that maps the cookie value to a larger and more complex data structure
stored at the server.)

Disabling cookies in the client thwarts all of these behaviors, which
is why most sites that require login (which is a stateful concept:
you're logged in, or you're not), or which step you through a sequence
of pages to do an operation (another stateful concept: which page of
the flow are you currently on?  Which page should be shown next?)
don't work properly if cookies are disabled in the browser.


