==title==
 A Website and a Blog for $5/mo - Part 2
==author==
 Andrew Barr
==description==
 I will create two simple Phoenix applications and deploy them to Digital Ocean. 
==tags==
 elixir
==body==


This is the second part of a series focussing on setting up more than one Phoenix Application on a single Digital Ocean Droplet (<span class="text-indigo-600">[Part 1 can be found here](https://andrewbarr.io/posts/website-and-blog-5-dolllars-a-month-p1)</span>).

## Simple Phoenix Application 

As I mentioned in <span class="text-indigo-600">[Part 1](https://andrewbarr.io/posts/website-and-blog-5-dolllars-a-month-p1)</span>, I was keen to not use a database for my website and blog, not only to keep the cost lower, but also I am not planning on doing anything that needs a database yet (In a future post I will detail how I made a `LiveView` contact form without a database).

To test my server I started with a `Phoenix Application`:

```
$ mix phx.new blog --live --no-ecto
```

Following the instructions and ensure that it runs with the default settings (Creating a new <span class="text-indigo-600">[Phoenix App](https://www.phoenixframework.org/)</span> is well documented so I won't spend anytime on it here). However, using the --live and --no-ecto switches will ensure most of the biolerplate we need is setup for us.

## Git 

Make sure you follow best practice and keep your project in a code repo. If you have not done so already, head over to <span class="text-indigo-600">[github](https://www.`github`.com)</span> and create and account. With an account create a new repo called `blog` or whatever you called your `Phoenix Application` above. Once you have a `github` repo create your local git repo and add the `github` remote.

```
$ git init
$ git remote add origin git@github.com:your_user_name/your_project_name.git
$ git add .
$ git commit -m "initial commit"
$ git push --set-upstream origin master
```

## Simplify Your Phoenix App

Go to the `page_live.html.leex` and modify the page to identify it as your Blog or whatever you have called your project. Delete all of the `html` and replace it with something unique. Open the `page_live.html.leex` in your editor of choice.

```
$ vim /lib/blog_web/live/page_live.html.leex
```

Replace all of the markup with something like

```
<div>
	<h1>MY BLOG</h1>
<div>
```

You can then open `page_live.ex` and remove all of the functions except `mount`, change  `mount` to 

```
@impl true
def mount(_params, _session, socket) do
{:ok, socket}
end

```

You can now delete all of the `handle_event` functions. Run `mix phx.server` and ensure that your site is running on `localhost:4000` and shows your modified page. We cam now deploy the application to our Digital Ocean Droplet. Don't forget to commit your changes to ``github``.

```
$ git add .
$ git commit -m "Modified home page"
$ git push
```

## Deployment

Our first deployment will be manual (In a future post I will show you how I automated it). Start by connecting to your Droplet using `ssh`. 

```
$ ssh your-user-name@your-Droplet-ip
```

Then we need to install `git`.

```
$ sudo apt-get install git
```

After installing git we need to add an `ssh-key` to `github` so we can pull the repo to our server. Just like before run `ssh-keygen` (ensuring the new key is created in the `.ssh/` directory). I used all of the default settings, and then used the `more` cmd to copy the public key (Make sure it is the `.pub` file). 

Once you have the public key go to your `github` account and navigate to the deploy keys sections Settings -> Deploy Keys. Create a new deploy key (naming it something meaningful) and paste in the public key from the server.

Now that you have the deploy key setup, grab the clone url from the `Clone or Download` menu. Go back to your `ssh` session with the Droplet and clone your repo on the server.

```
$ git clone git@github.com:your-account/your-project.git
```

Once the project has been cloned run through the local setup.

```
$ cd project_name
$ mix deps.get
$ cd assets
$ npm install
```

NOTE: I had some issues with webpack when I started to create a release and found a tip from Michael at Omgneering that webpack needed to be installed globally.

```
$ sudo npm install -g webpack
$ sudo npm install -g webpack-cli

```

Because we are going to be creating a `PROD` release we need to change our configuration. Go back to your ``github`` account and navigate to `Settings -> Secrets`. Create a new secret called `KEY_BASE` and past in a key generated at in your terminal using `mix phx.gen.secret 64`. 

Then create a new secret called `SIGNING_SALT` and paste in the key generated using `mix phx.gen.secret 32`. Go back to your local editor and open `/config/prod.exs` and make the following changes.

```
use Mix.Config

config :your_app, YourAppWeb.Endpoint,
  server: true,
  http: [
    port: String.to_integer(System.get_env("PORT") || "4000"),
    transport_options: [socket_opts: [:inet6]]
  ],
  url: [host: "your-domain.com", port: 80],
  check_origin: [
    "https://your-domain.com",
    "https://www.your-domain.com"
  ],
  secret_key_base: System.get_env("KEY_BASE"),
  live_view: [signing_salt: System.get_env("SIGNING_SALT")]

# Do not print debug messages in production
config :logger, level: :info
```

Commit your changes from your local machine to `github`.

```
$ git add .
$ git commit -m "Modified PROD config"
$ git push
```

Now go back to your `ssh` session on the Droplet and run `git pull` from the project directory. Your project will now be up to date on the server. Before we build our release we are going to setup `Nginx`. Open the settings file for your project <span class="text-indigo-600">([See Part 1](https://andrewbarr.io/posts/website-and-blog-5-dolllars-a-month-p1))</span> using `$ sudo vim /etc/nginx/sites-available/your-website-name`, add the following section directly above the sever config:

```
upstream your-website-name{
	server 127.0.0.1:4000;
}

server {
	...
}
```

Then go down to the `location` section and change it to

```
location / {
	allow all;

	proxy_http_version 1.1;
	proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
	proxy_set_header X-Cluster-Client-Ip $remote_addr;

	proxy_set_header Upgrade $http_upgrade;
	proxy_set_header Connection "upgrade";

	proxy_pass http://your-website-name; # Defined above
}
```

Save and test the config using `sudo nginx -t` and if OK restart with `sudo systemctl restart nginx`. Now we can build and start our Phoenix application and test our server. Go to the project directory and run

```
$ npm run deploy --prefix ./assets
$ mix phx.digest
$ MIX_ENV=prod mix compile
$ MIX_ENV=prod mix release 
$ _build/prod/rel/your_project/bin/your_project start
```

You should now be able to go to your domain and see your Phoeinx application. You can stop your application by using 

```
$ _build/prod/rel/your_project/bin/your_project stop
``` 

If you want to run your application and exit the Droplet you can use 

```
$ _build/prod/rel/your_project/bin/your_project daemon
``` 
You can see all the commands available using 

```
$ _build/prod/rel/your_project/bin/your_project
```

In Part 3 I am going to deploy another Phoeinx Application and configure `Nginx` to serve both sites.

<p>&nbsp;</p>
<p>&nbsp;</p>
<p>&nbsp;</p>
<p>&nbsp;</p>